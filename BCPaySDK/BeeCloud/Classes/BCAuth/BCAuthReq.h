//
//  BCAuthReq.h
//  BCPay
//
//  Created by Ewenlong03 on 16/9/20.
//  Copyright © 2016年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayUtil.h"

@interface BCAuthReq : BCBaseReq
/**
 *  姓名
 */
@property (nonatomic, retain) NSString *name;
/**
 *  身份证号码
 */
@property (nonatomic, retain) NSString *idNo;
/**
 *  银行卡号
 */
@property (nonatomic, retain) NSString *cardNo;
/**
 *  手机号
 */
@property (nonatomic, retain) NSString *mobile;

- (void)authReqWithName:(NSString *)name idNo:(NSString *)idNo;

- (void)authReq;

@end
