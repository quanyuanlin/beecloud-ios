//
//  BCQRefundResult.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResult.h"

#pragma mark BCQueryRefundResult

/**
 *  退款订单查询结果
 */
@interface BCQueryRefundResult : BCBaseResult

@property (nonatomic, retain) NSString *refundno;
@property (nonatomic, assign) NSInteger refundfee; //NSInteger
@property (nonatomic, assign) BOOL      finish;//BOOL
@property (nonatomic, assign) BOOL      result;//BOOL

@end
