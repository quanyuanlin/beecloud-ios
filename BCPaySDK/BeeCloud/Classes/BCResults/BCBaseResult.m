//
//  BCBaseResult.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResult.h"

@implementation BCBaseResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeBaseResults;
        self.channel = @"";
        self.billno = @"";
        self.title = @"";
        self.createdtime = 0;
        self.totalfee = 0;
    }
    return self;
}
@end
