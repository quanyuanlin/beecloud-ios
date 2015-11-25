//
//  BCQueryBillByIdReq.h
//  BCPay
//
//  Created by Ewenlong03 on 15/11/25.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"

@interface BCQueryBillByIdReq : BCBaseReq

/**
 *  支付订单记录id
 */
@property (nonatomic, retain) NSString *objectId;

+ (instancetype)getInstance:(NSString *)objectId;

@end
