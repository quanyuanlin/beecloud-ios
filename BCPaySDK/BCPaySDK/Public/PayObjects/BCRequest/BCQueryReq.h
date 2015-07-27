//
//  BCQueryReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayConstant.h"

#pragma mark BCQueryReq
/**
 *  queryBills 请求结构体
 */
@interface BCQueryReq : BCBaseReq //type=102;

@property (nonatomic, assign) PayChannel channel;
@property (nonatomic, retain) NSString *billno;
@property (nonatomic, assign) NSString *starttime;//@"yyyyMMddHHmm"格式
@property (nonatomic, assign) NSString *endtime;//@"yyyyMMddHHmm"格式
@property (nonatomic, assign) NSInteger skip;
@property (nonatomic, assign) NSInteger limit;

@end
