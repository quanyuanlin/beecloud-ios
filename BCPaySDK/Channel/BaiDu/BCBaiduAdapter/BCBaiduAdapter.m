//
//  BCBaiduAdapter.m
//  BCPay
//
//  Created by Ewenlong03 on 15/9/23.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCBaiduAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "BCPayUtil.h"
#import "BDWalletSDKMainManager.h"

@interface BCBaiduAdapter ()<BeeCloudAdapterDelegate,BDWalletSDKMainManagerDelegate>
@property (nonatomic, weak) id<BeeCloudDelegate> delegate;
@end

@implementation BCBaiduAdapter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCBaiduAdapter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCBaiduAdapter alloc] init];
    });
    return instance;
}

- (void)setBeeCloudDelegate:(id<BeeCloudDelegate>)delegate {
    [BCBaiduAdapter sharedInstance].delegate = delegate;
}

- (void)baiduPay:(NSMutableDictionary *)dic {
    [[BDWalletSDKMainManager getInstance] doPayWithOrderInfo:dic[@"orderInfo"] params:nil delegate:self];
}

- (void)BDWalletPayResultWithCode:(int)statusCode payDesc:(NSString *)payDescs {
    NSString *status = @"";
    switch (statusCode) {
        case 0:
            status = @"支付成功";
            break;
        case 1:
            status = @"支付中";
            break;
        case 2:
            status = @"支付取消";
            break;
        default:
            break;
    }
    BCPayResp *resp = [[BCPayResp alloc] init];
    resp.result_code = statusCode;
    resp.result_msg = status;
    resp.err_detail = status;
    resp.paySource = @{@"payDescs":payDescs};
    if (_delegate && [_delegate respondsToSelector:@selector(onBeeCloudResp:)]) {
        [_delegate onBeeCloudResp:resp];
    }
}

- (void)logEventId:(NSString *)eventId eventDesc:(NSString *)eventDesc {
    
}

@end
