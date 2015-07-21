//
//  BCWXPay.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/10.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayUtil.h"

@interface BCWXPay : NSObject

#pragma mark - WXPay functions
/** @name WeChatPay */

/**
 *  WXApi的成员函数，向微信终端程序注册第三方应用。
 *  需要在每次启动第三方应用程序时调用。第一次调用后，会在微信的可用应用列表中出现。
 *  iOS7及以上系统需要调起一次微信才会出现在微信的可用应用列表中。
 *
 *  @param wxAppID 微信开放平台创建APP的APPID
 *
 *  @return 成功返回YES，失败返回NO。只有YES的情况下，才能正常执行支付。
 */
+ (BOOL)initWeChatPay:(NSString *)wxAppID;

/**
 * 处理微信通过URL启动App时传递的数据
 *
 * @param 需要在application:openURL:sourceApplication:annotation:中调用。
 * @param url 启动第三方应用时传递过来的URL
 *
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 *  微信支付调用接口.初始化boby,totalFee,outTradeNo,traceid后调用此接口发起微信支付，并跳转到微信。
 *  如果您申请的是新版本(V3)的微信支付，请使用此接口发起微信支付.
 *
 *  @param body       商品描述,32个字节内，最长16个汉字
 *  @param totalFee   支付金额,以分为单位
 *  @param outTradeNo 商户系统内部的订单号,32个字节内、只包含数字与字母,确保在商户系统中唯一
 *  @param traceId    支付用户ID，必须保证在商户系统中唯一，32个字节，最长为16个汉字
 *  @param optional   扩展参数，可以传入任意数量的key/value对来补充对业务逻辑的需求，
 *  @param block      支付结果回调
 */
+ (void)reqWXPayV3:(NSString *)body
          totalFee:(NSString *)totalFee
        outTradeNo:(NSString *)outTradeNo
          optional:(NSDictionary *)optional
          payBlock:(BCPayBlock)block;

/**
 *  根据out_trade_no，out_refund_no, refundReason,refundFee查询订单是否可退款，允许退款情况下自动生成预退款订单，否则返回不可退款原因。预退款订单生成成功后，在BeeCloud商户后台对预退款订单进行处理。
 *
 *  @param outTradeNo   商户系统内部的支付订单号,32个字符内、包含数字与字母,确保在商户系统中唯一
 *  @param outRefundNo  商户系统内部的退款订单号,32个字符内、包含数字与字母,确保在商户系统中唯一
 *  @param refundReason 用户退款理由
 *  @param refundFee    用户欲退款金额，以分为单位
 *  @param block        退款结果回调.如果预退款成功,success=YES;失败success=NO.
 */
+ (void)reqWXRefundV3:(NSString *)outTradeNo
          outRefundNo:(NSString *)outRefundNo
         refundReason:(NSString *)refundReason
            refundFee:(NSString *)refundFee
             payBlock:(BCPayBlock)block;

/**
 *  向微信发送查询订单状态请求
 *
 *  @param outTradeNo 商户系统内部的订单号,32个字节内、只包含数字与字母,确保在商户系统中唯一
 *  @param block      查询结果回调。success=YES时，正确返回从微信后台获取的订单状态;success=NO时，返回订单查询请求失败原因
 */
+ (void)reqQueryPayOrder:(NSString *)outTradeNo queryBlock:(BCPayBlock)block;

/**
 *  根据商户自定义退款订单号查询退款状态。
 *
 *  @param out_refund_no 商户自定义退款订单号
 *  @param block         退款状态回调。success=YES时，正确返回从微信后台获取的退款状态;success=NO时，返回退款查询请求失败原因。
 */
+ (void)reqQueryRefund:(NSString *)out_refund_no block:(BCPayBlock)block;

@end
