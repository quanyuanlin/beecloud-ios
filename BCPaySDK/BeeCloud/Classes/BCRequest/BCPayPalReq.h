//
//  BCPayPalReq.h
//  BCPay
//
//  Created by Ewenlong03 on 15/8/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"

#pragma mark  BCPayPalReq

@interface BCPayPalReq : BCBaseReq

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *shipping;
@property (nonatomic, strong) NSString *tax;
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, strong) id payConfig;
@property (nonatomic, strong) id viewController;

@end
