//
//  BCQRefundResult.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQRefundResult.h"

@implementation BCQRefundResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeRefundsResults;
        self.refund_no = @"";
        self.refund_fee = @0;
        self.result = @NO;
        self.finish = @NO;
    }
    return self;
}

@end
