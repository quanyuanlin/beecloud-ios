//
//  BCPayResp.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <BCPaySDK/BCPaySDK.h>

#pragma mark BCPayResp
/**
 *  Pay 响应结构体
 */
@interface BCPayResp : BCBaseResp

@property (nonatomic, retain) NSDictionary *paySource;

@end
