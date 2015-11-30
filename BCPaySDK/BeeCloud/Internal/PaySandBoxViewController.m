//
//  PaySandBoxViewController.m
//  BCPay
//
//  Created by Ewenlong03 on 15/11/30.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "PaySandBoxViewController.h"
#import "BeeCloud.h"

@interface PaySandBoxViewController () {
    UIStatusBarStyle statusStyle;
    
    UIView *titleView;
    UIButton *leftBtn;
    UIButton *rightBtn;
    
    NSInteger resultCode;
    NSString *resultMsg;
}

@end

@implementation PaySandBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    resultCode = BCErrCodeCommon;
    resultMsg = @"支付失败";
    
    self.view.backgroundColor = [UIColor whiteColor];
    if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
        statusStyle = [UIApplication sharedApplication].statusBarStyle;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    titleView.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:59.0/255.0 alpha:1];
    [self.view addSubview:titleView];
    
    leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 60, 40)];
    leftBtn.backgroundColor = [UIColor clearColor];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:leftBtn];
    
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100, 22, 90, 40)];
    rightBtn.backgroundColor = [UIColor clearColor];
    [rightBtn setTitle:@"支付完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:rightBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = statusStyle;
    BCPayResp *resp = (BCPayResp *)[BCPayCache sharedInstance].bcResp;
    resp.resultCode = resultCode;
    resp.resultMsg = resultMsg;
    resp.errDetail = resultMsg;
    [BCPayCache beeCloudDoResponse];
}

- (void)back {
    resultCode = BCErrCodeUserCancel;
    resultMsg = @"支付取消";
    
    [self dismissViewControllerAnimated:YES completion:^{
//        BCPayResp *resp = (BCPayResp *)[BCPayCache sharedInstance].bcResp;
//        resp.resultCode = resultCode;
//        resp.resultMsg = resultMsg;
//        resp.errDetail = resultMsg;
//        [BCPayCache beeCloudDoResponse];
    }];
}

- (void)pay {
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForRequest];
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    NSString *host = [NSString stringWithFormat:@"%@%@/%@",[BCPayUtil getBestHostWithFormat:kRestApiSandBoxNotify], [BCPayCache sharedInstance].appId, self.objectId];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    __weak PaySandBoxViewController *weakSelf = self;
    [manager GET:[BCPayUtil getBestHostWithFormat:host] parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"resp = %@", response);
             [weakSelf doNotifyResponse:(NSDictionary *)response];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [BCPayUtil doErrorResponse:kNetWorkError];
         }];
}

- (void)doNotifyResponse:(NSDictionary *)response {
    if ([response integerValueForKey:kKeyResponseResultCode defaultValue:BCErrCodeCommon] == BCErrCodeSuccess) {
        resultMsg = @"支付成功";
        resultCode = BCErrCodeSuccess;
    }
}



@end
