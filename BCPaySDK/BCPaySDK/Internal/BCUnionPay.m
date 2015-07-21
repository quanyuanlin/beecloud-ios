//
//  BCUnionPay.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/10.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCUnionPay.h"


#pragma mark - UnionPay

@implementation BCUnionPay

#pragma mark - unionPay

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCUnionPay *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCUnionPay alloc] init];
    });
    return instance;
}

+ (void)reqUnionPayment:(NSString *)body
             outTradeNo:(NSString *)out_trade_no
               totalFee:(NSString *)total_fee
         viewController:(UIViewController *)viewController
               optional:(NSDictionary *)optional
               payblock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:body] || [BCUtil getBytes:body] > 32) {
        if (block) block(NO, @"body 必须是长度不大于32个字节的字符串", nil);
        return;
    } else if (![BCUtil isValidString:out_trade_no] || ![BCUtil isValidTraceNo:out_trade_no] || (out_trade_no.length < 8 || out_trade_no.length > 40)) {
        if (block) block(NO, @"out_trade_no 必须是8~40字节的变长字母和/或数字字符", nil);
        return;
    } else if (![BCUtil isValidString:total_fee] || ![BCUtil isPureInt:total_fee]) {
        if (block) block(NO, @"totalFee 以分为单位，必须是只包含数字的字符串", nil);
        return;
    }
    
    BCUnionPay *instance = [BCUnionPay sharedInstance];
    instance->payBlock = block;
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return ;
    
    parameters[@"orderDesc"] = body;
    parameters[@"txnAmt"] = total_fee;
    parameters[@"orderId"] = out_trade_no;
    parameters[@"traceId"] = @"BCTest";
    if (optional) {
        parameters[@"optional"] = optional;
    }
    
    NSMutableDictionary *paramWrapper = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager GET:[BCUtil getBestHostWithFormat:kApiPayUnionPayGetTN] parameters:paramWrapper
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"unionPay end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
             NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
             if (basicErrorMsg != nil) {
                 if (block) block(NO, basicErrorMsg, nil);
             } else {
                 NSString *tn = [response objectForKey:@"tn"];
                 BCPayLog(@"Union Pay Start %@", response);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [UPPayPlugin startPay:tn mode:@"00" viewController:viewController delegate:[BCUnionPay sharedInstance]];
                 });
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) block(NO, @"网络请求失败", error);
             [BCUtil checkRequestFail];
         }];
}

+ (void)reqUnionRefund:(NSString *)out_trade_no
             refundFee:(NSString *)refund_fee
           outRefundNo:(NSString *)out_refund_no
          refundReason:(NSString *)refund_reason
           refundBlock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:out_trade_no] || ![BCUtil isValidTraceNo:out_trade_no] || (out_trade_no.length < 8) || (out_trade_no.length > 40)) {
        if (block) block(NO, @"out_trade_no 必须是8~40字节的变长字母和/或数字字符", nil);
        return;
    } else if (![BCUtil isValidString:refund_fee] || ![BCUtil isPureInt:refund_fee]) {
        if (block) block(NO, @"refund_fee 以分为单位，必须是只包含数字的字符串", nil);
        return;
    } else if (![BCUtil isValidString:out_refund_no] || ![BCUtil isValidTraceNo:out_refund_no] || (out_refund_no.length < 8 || out_refund_no.length > 40)) {
        if (block) block(NO, @"out_refund_no 必须是8~40字节的变长字母和/或数字字符", nil);
        return;
    } else if (![BCUtil isValidString:@"refund_reason"]) {
        if (block) block(NO, @"refund_reason 不是合法的字符串", nil);
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return ;
    parameters[@"orderId"] = out_trade_no;
    parameters[@"out_refund_no"] = out_refund_no;
    parameters[@"refund_fee"] = refund_fee;
    parameters[@"refund_reason"] = refund_reason;
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    [manager POST:[BCUtil getBestHostWithFormat:kApiPayUnionPayRefund] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
              if (basicErrorMsg != nil) {
                  if (block) block(NO, [BCUnionPay descRefundMsg:basicErrorMsg], nil);
              } else {
                  if (block) block(YES, @"退款订单已经生成，等待商家处理", nil);
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

- (void)UPPayPluginResult:(NSString *)result {
    BOOL status = NO;
    if ([result isEqualToString:@"success"]) status = YES;
    
    if ([BCUnionPay sharedInstance]->payBlock) {
        [BCUnionPay sharedInstance]->payBlock(status, result, nil);
    }
}

@end

