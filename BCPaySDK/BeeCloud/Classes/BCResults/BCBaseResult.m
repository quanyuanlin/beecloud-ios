//
//  BCBaseResult.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResult.h"

@implementation BCBaseResult

- (instancetype) initWithResult:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeBaseResults;
        if (dic) {
            self.billNo = [dic stringValueForKey:@"bill_no" defaultValue:@""];
            self.title = [dic stringValueForKey:@"title" defaultValue:@""];
            self.channel = [dic stringValueForKey:@"channel" defaultValue:@""];
            self.subChannel = [dic stringValueForKey:@"sub_channel" defaultValue:@""];
            self.createTime = [dic longlongValueForKey:@"create_time" defaultValue:0];
            self.totalFee = [dic integerValueForKey:@"total_fee" defaultValue:0];
            NSString *optionalString = [dic stringValueForKey:@"optional" defaultValue:@""];
            NSData *opData = [optionalString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            self.optional = [NSJSONSerialization JSONObjectWithData:opData options:NSJSONReadingAllowFragments error:&error];
        }
    }
    return self;
}
@end
