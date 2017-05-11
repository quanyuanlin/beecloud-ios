//
//  BCProtocol.h
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeeCloud.h"

@interface BeeCloudAdapter : NSObject

+ (BOOL)bcRegisterWeChat:(NSString *_Nonnull)appid;
+ (BOOL)bcIsWXAppInstalled;
+ (BOOL)bc:(NSString * _Nonnull)object handleOpenUrl:(NSURL *_Nonnull)url;

+ (BOOL)bcWXPay:(NSMutableDictionary *_Nonnull)dic;
+ (BOOL)bcAliPay:(NSMutableDictionary *_Nonnull)dic;
+ (BOOL)bcUnionPay:(NSMutableDictionary *_Nonnull)dic;
+ (BOOL)bcApplePay:(NSMutableDictionary *_Nonnull)dic;
+ (NSString *_Nonnull)bcBaiduPay:(NSMutableDictionary *_Nonnull)dic;
+ (BOOL)beecloudSandboxPay;
+ (BOOL)beecloudCanMakeApplePayments:(NSUInteger)cardType;

+ (void)bcOfflinePay:(NSMutableDictionary *_Nonnull)dic;
+ (void)bcOfflineStatus:(NSMutableDictionary *_Nonnull)dic;
+ (void)bcOfflineRevert:(NSMutableDictionary *_Nonnull)dic;

+ (void)bcInitBCWXPay:(NSString *_Nonnull)wxAppId;
+ (void)bcBCWXPay:(NSMutableDictionary *_Nonnull)dic;

@end
