//
//  BCPayObject.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/14.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PayChannel) {
    None  = 0,
    WX    = 1 << 0,
    Ali   = 1 << 1,
    Union = 1 << 2
};

/**
 *  Result block for pay result.
 *
 *  @param result Pay result, success\fail\cancel\invalid
 *  @param error  Error
 */
typedef void (^BCPayBlock)(BOOL success, NSString *strMsg, NSError *error);

/**
 *  Result block for array result.
 *
 *  @param objects Array result.
 *  @param error   Carries error if there is one, or nil otherwise.
 */
typedef void (^BCArrayResultBlock)(NSArray *objects, NSError *error);


@interface BCQueryOrder : NSObject
/**
 *  11:wxPay;  12:wxRefund;
 *  21:aliPay; 22:aliRefund; 
 *  31:unPay;  32:unRefund;
 */
@property (assign) NSString *queryType;
/**
 *  queryType=11/21/31时orderid为billno,即根据支付订单号查询支付订单;
 *  queryType=12/22/32时orderid为refundno,即根据退款订单号查询退款订单;
 */
@property (assign) NSString *orderid;

/**
 *  同步查询支付订单或退款订单。内置购买只支持查询支付订单表。
 *
 *  @param orderid   out_trade_no或者out_refund_no
 *  @param type      支付平台的支付订单或者退款订单
 *
 *  @return 符合条件的订单列表
 @refund status
 REFUND_START = 0; //退款开始
 REFUND_REJECT = 1; //退款被商家拒绝
 REFUND_ACCEPT = 2; //退款被商家同意
 REFUND_SUCCESS = 3; //退款成功
 REFUND_FAIL = 4; //退款被渠道拒绝
 REFUND_RETRY = 5; //退款被渠道拒绝，但原因不明， 需要用原退款单号重试
 REFUND_NEED_OFFLINE = 6; //用户银行卡已注销，现金回流到商户账户，需要走线下人工操作
 */
+ (NSArray *)queryOrder:(NSString *)type orderid:(NSString *)orderid ;

/**
 *  异步查询支付订单或退款订单。内置购买只支持查询支付订单表。
 *
 *  @param orderid   out_trade_no或者out_refund_no
 *  @param type      支付平台的支付订单或者退款订单
 *  @param block     接收查询结果
 */
+ (void)querOrderAsync:(NSString *)orderid type:(NSString *)type block:(BCArrayResultBlock)block ;

@end





