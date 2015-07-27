//
//  BCPayResp.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//
#import "BCBaseResp.h"

#pragma mark BCPayResp
/**
 *  Pay 响应结构体
 */
@interface BCPayResp : BCBaseResp  //type=201;

@property (nonatomic, retain) NSDictionary *paySource;

@end
