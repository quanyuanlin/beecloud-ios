//
//  BeeCloudAdapterProtocol.h
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#ifndef BeeCloud_BeeCloudAdapterProtocol_h
#define BeeCloud_BeeCloudAdapterProtocol_h

#import <Foundation/Foundation.h>
#import "BeeCloud.h"

@protocol BeeCloudAdapterDelegate <NSObject>

@optional
- (BOOL)registerWeChat:(NSString *)appid;
- (BOOL)isWXAppInstalled;
- (void)registerPayPal:(NSString *)clientID secret:(NSString *)secret sanBox:(BOOL)isSandBox;
- (BOOL)handleOpenUrl:(NSURL *)url;

- (void)wxPay:(NSMutableDictionary *)dic;
- (void)aliPay:(NSMutableDictionary *)dic;
- (void)unionPay:(NSMutableDictionary *)dic;
- (void)payPal:(NSMutableDictionary *)dic;
- (void)payPalVerify:(NSMutableDictionary *)dic;
- (void)baiduPay:(NSMutableDictionary *)dic;

- (void)offlinePay:(NSMutableDictionary *)dic;
- (void)offlineStatus:(NSMutableDictionary *)dic;
- (void)offlineRevert:(NSMutableDictionary *)dic;


@end

#endif
