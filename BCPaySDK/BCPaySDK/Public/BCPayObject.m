//
//  BCPayObject.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/21.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//
#import "BCPayObject.h"
#import <Foundation/Foundation.h>
#import "BCPayUtil.h"
#import "BCUtil.h"

#pragma makr base request
@implementation BCBaseReq
- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = 0;
    }
    return self;
}

@end

#pragma mark base response
@implementation BCBaseResp
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
@end

#pragma mark pay request
@implementation BCPayReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = 1;
    }
    return self;
}
@end

#pragma mark pay response
@implementation BCPayResp
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
@end

#pragma mark query request
@implementation BCQueryReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = 2;
        self.skip = 0;
        self.limit = 10;
        self.starttime = @"";
        self.endtime = @"";
        self.billno = @"";
    }
    return self;
}
@end

#pragma mark query response
@implementation BCQueryResp
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
@end

#pragma mark query refund request
@implementation BCQRefundReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = 3;
        self.refundno = @"";
    }
    return self;
}
@end



