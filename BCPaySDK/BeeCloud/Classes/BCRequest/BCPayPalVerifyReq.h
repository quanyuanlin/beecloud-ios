//
//  BCPayPalAccessTokenReq.h
//  BCPay
//
//  Created by Ewenlong03 on 15/8/28.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"

#pragma mark BCPayPalVerifyReq

@interface BCPayPalVerifyReq : BCBaseReq

@property (nonatomic, strong) id payment;
@property (nonatomic, strong) NSDictionary *optional;

@end
