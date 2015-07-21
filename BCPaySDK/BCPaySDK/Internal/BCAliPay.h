//
//  BCAliPay.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/10.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayUtil.h"

@interface BCAliPay : NSObject

#pragma mark - AliPay Functions
/** @name AliPay Functions */

+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 *  支付宝支付
 *
 *  @param trace_id     支付用户ID，必须保证在商户系统中唯一，32个字节，最长为16个汉字.可通过trace_id查询订单详情。
 *  @param out_trade_no 商户系统内部的支付订单号,包含数字与字母,确保在商户系统中唯一,该参数最长为64个字符
 *  @param subject      商品的标题/交易标题/订单标题/订单关键字等，256个字节，最长为128个汉字
 *  @param body         对一笔交易的具体描述信息。如果是多种商品,请将商品描述字符串累加传给body,长度不大于512字节
 *  @param total_fee    该笔订单的资金总额,单位为RMB-Yuan。取值范围为[0.01,100000000.00],精确到小数点后两位
 *  @param scheme       调用支付的app注册在info。plist中的scheme
 *  @param optional     扩展参数，可以传入任意数量的key/value对来补充对业务逻辑的需求
 *  @param block        支付结果回调.strMsg=@"订单支付成功";//@"正在处理中";@"订单支付失败";@"用户中途取消";@"网络连接错误";
 */
+ (void)reqAliPayment:(NSString *)out_trade_no
              subject:(NSString *)subject
                 body:(NSString *)body
             totalFee:(NSString *)total_fee
               scheme:(NSString *)scheme
             optional:(NSDictionary *)optional
             payBlock:(BCPayBlock)block;

+ (void)processOrderForAliPay:(NSDictionary *)resultDic;

/**
 *  根据out_trade_no，refund_no, refund_reason,refund_fee查询订单是否可退款，允许退款情况下自动生成预退款订单，否则返回不可退款原因。预退款订单生成成功后，在BeeCloud商户后台对预退款订单进行处理。（订单状态trade_status=@”TRADE_SUCCESS“)时支持退款，其他状态下不支持退款。
 *
 *  @param out_trade_no  商户系统内部的支付订单号,包含数字与字母,确保在商户系统中唯一
 *  @param refund_no     格式为:退款日期(8位)+流水号(3~8位)。不可重复,且退款日期必须是当天日期(年月日)。
 *                       流水号可以接受数字或英文字符,建议使用数字,但不可接受“000”。例如: 201101120001
 *  @param refund_fee    退款金额
 *  @param refund_reason 退款原因
 *  @param block         退款结果回调
 */
+ (void)reqAliRefund:(NSString *)out_trade_no
            refundNo:(NSString *)out_refund_no
           refundFee:(NSString *)refund_fee
        refundReason:(NSString *)refund_reason
         refundBlock:(BCPayBlock)block;

@end
