//
//  BCQueryRefundsCount.m
//  BCPay
//
//  Created by Ewenlong03 on 15/11/26.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryRefundsCountReq.h"

@implementation BCQueryRefundsCount

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryRefundsCountReq;
        self.refundNo = @"";
        self.billNo = @"";
        self.startTime = @"";
        self.endTime = @"";
        self.needApproved = NeedApprovalAll;
    }
    return self;
}

- (void)reqBillsCount {
    
}

@end
