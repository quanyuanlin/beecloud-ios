//
//  BCRefundStateReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayConstant.h"

@interface BCRefundStatusReq : BCBaseReq //type=104;

@property (nonatomic, retain) NSString *refundno;

@end
