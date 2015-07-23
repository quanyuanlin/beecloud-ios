//
//  BCPay.h
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPayObject.h"

@protocol BCApiDelegate <NSObject>
@optional
- (void)doBCResp:(BCBaseResp *)resp;

@end


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
+ (BOOL)handleOpenUrl:(NSURL *)url delegate:(id<BCApiDelegate>)delegate;

/**
 *  获取API版本号
 *
 *  @return 版本号
 */
+ (NSString *)getBCApiVersion;

#pragma mark - pay function
/** @name pay function */

+ (BOOL)sendBCReq:(BCBaseReq *)req;

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
