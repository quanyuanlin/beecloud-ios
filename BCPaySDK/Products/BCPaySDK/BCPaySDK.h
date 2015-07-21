//
//  BCPay.h
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPayObject.h"


@interface BCPaySDK : NSObject

/**
 *  全局初始化
 *
 *  @param appId     BeeCloud平台APPID
 *  @param appSecret BeeCloud平台APPSECRET
 */
+ (void)initWithAppID:(NSString *)appId andAppSecret:(NSString *)appSecret;

/**
 *  需要在每次启动第三方应用程序时调用。第一次调用后，会在微信的可用应用列表中出现。
 *  iOS7及以上系统需要调起一次微信才会出现在微信的可用应用列表中。
 *
 *  @param wxAppID 微信开放平台创建APP的APPID
 *
 *  @return 成功返回YES，失败返回NO。只有YES的情况下，才能正常执行微信支付。
 */
+ (BOOL)initWeChatPay:(NSString *)wxAppID;

/**
 * 处理通过URL启动App时传递的数据
 *
 * @param 需要在application:openURL:sourceApplication:annotation:中调用。
 * @param url 启动第三方应用时传递过来的URL
 *
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 *  获取API版本号
 *
 *  @return 版本号
 */
+ (NSString *)getBCApiVersion;

#pragma mark - pay function
/** @name pay function */

/**
*  发起支付
*
*  @param channel        支付渠道(WeChatPay,AliPay,UnionPay)
*  @param title          订单描述,32个字节内,最长16个汉字
*  @param totalfee       支付金额,以分为单位,必须为整数,100表示1元
*  @param traceno        商户系统内部的订单号,8~32位数字和/或字母组合,确保在商户系统中唯一
*  @param scheme         调用支付的app注册在info.plist中的scheme,支付宝支付需要
*  @param viewController 调起银联支付的页面，银联支付需要
*  @param optional       扩展参数,可以传入任意数量的key/value对来补充对业务逻辑的需求
*  @param block          支付结果回调
*/
+ (void)reqPayChannel:(PayChannel)channel
                title:(NSString *)title
             totalfee:(NSString *)totalfee
              traceno:(NSString *)traceno
               scheme:(NSString *)scheme
       viewController:(UIViewController *)viewController
             optional:(NSDictionary *)optional
             payBlock:(BCPayBlock)block;

/**
 *  根据traceno,refundno,reason,refundee生成预退款订单。预退款订单生成成功后，在BeeCloud商户后台对预退款订单进行处理。
 *
 *  @param channel   支付渠道(WeChatPay,AliPay,UnionPay)
 *  @param traceno   商户系统内部的订单号,8~32位数字和/或字母组合,确保在商户系统中唯一
 *  @param refundno  格式为:退款日期(8位)+流水号(3~24位)。不可重复,且退款日期必须是当天日期(年月   日)。流水号可以接受数字或英文字符,建议使用数字,但不可接受“000”。例如: 201101120001
 *  @param reason    用户退款理由
 *  @param refundfee 退款金额，以分为单位
 *  @param block     退款结果回调.如果预退款成功,success=YES;失败success=NO.
 */
+ (void)reqRefundChannel:(PayChannel)channel
                 traceno:(NSString *)traceno
                refundno:(NSString *)refundno
                  reason:(NSString *)reason
               refundfee:(NSString *)refundfee
                payBlock:(BCPayBlock)block;

#pragma mark - query WX orders

/**
 *  向微信发送查询订单状态请求
 *
 *  @param outTradeNo 商户系统内部的订单号,32个字节内、只包含数字与字母,确保在商户系统中唯一
 *  @param block      查询结果回调。success=YES时，正确返回从微信后台获取的订单状态;success=NO时，返回订单查询请求失败原因
 */
+ (void)reqQueryWXPay:(NSString *)outTradeNo queryBlock:(BCPayBlock)block;

/**
 *  向微信发送查询退款状态请求
 *
 *  @param out_refund_no 商户自定义退款订单号
 *  @param block         退款状态回调。success=YES时，正确返回从微信后台获取的退款状态;success=NO时，返回退款查询请求失败原因。
 */
+ (void)reqQueryWXRefund:(NSString *)out_refund_no block:(BCPayBlock)block;

@end
