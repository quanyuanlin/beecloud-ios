//
//  BCQRefundResult.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResult.h"

#pragma mark BCQRefundResult

@interface BCQRefundResult : BCBaseResult

@property (nonatomic, retain) NSString *refund_no;
@property (nonatomic, assign) NSNumber *refund_fee; //NSInteger
@property (nonatomic, assign) NSNumber *finish;//BOOL
@property (nonatomic, assign) NSNumber *result;//BOOL

@end
