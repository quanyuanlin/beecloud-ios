//
//  BCUnionPay.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/10.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayUtil.h"
#import "UPPayPlugin.h"

@interface BCUnionPay : NSObject<UPPayPluginDelegate>
{
    BCPayBlock payBlock;
}

#pragma mark - UnionPay functions
/** @name unionPay functions*/

+ (instancetype)sharedInstance;

/**
 *  银联在线支付
 *
 *  @param trace_id       支付用户ID，必须保证在商户系统中唯一，32个字节，最长为16个汉字.可通过trace_id查询订单详情
 *  @param body           商品的标题/交易标题/订单标题/订单关键字等。该参数最长为32个字节(16个汉字)
 *  @param out_trade_no   商户系统内部的支付订单号,包含数字与字母,确保在商户系统中唯一,8~40字节的变长字母和/或数字字符
 *  @param total_fee      支付金额,以分为单位
 *  @param viewController 调起银联支付的页面
 *  @param optional       扩展参数，可以传入任意数量的key/value对来补充对业务逻辑的需求
 *  @param block          接收支付结果回调
 */
+ (void)reqUnionPayment:(NSString *)body
             outTradeNo:(NSString *)out_trade_no
               totalFee:(NSString *)total_fee
         viewController:(UIViewController *)viewController
               optional:(NSDictionary *)optional
               payblock:(BCPayBlock)block ;

/**
 *  银联预退款，支持部分退款或者全额退款。如果提供的支付订单的交易状态不支持退款，在block中返回具体的信息;如果支持退款，生成预退款订单，商户在管理后台管理预退款订单。
 *
 *  @param out_trade_no  商户系统内部的支付订单号,包含数字与字母,确保在商户系统中唯一,8~40字节的变长字母和/或数字字符
 *  @param refund_fee    退款金额
 *  @param out_refund_no 商户系统内部的退款订单号,包含数字与字母,确保在商户系统中唯一,8~40字节的变长字母和/或数字字符
 *  @param refund_reason 退款原因
 *  @param block         接收预退款订单生成结果
 */
+ (void)reqUnionRefund:(NSString *)out_trade_no
             refundFee:(NSString *)refund_fee
           outRefundNo:(NSString *)out_refund_no
          refundReason:(NSString *)refund_reason
           refundBlock:(BCPayBlock)block;

@end
