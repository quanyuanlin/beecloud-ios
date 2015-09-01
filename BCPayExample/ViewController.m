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

@interface ViewController ()<BCApiDelegate, PayPalPaymentDelegate> {
    PayPalConfiguration * _payPalConfig;
    PayPalPayment *_completedPayment;
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
    [BCPay setBCApiDelegate:self];
    
}

- (void)doPay:(PayChannel)channel {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];

    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"20150901-PayPal-Release";
    payReq.totalfee = @"1";
    payReq.billno = outTradeNo;
    payReq.scheme = @"payDemo";
    payReq.viewController = self;
    payReq.optional = dict;
    [BCPay sendBCReq:payReq];
}

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
    payReq.shortDesc = @"paypal test";
    payReq.viewController = self;
    payReq.payConfig = _payPalConfig;
    
    [BCPay sendBCReq:payReq];
    
}

- (void)doPayPalVerify {
    BCPayPalVerifyReq *req = [[BCPayPalVerifyReq alloc] init];
    req.payment = _completedPayment;
    [BCPay sendBCReq:req];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success! %@", completedPayment.description);
    
    _completedPayment = completedPayment;

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationVC = (UINavigationController*)segue.destinationViewController;
    QueryResultViewController *vc = (QueryResultViewController *)navigationVC.childViewControllers[0];
    vc.dataList = self.payList;
}

- (void)onBCPayResp:(BCBaseResp *)resp {
    if ([resp isKindOfClass:[BCQueryResp class]]) {
        if (resp.result_code == 0) {
            BCQueryResp *tempResp = (BCQueryResp *)resp;
            if (tempResp.count == 0) {
                [self showAlertView:@"未找到相关订单信息"];
            } else {
                self.payList = tempResp.results;
                [self performSegueWithIdentifier:@"queryResult" sender:self];
            }
        }
    } else {
        if (resp.result_code == 0) {
             [self showAlertView:resp.result_msg];
        } else {
             [self showAlertView:resp.err_detail];
        }
    }
}

#pragma mark - 银联支付

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 订单查询

- (void)doQuery:(PayChannel)channel {
    
    if (self.actionType == 1) {
        BCQueryReq *req = [[BCQueryReq alloc] init];
      //  req.channel = channel;
        req.billno = @"20150901104138656";
       // req.starttime = @"2015-07-23 00:00";
     //   req.endtime = @"2015-07-23 12:00";
        req.skip = 0;
        req.limit = 50;
        [BCPay sendBCReq:req];
    } else if (self.actionType == 2) {
        BCQueryRefundReq *req = [[BCQueryRefundReq alloc] init];
       // req.channel = channel;
        //  req.billno = @"20150722164700237";
        //  req.starttime = @"2015-07-21 00:00";
        // req.endtime = @"2015-07-23 12:00";
        //req.refundno = @"20150709173629127";
        req.skip = 0;
        req.limit = 20;
        [BCPay sendBCReq:req];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == 0) {
        if (indexPath.row == 3) {
            [self doPayPal];
        } else if (indexPath.row == 4) {
            [self doPayPalVerify];
        } else {
            [self doPay:(PayChannel)((indexPath.row + 1)*10+1)];
        }
    } else {
        [self doQuery:(PayChannel)((indexPath.row + 1)*10)];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

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
