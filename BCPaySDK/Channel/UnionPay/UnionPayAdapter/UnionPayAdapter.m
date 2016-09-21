//
//  UnionPayAdapter.m
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "UnionPayAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "UPPayPlugin.h"

@interface UnionPayAdapter ()<BeeCloudAdapterDelegate, UPPayPluginDelegate>

@end


@implementation UnionPayAdapter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UnionPayAdapter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[UnionPayAdapter alloc] init];
    });
    return instance;
}

- (BOOL)unionPay:(NSMutableDictionary *)dic {
    NSString *tn = [dic stringValueForKey:@"tn" defaultValue:@""];
    if (tn.isValid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UPPayPlugin startPay:tn mode:@"00" viewController:dic[@"viewController"] delegate:[UnionPayAdapter sharedInstance]];
        });
        return YES;
    }
    return NO;
}

#pragma mark - Implementation UnionPayDelegate

- (void)UPPayPluginResult:(NSString *)result {
    int errcode = BCErrCodeSentFail;
    NSString *strMsg = @"支付失败";
    if ([result isEqualToString:@"success"]) {
        errcode = BCErrCodeSuccess;
        strMsg = @"支付成功";
    } else if ([result isEqualToString:@"cancel"]) {
        errcode = BCErrCodeUserCancel;
        strMsg = @"支付取消";
    }
    
    BCPayResp *resp = (BCPayResp *)[BCPayCache sharedInstance].bcResp;
    resp.resultCode = errcode;
    resp.resultMsg = strMsg;
    resp.errDetail = strMsg;
    [BCPayCache beeCloudDoResponse];
}

@end
