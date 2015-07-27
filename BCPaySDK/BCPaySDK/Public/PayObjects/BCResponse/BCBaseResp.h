//
//  BCBaseResp.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark BCBaseResp
/**
 *  BCPay所有响应的基类
 */
@interface BCBaseResp : NSObject

/** 响应码 */
@property (nonatomic, assign) int result_code;
/** 响应提示字符串 */
@property (nonatomic, retain) NSString *result_msg;
/** 错误详情 */
@property (nonatomic, retain) NSString *err_detail;

@end
