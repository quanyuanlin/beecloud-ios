//
//  BCPayUtil.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "BCPayCache.h"

@implementation BCPayUtil

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)errorMsg {
    NSMutableDictionary *userInfo = nil;
    if (errorMsg != nil) {
        userInfo = [NSMutableDictionary dictionaryWithObject:errorMsg forKey:@"error"];
    }
    return [NSError errorWithDomain:kErrorDomain code:code userInfo:userInfo];
}

+ (NSString *)getAppSignature:(NSString *)appId appSecret:(NSString *)appSecret
{
    NSString *input = [appId stringByAppendingString:appSecret];
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSString *)getErrorStringBasedOnResultCodeAndErrMsgInResponse:(id)response {
    NSNumber *resultCode = [response objectForKey:kKeyResponseResultCode];
    NSString *errMsg = [response objectForKey:kKeyResponseErrDetail];
    if (resultCode == nil || errMsg == nil) {
        return @"Invalid response.";
    } else if ([resultCode intValue] != 0) {
        // Result code indicating error.
        return errMsg;
    }
    return nil;
}

+ (AFHTTPRequestOperationManager *)getAFHTTPRequestOperationManager {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = NO;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    return manager;
}

+ (NSMutableDictionary *)getWrappedParametersForGetRequest:(NSDictionary *) parameters {
    NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *parameterString = [[NSString alloc] initWithBytes:[parameterData bytes] length:[parameterData length]
                                                       encoding:NSUTF8StringEncoding];
    NSMutableDictionary *paramWrapper = [NSMutableDictionary dictionary];
    [paramWrapper setObject:parameterString forKey:@"para"];
    return paramWrapper;
}

+ (NSMutableDictionary *)prepareParametersForPay:(BCPayBlock)block {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *timeStamp = [BCPayUtil getNowTimeStamp];
    NSString *appSign = [BCPayUtil getAppSignature:timeStamp];
    if(appSign) {
        [parameters setObject:[BCPayCache sharedInstance].appId forKey:@"app_id"];
        [parameters setObject:[NSNumber numberWithLongLong:[timeStamp longLongValue]] forKey:@"timestamp"];
        [parameters setObject:appSign forKey:@"app_sign"];
    } else {
        if (block) {
            block(NO, @"Prepare parameters: appID and appSecret needs to be specified.",nil);
        }
        return nil;
    }
    return parameters;
}

+ (NSString *)getNowTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];//转为字符型
    return timeString;
}

+ (NSString *)getAppSignature:(NSString *)timeStamp {
    NSString *appid = [BCPayCache sharedInstance].appId;
    NSString *appsecret = [BCPayCache sharedInstance].appSecret;
    
    if (![BCUtil isValidString:appid] || ![BCUtil isValidString:appsecret])
        return nil;
    
    NSString *input = [appid stringByAppendingString:timeStamp];
    input = [input stringByAppendingString:appsecret];
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (BCPayUrlType)getUrlType:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"])
        return BCPayUrlAlipay;
    else if ([url.scheme hasPrefix:@"wx"] && [url.host isEqualToString:@"pay"])
        return BCPayUrlWeChat;
    else
        return BCPayUrlUnknown;
}

@end

void BCPayLog(NSString *format,...) {
    if ([BeeCloud getWillPrintLog]) {
        va_list list;
        va_start(list,format);
        NSLogv(format, list);
        va_end(list);
    }
}
