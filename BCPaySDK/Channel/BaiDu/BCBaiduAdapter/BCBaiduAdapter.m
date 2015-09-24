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

@interface BCBaiduAdapter ()<BeeCloudAdapterDelegate>
@end

@implementation BCBaiduAdapter

- (void)baiduPay:(NSMutableDictionary *)dic {
    BCPayResp *resp = (BCPayResp *)[BCPayCache sharedInstance].bcResp;
    resp.result_code = [[dic objectForKey:kKeyResponseResultCode] intValue];
    resp.result_msg = [dic objectForKey:kKeyResponseResultMsg];
    resp.err_detail = [dic objectForKey:kKeyResponseErrDetail];
    resp.paySource = @{@"orderInfo":[dic objectForKey:@"orderInfo"]};
    [BCPayCache beeCloudDoResponse];
}

@end
