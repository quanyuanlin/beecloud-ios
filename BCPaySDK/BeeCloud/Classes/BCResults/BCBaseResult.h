//
//  BCBaseResult.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCPayConstant.h"
#import "NSDictionary+Utils.h"

#pragma mark BCBaseResult

/**
 *  订单查询结果的基类
 */
@interface BCBaseResult : NSObject

@property (nonatomic, assign) BCObjsType type;
@property (nonatomic, retain) NSString  *billNo;
@property (nonatomic, assign) NSInteger  totalFee;//NSInteger
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, assign) long long  createTime;//long long
@property (nonatomic, retain) NSString  *channel;
@property (nonatomic, retain) NSString  *subChannel;
@property (nonatomic, retain) NSDictionary  *optional;

- (instancetype) initWithResult:(NSDictionary *)dic;

@end
