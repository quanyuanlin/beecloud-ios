//
//  BCQueryRefundByIdReq.m
//  BCPay
//
//  Created by Ewenlong03 on 15/11/25.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryRefundByIdReq.h"

@implementation BCQueryRefundByIdReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryRefundByIdReq;
        self.objectId = @"";
    }
    return self;
}

+ (instancetype)getInstance:(NSString *)objectId {
    BCQueryRefundByIdReq *req = [[BCQueryRefundByIdReq alloc] init];
    req.objectId = objectId;
    return req;
}

@end
