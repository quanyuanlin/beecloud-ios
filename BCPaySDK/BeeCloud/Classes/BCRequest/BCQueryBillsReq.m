//
//  BCQueryBillsReq.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryBillsReq.h"

#pragma mark query request
@implementation BCQueryBillsReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryBillsReq;
        self.skip = 0;
        self.limit = 10;
        self.startTime = @"";
        self.endTime = @"";
        self.billNo = @"";
        self.billStatus = BillStatusAll;
        self.needMsgDetail = NO;
    }
    return self;
}
@end
