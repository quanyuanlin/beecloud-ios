//
//  RedPacketAdapter.m
//  BCPay
//
//  Created by Ewenlong03 on 2017/5/2.
//  Copyright © 2017年 BeeCloud. All rights reserved.
//

#import "RedPacketAdapter.h"
#import "BeeCloudAdapterProtocol.h"
#import <AlipaySDK/AlipaySDK.h>
#import <CommonCrypto/CommonDigest.h>

@implementation RedPacketAdapter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RedPacketAdapter *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[RedPacketAdapter alloc] init];
        instance.secretCacheDic = [NSMutableDictionary dictionaryWithCapacity:10];
    });
    return instance;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
         [RedPacket redpacketHandleAlipayResult:resultDic url:url];
     }];
    
    [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
         //[您的其它方法...];
         [RedPacket redpacketHandleAliAuthResult:resultDic url:url];
     }];

    return YES;
}

+ (BOOL)initRedPacket {
    
    [BCPayCache sharedInstance].redPacketAppKey = @"484bf78a04f94ab9bcee8f4302c2bdcd";
    [BCPayCache sharedInstance].redPacketAppSecret = @"b5b69209750149318c4fbe6a63d5c666";
    
    [RedPacket initRepacketSDKWithAppKey:[BCPayCache sharedInstance].redPacketAppKey URLScheme:[NSString stringWithFormat:@"rp%@", [BCPayCache sharedInstance].appId] AppSecretMethod:^NSString * _Nonnull{
        return [[RedPacketAdapter sharedInstance] getRedPacketAppSecret];
    } AlipayAuthMehtod:nil];
    
    return YES;
}


+ (void)sendPacketFrom:(nonnull UIViewController*)viewcontroller
                  Type:(RedpacketType)type
                UserID:(nonnull NSString*)userID
            OutTradeNo:(nonnull NSString*)outTradeNo
                Result:(nullable RedpacketResultBlock)block {
    
    [RedPacket sendPacketFrom:viewcontroller Type:type Receiver:userID OutTradeNo:outTradeNo Result: block];
}

+ (void)queryAvailablePacketsByUserID:(nonnull NSString*)userID
                UserNickname:(nonnull NSString*)nickname
                  UserAvatar:(nullable NSString*)avatar
                GroupIDArray:(nullable NSArray *)groupArray
                      Result:(nullable RedpacketResultBlock)block {
    [RedPacket queryAvailablePackets:YES UserID:userID UserNickname:nickname UserAvatar:avatar GroupIDArray:groupArray Result: block];
}

/**
 *
 *      为了保证secret安全:
 *      (1)请开发者将云叮当管理后台拿到secret，保存在开发者服务端;
 *      (2)由开发者服务端调用云叮当“random-secret”接口（完整地址见下面代码）,获取随机密钥，并缓存
 *      (3)开发者客户端请求开发者服务器，获得随机密钥，并缓存
 *      (4)开发者客户端将获取随机密钥的方法，传给SDK
 *
 *      注意：随机密钥具有时效性，过期需要更换
 *
 */

#pragma mark - 模拟客户端获取随机密钥的方法
- (NSString *)getRedPacketAppSecret {
    
    NSString * secretExpireStr = [self.secretCacheDic objectForKey:@"secretExpiresTime"];
    NSInteger expiredTime=secretExpireStr.integerValue;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970]*1000;
    
    //secret未过期
    if (expiredTime > currentTime)
    {
        NSString * Appsecret=[self.secretCacheDic objectForKey:@"AppSecret"];
        return Appsecret;
    }
    
    //secret过期则重新请求
    else
    {
        return [self requestForAppSecret];
    }
    
}

#pragma mark - 模拟请求云叮当获取random secret
-(NSString*)requestForAppSecret
{
    NSURL *url = [NSURL URLWithString:@"http://api.c2c.yundingdang.com/web-api/v1.0/random-secret/refresh"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    
    //设置Header
    [request addValue:@"POST" forHTTPHeaderField:@"Method"];
    [request addValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    //设置Body
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString * timeStr=[NSString stringWithFormat:@"%.0f",interval];
    NSMutableDictionary * param=[NSMutableDictionary dictionary];
    [param setObject:[BCPayCache sharedInstance].redPacketAppKey forKey:@"app_id"];
    [param setObject:[BCPayCache sharedInstance].redPacketAppSecret forKey:@"secret"];
    [param setObject:timeStr forKey:@"timestamp"];
    [param setObject:@"1.0" forKey:@"version"];
    [param setObject:@"md5" forKey:@"sign_type"];
    [param setObject:@"{}" forKey:@"biz_content"];
    [param setObject:[self MD5String:[self converDictionaryToString:param]] forKey:@"sign"];
    [param removeObjectForKey:@"secret"];
    NSString * paramStr = [self converDictionaryToString:param];
    NSData * httpBodyData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody: httpBodyData];
    
    //请求
    NSError * errorInfo = nil;
    NSData *receiveData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&errorInfo];
    
    //解析
    if (errorInfo == nil)
    {
        NSDictionary * responseDic = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
        NSData * bizData=[[responseDic objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * SecretDic=[NSJSONSerialization JSONObjectWithData:bizData options:NSJSONReadingMutableLeaves error:nil];
        NSString * AppSecretStr=[SecretDic objectForKey:@"random_secret"];
        NSNumber * expiresTime=[SecretDic objectForKey:@"expires_time"];
        
        //开发者须设置机制缓存Secret，并在超过有效期前更换token
        [self.secretCacheDic setObject:AppSecretStr forKey:@"AppSecret"];
        [self.secretCacheDic setObject:expiresTime.stringValue forKey:@"secretExpiresTime"];
        
        return AppSecretStr;
    }
    else
    {
        NSLog(@"GetSecretError===%@",errorInfo.localizedDescription);
        return @"secretError";
    }
}

-(NSString*)converDictionaryToString:(NSDictionary*)dictionary
{
    NSArray * keysASC = [[dictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString * str=[NSMutableString string];
    for (int i= 0; i<keysASC.count; i++)
    {
        NSString * key = keysASC[i];
        NSString * value = [dictionary objectForKey:key];
        
        if (i==0)
        {
            [str appendFormat:@"%@=%@",key,value];
        }
        else
        {
            [str appendFormat:@"&%@=%@",key,value];
        }
    }
    return str;
}


//MD5
- (NSString *)MD5String:(NSString *)paramStr
{
    const char *cStr = [paramStr UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr),digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

@end

