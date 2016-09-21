//
//  BCSPayAdapter.m
//  BCPay
//
//  Created by Ewenlong03 on 16/9/21.
//  Copyright © 2016年 BeeCloud. All rights reserved.
//

#import "BCWXPayAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "BCPayUtil.h"
#import "SPayClient.h"

@interface BCWXPayAdapter ()<BeeCloudAdapterDelegate>

@end

@implementation BCWXPayAdapter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCWXPayAdapter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCWXPayAdapter alloc] init];
    });
    return instance;
}

- (void)initBCWXPay:(NSString *)wxAppId {
    SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
    wechatConfigModel.appScheme = wxAppId;
    wechatConfigModel.wechatAppid = wxAppId;
    //配置微信APP支付
    [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
}

- (void)bcWXPay:(NSMutableDictionary *)dic {
    
    [[SPayClient sharedInstance] pay:dic[@"viewController"]
                              amount:0
                   spayTokenIDString:dic[@"token_id"]
                   payServicesString:@"pay.weixin.app"
                              finish:^(SPayClientPayStateModel *payStateModel,
                                       SPayClientPaySuccessDetailModel *paySuccessDetailModel) {
                                  
                              }];
}




@end
