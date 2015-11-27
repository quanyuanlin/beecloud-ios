//
//  BCQueryBillsCount.m
//  BCPay
//
//  Created by Ewenlong03 on 15/11/26.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryBillsCountReq.h"

@implementation BCQueryBillsCount

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryBillsReq;
        self.billNo = @"";
        self.startTime = @"";
        self.endTime = @"";
        self.billStatus = BillStatusAll;
    }
    return self;
}

@end
