//
//  BCQueryBillByIdReq.m
//  BCPay
//
//  Created by Ewenlong03 on 15/11/25.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryBillByIdReq.h"

@implementation BCQueryBillByIdReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryBillByIdReq;
        self.objectId = @"";
    }
    return self;
}

+ (instancetype)getInstance:(NSString *)objectId {
    BCQueryBillByIdReq *req = [[BCQueryBillByIdReq alloc] init];
    req.objectId = objectId;
    return req;
}

@end
