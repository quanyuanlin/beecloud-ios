//
//  BCWXPay.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/10.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCWXPay.h"
#import "WXApi.h"

#pragma mark - WechatPay

@interface BCWXPay ()<WXApiDelegate>
{
    BCPayBlock payBlock;
    BOOL registerStatus;
}
@end

@implementation BCWXPay

#pragma mark - WXPay functions
/** @name WeChatPay Functions*/

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCWXPay *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCWXPay alloc] init];
        instance->registerStatus = NO;
    });
    return instance;
}

/**
 *  WXApi的成员函数，向微信终端程序注册第三方应用。
 */
+ (BOOL)initWeChatPay:(NSString *)wxAppID {
    BCWXPay *instance = [BCWXPay sharedInstance];
    instance->registerStatus =  [WXApi registerApp:wxAppID];
    return instance->registerStatus;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[BCWXPay sharedInstance]];
}

#pragma mark WeChat Pay
+ (void)reqWXPayV3:(NSString *)body
          totalFee:(NSString *)totalFee
        outTradeNo:(NSString *)outTradeNo
          optional:(NSDictionary *)optional
          payBlock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:body] || [BCUtil getBytes:body] > 32) {
        if (block) block(NO, @"body 必须是长度不大于32个字节的合法字符串", nil);
        return;
    } else if (![BCUtil isValidString:totalFee] || ![BCUtil isPureInt:totalFee]) {
        if (block) block(NO, @"totalFee 以分为单位，必须是只包含数字的字符串", nil);
        return;
    } else if (![BCUtil isValidString:outTradeNo] || (![BCUtil isValidTraceNo:outTradeNo]) || (outTradeNo.length > 32)) {
        if (block) block(NO, @"outTradeNo 必须是长度不大于32个字节且只包含字母与数字的字符串", nil);
        return;
    }
    
    BCWXPay *instance = [BCWXPay sharedInstance];
    instance->payBlock = block;
    
    if (!instance->registerStatus) {
        if (block) {
            block(NO, @"微信注册应用失败,请检查是否已经初始化微信支付", nil);
        }
        return;
    }
    
    if (![WXApi isWXAppInstalled]) {
        if (block) {
            block(NO, @"您尚未安装微信客户端", nil);
        }
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return ;
    
    parameters[@"body"] = body;
    parameters[@"total_fee"] = totalFee;
    parameters[@"out_trade_no"] = outTradeNo;
    parameters[@"trade_type"] = @"APP";
    if (optional) {
        parameters[@"optional"] = optional;
    }
    
    NSMutableDictionary *paramWrapper = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager GET:[BCUtil getBestHostWithFormat:kApiPayWeChatNewPrepare] parameters:paramWrapper
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"wechat end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
             NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
             if (basicErrorMsg != nil) {
                 if (block) block(NO, basicErrorMsg, nil);
             } else {
                 NSMutableDictionary * dic = response;
                 BCPayLog(@"WeChat pay prepayid = %@", [dic objectForKey:@"prepayid"]);
                 PayReq *request = [[PayReq alloc] init];
                 request.partnerId = [dic objectForKey:@"partnerid"];
                 request.prepayId = [dic objectForKey:@"prepayid"];
                 request.package = [dic objectForKey:@"package"];
                 request.nonceStr = [dic objectForKey:@"noncestr"];
                 NSMutableString *time = [dic objectForKey:@"timestamp"];
                 request.timeStamp = time.intValue;
                 request.sign = [dic objectForKey:@"paySign"];
                 [WXApi sendReq:request];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) block(NO, @"网络请求失败", error);
             [BCUtil checkRequestFail];
         }];
}

#pragma mark WeChat Refund V3

+ (void)reqWXRefundV3:(NSString *)outTradeNo
          outRefundNo:(NSString *)outRefundNo
         refundReason:(NSString *)refundReason
            refundFee:(NSString *)refundFee
             payBlock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:outTradeNo] || (![BCUtil isValidTraceNo:outTradeNo]) || (outTradeNo.length > 32)) {
        if (block) block(NO, @"outTradeNo 必须是长度不大于32位且只包含字母与数字的合法字符串", nil);
        return;
    } else if (![BCUtil isValidString:outRefundNo] || (![BCUtil isValidTraceNo:outRefundNo]) || (outRefundNo.length > 32)) {
        if (block) block(NO, @"outRefundNo 必须是长度不大于32位且只包含字母与数字的字符串", nil);
        return;
    } else if (![BCUtil isValidString:refundFee] || ![BCUtil isPureInt:refundFee]) {
        if (block) block(NO, @"refundFee 以分为单位，必须是只包含数字的字符串", nil);
        return;
    }  else if (![BCUtil isValidString:refundReason]) {
        if (block) block(NO, @"refundReason 不是合法的字符串", nil);
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return;
    parameters[@"out_trade_no"] = outTradeNo;
    parameters[@"out_refund_no"] = outRefundNo;
    parameters[@"refundReason"] = refundReason;
    parameters[@"refundAmount"] = refundFee;
    parameters[@"trade_type"] = @"2";//代表APP
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    [manager POST:[BCUtil getBestHostWithFormat:kApiPayWeChatNewStartRefund] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
              if (basicErrorMsg != nil) {
                  if (block) block(NO,[BCWXPay descRefundMsg:basicErrorMsg], nil);
              } else {
                  if (block) block(YES, @"退款订单已生成,等待商家处理", nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (block) block(NO, @"网络请求失败", error);
              [BCUtil checkRequestFail];
          }];
}

+ (NSString *)descRefundMsg:(NSString *)refundMsg {
    NSString *strMsg = @"";
    if (![BCUtil isValidString:refundMsg]) return strMsg;
    
    if ([refundMsg isEqualToString:@"ALREADY_REFUNDING"]) {
        strMsg = @"该订单正在退款中";
    } else if ([refundMsg isEqualToString:@"ALREADY_AGREE"]) {
        strMsg = @"该退款申请商家已经确认";
    } else if ([refundMsg hasPrefix:@"REFUND_AMOUNT_TOO_LARGE"]) {
        NSArray *strArray = [refundMsg componentsSeparatedByString:@":"];
        strMsg = [NSString stringWithFormat:@"退款额度不足,可退款金额为:%@",strArray[1]];
    } else if ([refundMsg isEqualToString:@"NO_SUCH_BILL"]) {
        strMsg = @"未找到该订单";
    } else if ([refundMsg isEqualToString:@"NO_SUCH_BILL"] ||
               [refundMsg isEqualToString:@"EMPTY_TRANSACTION_ID"]) {
        strMsg = @"未找到该订单";
    } else if ([refundMsg isEqualToString:@"REFUND_EXCEED_TIME"]) {
        strMsg = @"支付交易和退款之间时间差超过6个月";
    } else {
        strMsg = refundMsg;
    }
    return strMsg;
}

#pragma mark Query Refund Order

+ (void)reqQueryRefund:(NSString *)out_refund_no block:(BCPayBlock)block {
    if (![BCUtil isValidString:out_refund_no] ||
        ![BCUtil isValidTraceNo:out_refund_no] ||
        (out_refund_no.length > 32)) {
        if (block) block(NO, @"out_refund_no 参数不合法", nil);
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return;
    parameters[@"out_refund_no"] = out_refund_no;
    parameters[@"trade_type"] = @"2";
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    [manager POST:[BCUtil getBestHostWithFormat:kApiPayWeChatNewQueryRefund] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
              if (basicErrorMsg != nil) {
                  if (block) block(NO, basicErrorMsg, nil);
              } else {
                  NSNumber *statusNum = [response objectForKey:@"status"];
                  if (block) block(YES, [BCWXPay getRefundStatusByCode:[statusNum intValue]], nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (block) block(NO, @"网络请求失败", error);
              [BCUtil checkRequestFail];
          }];
}

+ (NSString *)getRefundStatusByCode:(NSInteger)statusCode {
    NSString *statusMsg = @"";
    switch (statusCode) {
        case 3:
            statusMsg = @"退款成功";
            break;
        case 4:
            statusMsg = @"退款被渠道拒绝";
            break;
        case 7:
            statusMsg = @"未确定，需要商户原退款单号重新发起";
            break;
        case 9:
            statusMsg = @"退款处理中";
            break;
        default:
            statusMsg = @"退款失败";
            break;
    }
    return statusMsg;
}

#pragma mark Query WeChatPay Order

+ (void)reqQueryPayOrder:(NSString *)outTradeNo queryBlock:(BCPayBlock)block {
    if (![BCUtil isValidString:outTradeNo] ||
        ![BCUtil isValidTraceNo:outTradeNo] ||
        (outTradeNo.length > 32)) {
        if (block) block(NO, @"outTradeNo 必须是长度不大于32位且只包含字母与数字的合法字符串", nil);
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return;
    parameters[@"out_trade_no"] = outTradeNo;
    parameters[@"trade_type"] = @"2";
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    [manager POST:[BCUtil getBestHostWithFormat:kApiPayWeChatNewQueryOrder] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
              if (basicErrorMsg != nil) {
                  if (block) block(NO, [BCWXPay parseTradeState:basicErrorMsg], nil);
              } else {
                  NSString *state = [response objectForKey:@"trade_state"];
                  if (block) block(YES, [BCWXPay parseTradeState:state], nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (block) block(NO, @"网络请求失败", error);
              [BCUtil checkRequestFail];
          }];
}

+ (NSString *)parseTradeState:(NSString *)state {
    NSString *cString = nil;
    if (![BCUtil isValidString:state]) return cString;
    NSArray *array = [state componentsSeparatedByString:@":"];
    if (array) {
        NSString *tempString = [array lastObject];
        if ([tempString isEqualToString:@"SUCCESS"]) {
            cString = @"支付成功";
        } else if ([tempString isEqualToString:@"REFUND"]) {
            cString = @"转入退款";
        } else if ([tempString isEqualToString:@"NOTPAY"]) {
            cString = @"未支付";
        } else if ([tempString isEqualToString:@"CLOSED"]) {
            cString = @"已关闭";
        } else if ([tempString isEqualToString:@"REVOKED"]) {
            cString = @"已撤销";
        } else if ([tempString isEqualToString:@"USERPAYING"]) {
            cString = @"用户支付中";
        } else if ([tempString isEqualToString:@"PAYERROR"]) {
            cString = @"支付失败(其他原因，如银行返回失败)";
        } else {
            cString = tempString;
        }
    }
    return cString;
}


#pragma mark - Implementation WXApiDelegate
/** @name  WxApiDelegate_onResp*/

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *tempResp = (PayResp *)resp;
        NSString *strMsg = nil;
        BOOL status = NO;
        switch (tempResp.errCode) {
            case WXSuccess:
                strMsg = @"支付成功";
                status = YES;
                break;
            case WXErrCodeUserCancel:
                strMsg = @"用户取消";
                break;
            default:
                strMsg = @"支付失败";
                break;
        }
        NSString *result = [BCUtil isValidString:tempResp.errStr]?[NSString stringWithFormat:@"%@,%@",strMsg,tempResp.errStr]:strMsg;
        if ([BCWXPay sharedInstance]->payBlock) {
            [BCWXPay sharedInstance]->payBlock(status, result, nil);
        }
    }
}

@end
