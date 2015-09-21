//
//  ViewController.m
//  BeeCloudDemo
//
//  Created by RInz on 15/2/5.
//  Copyright (c) 2015年 RInz. All rights reserved.
//

#import "ViewController.h"
#import "QueryResultViewController.h"
#import "AFNetworking.h"
#import "PayPalMobile.h"
#import "BCOffinePay.h"
#import "GenQrCode.h"
#import "QRCodeViewController.h"
#import "ScanViewController.h"

@interface ViewController ()<BeeCloudDelegate, PayPalPaymentDelegate, SCanViewDelegate, QRCodeDelegate> {
    PayPalConfiguration * _payPalConfig;
    PayPalPayment *_completedPayment;
    PayChannel currentChannel;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.actionType == 0) {
        self.title = @"支付";
    } else if (self.actionType == 1) {
        self.title = @"查询支付订单";
    } else if (self.actionType == 2) {
        self.title = @"查询退款订单";
    }
    
    self.payList = [NSMutableArray arrayWithCapacity:10];
#pragma mark - 设置delegate
    [BeeCloud setBeeCloudDelegate:self];    
}

#pragma mark - 微信支付
- (void)doWXAppPay {
    [self doPay:PayChannelWxApp];
}

#pragma mark - 支付宝
- (void)doAliAppPay {
    [self doPay:PayChannelAliApp];
}

#pragma mark - 银联在线
- (void)doUnionPay {
    [self doPay:PayChannelUnApp];
}

- (void)doPay:(PayChannel)channel {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];

    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = billTitle;
    payReq.totalfee = @"1";
    payReq.billno = outTradeNo;
    payReq.scheme = @"payDemo";
    payReq.viewController = self;
    payReq.optional = dict;
    [BeeCloud sendBCReq:payReq];
}

- (void)doOfflinePay:(PayChannel)channel authCode:(NSString *)authcode {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    
    BCOfflinePayReq *payReq = [[BCOfflinePayReq alloc] init];
    payReq.channel = channel;
    payReq.title = billTitle;
    payReq.totalfee = @"1";
    payReq.billno = outTradeNo;
    payReq.authcode = authcode;
    payReq.terminalid = @"BeeCloud617";
    payReq.storeid = @"BeeCloud618";
    payReq.optional = dict;
    [BeeCloud sendBCReq:payReq];
}

#pragma mark - PayPal Pay
- (void)doPayPal {
    BCPayPalReq *payReq = [[BCPayPalReq alloc] init];
    
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    PayPalItem *item1 = [PayPalItem itemWithName:@"Old jeans with holes"
                                    withQuantity:2
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"84.99"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00037"];
    
    PayPalItem *item2 = [PayPalItem itemWithName:@"Free rainbow patch"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"0.00"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00066"];
    
    PayPalItem *item3 = [PayPalItem itemWithName:@"Long-sleeve plaid shirt (mustache not included)"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"37.99"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00291"];
    
    payReq.items = @[item1, item2, item3];
    payReq.shipping = @"5.00";
    payReq.tax = @"2.50";
    payReq.shortDesc = billTitle;
    payReq.viewController = self;
    payReq.payConfig = _payPalConfig;
    
    [BeeCloud sendBCReq:payReq];
    
}

#pragma mark - PayPal Verify
- (void)doPayPalVerify {
    BCPayPalVerifyReq *req = [[BCPayPalVerifyReq alloc] init];
    req.payment = _completedPayment;
    req.optional = @{@"key1":@"value1"};
    [BeeCloud sendBCReq:req];
}

#pragma mark - PayPalPaymentDelegate

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success! %@", completedPayment.description);
    
    _completedPayment = completedPayment;
    
    [self doPayPalVerify];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BCPay回调

- (void)onBeeCloudResp:(BCBaseResp *)resp {
    
    switch (resp.type) {
        case BCObjsTypeQueryResp:
        {
            if (resp.result_code == 0) {
                BCQueryResp *tempResp = (BCQueryResp *)resp;
                if (tempResp.count == 0) {
                    [self showAlertView:@"未找到相关订单信息"];
                } else {
                    self.payList = tempResp.results;
                    [self performSegueWithIdentifier:@"queryResult" sender:self];
                }
            }
        }
            break;
        case BCObjsTypeOfflinePayResp:
        {
            if (resp.result_code == 0) {
                BCOfflinePayResp *tempResp = (BCOfflinePayResp *)resp;
                switch (tempResp.request.channel) {
                    case PayChannelAliOfflineQrCode:
                    case PayChannelWxNative:
                        if (tempResp.codeurl.isValid) {
                            QRCodeViewController *qrCodeView = [[QRCodeViewController alloc] init];
                            qrCodeView.resp = tempResp;
                            qrCodeView.delegate = self;
                            self.modalPresentationStyle = UIModalPresentationCurrentContext;
                            qrCodeView.view.backgroundColor = [UIColor whiteColor];
                            [self presentViewController:qrCodeView animated:YES completion:nil];
                        }
                        break;
                    case PayChannelAliScan:
                    case PayChannelWxSCan:
                    {
                        BCOfflineStatusReq *req = [[BCOfflineStatusReq alloc] init];
                        req.channel = tempResp.request.channel;
                        req.billno = tempResp.request.billno;
                        [BeeCloud sendBCReq:req];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case BCObjsTypeOfflineBillStatusResp:
        {
            static int queryTimes = 1;
            BCOfflineStatusResp *tempResp = (BCOfflineStatusResp *)resp;
            if (!tempResp.payResult && queryTimes < 3) {
                queryTimes++;
                [BeeCloud sendBCReq:tempResp.request];
            } else {
                [self showAlertView:tempResp.payResult?@"支付成功":@"支付失败"];
//                BCOfflineRevertReq *req = [[BCOfflineRevertReq alloc] init];
//                req.channel = tempResp.request.channel;
//                req.billno = tempResp.request.billno;
//                [BeeCloud sendBCReq:req];
                queryTimes = 1;
            }
        }
            break;
        case BCObjsTypeOfflineRevertResp:
        {
            BCOfflineRevertResp *tempResp = (BCOfflineRevertResp *)resp;
            if (resp.result_code == 0) {
                [self showAlertView:tempResp.revertStatus?@"撤销成功":@"撤销失败"];
            } else {
                [self showAlertView:tempResp.err_detail];
            }
        }
            break;
        default:
        {
            if (resp.result_code == 0) {
                [self showAlertView:resp.result_msg];
            } else {
                [self showAlertView:resp.err_detail];
            }
        }
            break;
    }
}

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 订单查询
- (void)doQueryWX {
    [self doQuery:PayChannelWx];
}

- (void)doQueryAli {
    [self doQuery:PayChannelAli];
}

- (void)doQueryUN {
    [self doQuery:PayChannelUn];
}

- (void)doQueryPayPal {
    [self doQuery:PayChannelPayPal];
}

- (void)doQuery:(PayChannel)channel {
    
    if (self.actionType == 1) {
        BCQueryReq *req = [[BCQueryReq alloc] init];
        req.channel = channel;
     //   req.billno = @"20150901104138656";
       // req.starttime = @"2015-07-23 00:00";
       // req.endtime = @"2015-07-23 12:00";
        req.skip = 0;
        req.limit = 50;
        [BeeCloud sendBCReq:req];
    } else if (self.actionType == 2) {
        BCQueryRefundReq *req = [[BCQueryRefundReq alloc] init];
        req.channel = channel;
        //  req.billno = @"20150722164700237";
        //  req.starttime = @"2015-07-21 00:00";
        // req.endtime = @"2015-07-23 12:00";
        //req.refundno = @"20150709173629127";
        req.skip = 0;
        req.limit = 20;
        [BeeCloud sendBCReq:req];
    }
}

#pragma maek tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == 0) {
        switch (indexPath.row) {
            case 0:
                [self doWXAppPay];
                break;
            case 1:
                [self doOfflinePay:PayChannelWxNative authCode:@""];
                break;
            case 2:
                currentChannel = PayChannelWxSCan;
                [self showScanViewController];
                break;
            case 3:
                [self doAliAppPay];
                break;
            case 4:
                [self doOfflinePay:PayChannelAliOfflineQrCode authCode:@""];
                break;
            case 5:
                currentChannel = PayChannelAliScan;
                [self showScanViewController];
            case 6:
                [self doUnionPay];
                break;
            case 7:
                [self doPayPal];
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
            case 1:
            case 2:
                [self doQueryWX];
                break;
            case 3:
            case 4:
            case 5:
                [self doQueryAli];
                break;
            case 6:
                [self doQueryUN];
                break;
            case 7:
                [self doQueryPayPal];
                break;
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)showScanViewController {
    ScanViewController *scanView = [[ScanViewController alloc] init];
    scanView.delegate = self;
    [self presentViewController:scanView animated:YES completion:nil];
}

- (void)scanWithAuthCode:(NSString *)authCode {
    [self doOfflinePay:currentChannel authCode:authCode];
}

- (void)qrCodeBeScaned:(BCOfflinePayResp *)resp {
    BCOfflineStatusReq *req = [[BCOfflineStatusReq alloc] init];
    req.channel = resp.request.channel;
    req.billno = resp.request.billno;
    [BeeCloud sendBCReq:req];
}

#pragma mark - prepare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationVC = (UINavigationController *)segue.destinationViewController;
    QueryResultViewController *viewController = (QueryResultViewController *)navigationVC.childViewControllers[0];
    if([segue.identifier isEqualToString:@"queryResult"]) {
        viewController.dataList = self.payList;
    }
}

#pragma mark - 生成订单号
- (NSString *)genOutTradeNo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)setHideTableViewCell:(UITableView *)tableView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = view;
}

@end
