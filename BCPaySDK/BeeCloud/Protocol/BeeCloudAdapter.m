//
//  BeeCloudAdapaterProtocol.m
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BeeCloudAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import "BCPayCache.h"

@implementation BeeCloudAdapter

+ (BOOL)bcRegisterWeChat:(NSString *)appid {
    id adapter = [[NSClassFromString(kAdapterWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(registerWeChat:)]) {
        return [adapter registerWeChat:appid];
    }
    return NO;
}

+ (BOOL)bcIsWXAppInstalled {
    id adapter = [[NSClassFromString(kAdapterWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(isWXAppInstalled)]) {
        return [adapter isWXAppInstalled];
    }
    return NO;
}

+ (BOOL)bc:(NSString *)object handleOpenUrl:(NSURL *)url {
    id adapter = [[NSClassFromString(object) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(handleOpenUrl:)]) {
        return [adapter handleOpenUrl:url];
    }
    return NO;
}

+ (BOOL)bcWXPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(wxPay:)]) {
         return [adapter wxPay:dic];
    }
    return NO;
}

+ (BOOL)bcAliPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterAliPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(aliPay:)]) {
        return [adapter aliPay:dic];
    }
    return NO;
}

+ (BOOL)bcUnionPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterUnionPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(unionPay:)]) {
        return [adapter unionPay:dic];
    }
    return NO;
}

+ (BOOL)beecloudCanMakeApplePayments:(NSUInteger)cardType {
    id adapter = [[NSClassFromString(kAdapterApplePay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(canMakeApplePayments:)]) {
        return [adapter canMakeApplePayments:cardType];
    }
    return NO;
}

+ (BOOL)bcApplePay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterApplePay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(applePay:)]) {
        return [adapter applePay:dic];
    }
    return NO;
}

+ (NSString *)bcBaiduPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterBaidu) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(baiduPay:)]) {
        return [adapter baiduPay:dic];
    }
    return nil;
}

+ (BOOL)beecloudSandboxPay {
    id adapter = [[NSClassFromString(kAdapterSandbox) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(sandboxPay)]) {
        return [adapter sandboxPay];
    }
    return NO;
}

+ (void)bcOfflinePay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterOffline) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(offlinePay:)]) {
        [adapter offlinePay:dic];
    }
}

+ (void)bcOfflineStatus:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterOffline) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(offlineStatus:)]) {
        [adapter offlineStatus:dic];
    }
}

+ (void)bcOfflineRevert:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterOffline) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(offlineRevert:)]) {
        [adapter offlineRevert:dic];
    }
}

+ (void)bcInitBCWXPay:(NSString *)wxAppId {
    id adapter = [[NSClassFromString(kAdapterBCWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(initBCWXPay:)]) {
        [adapter initBCWXPay:wxAppId];
    }
}

+ (void)bcBCWXPay:(NSMutableDictionary *)dic {
    id adapter = [[NSClassFromString(kAdapterBCWXPay) alloc] init];
    if (adapter && [adapter respondsToSelector:@selector(bcWXPay:)]) {
        [adapter bcWXPay:dic];
    }
}

@end
