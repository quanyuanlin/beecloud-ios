//
//  BCQueryResp.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResp.h"

#pragma mark BCQueryResp
/**
 *  queryBills 响应结构体
 */
@interface BCQueryResp : BCBaseResp //type=202;
/**
 *  查询到得结果数量
 */
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, retain) NSMutableArray *results;

@end
