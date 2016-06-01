//
//  ApplePayViewController.m
//  BCPay
//
//  Created by Ewenlong03 on 16/4/12.
//  Copyright © 2016年 BeeCloud. All rights reserved.
//

#import "ApplePayViewController.h"
#import "BeeCloud.h"


@interface ApplePayViewController ()<BeeCloudDelegate>
@property (weak, nonatomic) IBOutlet UIView *payView;

@end

@implementation ApplePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.payView.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1].CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doApplePay)];
    [self.payView addGestureRecognizer:tap];
    [self showAlertView:@"支付成功"];
}

- (void)viewWillAppear:(BOOL)animated {
    [BeeCloud setBeeCloudDelegate:self];
}

- (void)doApplePay {
    NSString *billno = [self genBillNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    /**
     按住键盘上的option键，点击参数名称，可以查看参数说明
     **/
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = PayChannelApplePay; //支付渠道
    payReq.title = @"Apple Pay Test";//订单标题
    payReq.totalFee = @"10";//订单价格
    payReq.billNo = billno;//商户自定义订单号
    payReq.billTimeOut = 300;//订单超时时间
    payReq.viewController = self; //银联支付和Sandbox环境必填
    payReq.optional = dict;//商户业务扩展参数，会在webhook回调时返回
    [BeeCloud sendBCReq:payReq];
}

- (NSString *)genBillNo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)onBeeCloudResp:(BCBaseResp *)resp {
    if (resp.type == BCObjsTypePayResp) {
        // 支付请求响应
        BCPayResp *tempResp = (BCPayResp *)resp;
        if (tempResp.resultCode == 0) {
            //微信、支付宝、银联支付成功
            [self showAlertView:resp.resultMsg];
        } else {
            //支付取消或者支付失败
            [self showAlertView:[NSString stringWithFormat:@"%@ : %@",tempResp.resultMsg, tempResp.errDetail]];
        }
    }
}
@end
