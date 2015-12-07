//
//  BCSandBoxAdapter.m
//  BCPay
//
//  Created by Ewenlong03 on 15/12/2.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCSandBoxAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "BCPayUtil.h"
#import "BCPayCache.h"
#import "PaySandBoxViewController.h"

@interface BCSandBoxAdapter () <BeeCloudAdapterDelegate>

@end

@implementation BCSandBoxAdapter

- (BOOL)sandBoxPay {
    
    BCPayReq *req = (BCPayReq *)[BCPayCache sharedInstance].bcResp.request;
    
    if (req.viewController) {
        PaySandBoxViewController *view = [[PaySandBoxViewController alloc] init];
        [req.viewController presentViewController:view animated:YES completion:^{
        }];
        return YES;
    }
    return NO;
}

@end
