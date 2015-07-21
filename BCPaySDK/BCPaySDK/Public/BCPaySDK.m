//
//  BCPay.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPaySDK.h"
#import "BCWXPay.h"
#import "BCAliPay.h"
#import "BCUnionPay.h"
#import "BCPayUtil.h"
#import "WXApi.h"
#import "AlipaySDK.h"
#import "UPPayPlugin.h"

@interface BCPaySDK () {
    BOOL registerStatus;
    BCPayBlock payBlock;
}

@end

@implementation BCPaySDK

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCPaySDK *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCPaySDK alloc] init];
        instance->registerStatus = NO;
    });
    return instance;
}

+ (void)initWithAppID:(NSString *)appId andAppSecret:(NSString *)appSecret {
    BCPayCache *instance = [BCPayCache sharedInstance];
    instance.appId = appId;
    instance.appSecret = appSecret;
}

+ (BOOL)initWeChatPay:(NSString *)wxAppID {
    return [BCWXPay initWeChatPay:wxAppID];
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    if (BCPayUrlWeChat == [BCPayUtil getUrlType:url]) {
        return [BCWXPay handleOpenUrl:url];
    } else if (BCPayUrlAlipay == [BCPayUtil getUrlType:url]) {
        return [BCAliPay handleOpenUrl:url];
    }
    return NO;
}

+ (NSString *)getBCApiVersion {
    return kApiVersion;
}

+ (void)reqPayChannel:(PayChannel)channel
                title:(NSString *)title
             totalfee:(NSString *)totalfee
              traceno:(NSString *)traceno
               scheme:(NSString *)scheme
       viewController:(UIViewController *)viewController
             optional:(NSDictionary *)optional
             payBlock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:title] || [BCUtil getBytes:title] > 32) {
        if (block) block(NO, @"title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串", nil);
        return;
    } else if (![BCUtil isValidString:totalfee] || ![BCUtil isPureInt:totalfee]) {
        if (block) block(NO, @"totalfee 以分为单位，必须是只包含数值的字符串", nil);
        return;
    } else if (![BCUtil isValidString:traceno] || (![BCUtil isValidTraceNo:traceno]) || (traceno.length < 8) || (traceno.length > 32)) {
        if (block) block(NO, @"traceno 必须是长度8~32位字母和/或数字组合成的字符串", nil);
        return;
    } else if ((channel == AliPay) && ![BCUtil isValidString:scheme]) {
        if (block) block(NO, @"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用", nil);
        return;
    } else if ((channel == Union) && (viewController == nil)) {
        if (block) block(NO, @"viewController 不合法，将导致无法正常执行银联支付", nil);
        return;
    }
    
    NSString *cType = nil;
    switch (channel) {
        case WX:
            cType = @"WX_APP";
            break;
        case Ali:
            cType = @"ALI_APP";
            break;
        case Union:
            cType = @"UN_APP";
            break;
        default:
            break;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return ;
    
    parameters[@"channel"] = cType;
    parameters[@"total_fee"] = [NSNumber numberWithInteger:[totalfee integerValue]];
    parameters[@"bill_no"] = traceno;
    parameters[@"title"] = title;
    if (optional) {
        parameters[@"optional"] = optional;
    }
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager POST:[BCUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"wechat end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
             NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
             if (basicErrorMsg != nil) {
                 if (block) block(NO, basicErrorMsg, nil);
             } else {
                 NSLog(@"channel=%@,resp=%@", cType, response);
                 NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
                                             (NSDictionary *)response];
                 [dic setObject:scheme forKey:@"scheme"];
                 [dic setObject:viewController forKey:@"viewController"];
                 [BCPaySDK doPayAction:channel source:dic];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) block(NO, @"网络请求失败", error);
             [BCUtil checkRequestFail];
         }];
}

+ (void)doPayAction:(PayChannel)channel source:(NSMutableDictionary *)dic {
    if (dic) {
        switch (channel) {
            case WX:
            {
                BCPayLog(@"WeChat pay prepayid = %@", [dic objectForKey:@"prepay_id"]);
                PayReq *request = [[PayReq alloc] init];
                request.partnerId = [dic objectForKey:@"partner_id"];
                request.prepayId = [dic objectForKey:@"prepay_id"];
                request.package = [dic objectForKey:@"package"];
                request.nonceStr = [dic objectForKey:@"nonce_str"];
                NSMutableString *time = [dic objectForKey:@"timestamp"];
                request.timeStamp = time.intValue;
                request.sign = [dic objectForKey:@"pay_sign"];
                [WXApi sendReq:request];
            }
                break;
            case Ali:
            {
                BCPayLog(@"Ali Pay Start");
                NSString *orderString = [dic objectForKey:@"order_string"];
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:dic[@"scheme"]
                                            callback:^(NSDictionary *resultDic) {
                                                [BCAliPay processOrderForAliPay:resultDic];
                                            }];
            }
                break;
            case Union:
            {
                NSString *tn = [dic objectForKey:@"tn"];
                BCPayLog(@"Union Pay Start %@", dic);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UPPayPlugin startPay:tn mode:@"00" viewController:dic[@"viewController"] delegate:[BCUnionPay sharedInstance]];
                });
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark refund
+ (void)reqRefundChannel:(PayChannel)channel
                 traceno:(NSString *)traceno
                refundno:(NSString *)refundno
                  reason:(NSString *)reason
               refundfee:(NSString *)refundfee
                payBlock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:traceno] || (![BCUtil isValidTraceNo:traceno]) || (traceno.length < 8) || (traceno.length > 32)) {
        if (block) block(NO, @"traceno 必须是长度8~32位字母和/或数字组合成的字符串", nil);
        return;
    } else if (![BCPaySDK checkRefundNo:refundno]) {
        if (block) block(NO, @"refundno 格式为:退款日期(8位)+流水号(3~24位)。不可重复,且退款日期必须是当天日期(年月日)。流水号可以接受数字或英文字符,建议使用数字,但不可接受'000'", nil);
        return;
    } else if (![BCUtil isValidString:reason]) {
        if (block) block(NO, @"reason 不是合法的字符串", nil);
        return;
    } else if (![BCUtil isValidString:refundfee] || ![BCUtil isPureInt:refundfee]) {
        if (block) block(NO, @"refundfee 以分为单位，必须是只包含数值的字符串", nil);
        return;
    }
    switch (channel) {
        case WX:
            [BCWXPay reqWXRefundV3:traceno outRefundNo:refundno refundReason:reason refundFee:refundfee payBlock:block];
            break;
        case Ali:
        {
            NSString *amount = [NSString stringWithFormat:@"%.2lf", [refundfee intValue] / 100.0];
            [BCAliPay reqAliRefund:traceno refundNo:refundno refundFee:amount refundReason:reason refundBlock:block];
        }
            break;
        case Union:
            [BCUnionPay reqUnionRefund:traceno refundFee:refundfee outRefundNo:refundno refundReason:reason refundBlock:block];
            break;
        default:
            break;
    }
}

+ (BOOL)checkRefundNo:(NSString *)refundno {
    if (![BCUtil isValidString:refundno] || ![BCUtil isValidTraceNo:refundno] || (refundno.length < 8) || (refundno.length > 32)) {
        return NO;
    }
    NSString *dateString = [refundno substringWithRange:NSMakeRange(0, 8)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    return [[formatter stringFromDate:[NSDate date]] isEqualToString:dateString];
}

#pragma mark query WeChat Order from BeeCloud
+ (void)reqQueryWXRefund:(NSString *)refundno block:(BCPayBlock)block {
    if (![BCPaySDK checkRefundNo:refundno]) {
        if (block) block(NO, @"refundno 格式为:退款日期(8位)+流水号(3~24位)。不可重复,且退款日期必须是当天日期(年月日)。流水号可以接受数字或英文字符,建议使用数字,但不可接受'000'", nil);
        return;
    }
    [BCWXPay reqQueryRefund:refundno block:block];
}

+ (void)reqQueryWXPay:(NSString *)traceno queryBlock:(BCPayBlock)block {
    if (![BCUtil isValidString:traceno] || (![BCUtil isValidTraceNo:traceno]) || (traceno.length < 8) || (traceno.length > 32)) {
        if (block) block(NO, @"traceno 必须是长度8~32位字母和/或数字组合成的字符串", nil);
        return;
    }
    [BCWXPay reqQueryPayOrder:traceno queryBlock:block];
}


@end
