//
//  BCQRefundReq.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryRefundsReq.h"

#pragma mark query refund request
@implementation BCQueryRefundsReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryRefundsReq;
        self.refundNo = @"";
        self.needApproved = NeedApprovalAll;
        self.needMsgDetail = NO;
    }
    return self;
}
@end
