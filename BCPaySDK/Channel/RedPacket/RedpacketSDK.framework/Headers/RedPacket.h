//
//  Created by 马佳 on 17/3/13.
//  Copyright © 2017年 HW_Tech.Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RPPacketInfo.h"



/** 回调
 *  RedpacketResultBlock    回调
 */
typedef void(^RedpacketResultBlock)(NSDictionary * _Nonnull resultData);


/** 请求支付宝授权报文的方法
 *  AliAuthBlock    获取支付宝授权报文的方法 (若开发者想使用自己的授权页面，请在block里写获取授权报文的方法)
 */
typedef  NSString* _Nonnull (^AliAuthBlock)();


/** 请求AppSecret的方法
 *  AppSecretBlock   获取动态Secret的方法 (请在block里写获取secret的逻辑)
 */
typedef  NSString* _Nonnull (^AppSecretBlock)();



/** 红包类型
 *  SinglePacketType              单人红包
 *  MultiplePacketTypeNormal      定额群红包
 *  MultiplePacketTypeRandom      随机金额群红包
 */
typedef NS_ENUM(NSInteger,RedpacketType)
{
    SinglePacketType =0,
    MultiplePacketTypeNormal,
    MultiplePacketTypeRandom,
    MultiplePacketTypeCommission,
};







@interface RedPacket : NSObject


/** 初始化SDK
 *  @param key          在云叮当注册应用后,得到的AppKey
 *  @param scheme       用于标识App，开发者自定，推荐使用rp+AppKey的形式
 *  @param secretBlock  获取RandomSecret的方法(请开发者在block里写获取RandomSecret的逻辑，网络请用同步请求)
 *  @param authBlock    获取支付宝授权报文的方法(不需要自定义支付宝授权页面的开发者，传nil，默认显示‘幻舞科技’的授权页面)（需要自定义的开发者，在block中写获取支付宝报文的逻辑)
 */
+(void)initRepacketSDKWithAppKey:(nonnull NSString*)key
                       URLScheme:(nonnull NSString*)scheme
                 AppSecretMethod:(nonnull AppSecretBlock)secretBlock
                AlipayAuthMehtod:(nullable AliAuthBlock)authBlock;





/** 查询用户可领红包
 *  @param startService     开启／停止查询(如：用户登陆后开启，用户退出登录后关闭，切换用户后，继续开启)
 *  @param userID           当前登录用户ID
 *  @param nickname         当前登录用户昵称
 *  @param avatar           当前登录用户头像
 *  @param groupArray       当前登陆用户关联的群ID(数组)
 *  @param block            查询结果(会持续回调)
 */
+(void)queryAvailablePackets:(BOOL)startService
                      UserID:(nonnull NSString*)userID
                UserNickname:(nonnull NSString*)nickname
                  UserAvatar:(nullable NSString*)avatar
                GroupIDArray:(nullable NSArray *)groupArray
                      Result:(nullable RedpacketResultBlock)block;





/** 发送红包
 *  @param viewcontroller   当前控制器
 *  @param type             红包类型（单人红包、群红包等枚举值）
 *  @param receiverID       红包接收方ID（单人红包传用户ID，群红包传群ID）
 *  @param outTradeNo       开发者App使用的红包编号(需保证唯一性)
 *  @param block            红包发送后的回调
 */
+(void)sendPacketFrom:(nonnull UIViewController*)viewcontroller
                 Type:(RedpacketType)type
             Receiver:(nonnull NSString*)receiverID
           OutTradeNo:(nonnull NSString*)outTradeNo
               Result:(nullable RedpacketResultBlock)block;






/** 领取红包
 *  @param viewcontroller   当前控制器
 *  @param packet           从查询方法获得的红包对象
 *  @param block            领取成功后的回调
 */
+(void)fetchRedpacketFromViewController:(nonnull UIViewController*)viewcontroller
                          RedpacketInfo:(nonnull RPPacketInfo *)packet
                           SuccessBlock:(nullable RedpacketResultBlock)block;





/** 红包纪录
 *  @param viewcontroller 当前控制器
 */
+(void)showRedpacketRecordViewFrom:(nonnull UIViewController*)viewcontroller;






/** 红包详情
 *  @param viewcontroller 当前控制器
 *  @param platPpNo 红包编号
 */
+(void)showRedpacketDetailViewFrom:(nonnull UIViewController*)viewcontroller PacketNo:(nonnull NSString*)platPpNo;






/**请在AppDelegate.m中的openURL加入下列两个方法，分别用于接收<支付宝支付回调>和<支付宝授权回调>，需导入<AlipaySDK/AlipaySDK.h>
 *
 *  [RedPacket redpacketHandleAlipayResult:resultDic url:url]的返回值为 是否是支付宝红包支付回调
 *  [RedPacket redpacketHandleAliAuthResult:resultDic url:url]的返回值为 是否是支付宝红包授权回调
 *
 *
 *  示例:
 *
 -(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 {
 [[AlipaySDK defaultService]processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic)
 {
 if (![RedPacket redpacketHandleAlipayResult:resultDic url:url])
 {
 //[您的其它方法...];
 }
 }];
 
 [[AlipaySDK defaultService]processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic)
 {
 if (![RedPacket redpacketHandleAliAuthResult:resultDic url:url])
 {
 //[您的其它方法...];
 }
 }];
 return YES;
 }
 *
 */
+(BOOL)redpacketHandleAlipayResult:(nonnull id)result url:(nonnull NSURL*)url;                  //处理发送红包后的回调
+(BOOL)redpacketHandleAliAuthResult:(nonnull id)result url:(nonnull NSURL*)url;                 //处理支付宝授权后的回调







@end
