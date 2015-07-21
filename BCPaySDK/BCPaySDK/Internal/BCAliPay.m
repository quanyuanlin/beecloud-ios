//
//  BCAliPay.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/10.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCAliPay.h"
#import "AlipaySDK.h"

#pragma mark - AliPay
@interface BCAliPay () {
    BCPayBlock payBlock;
}

@end

@implementation BCAliPay

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCAliPay *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCAliPay alloc] init];
    });
    return instance;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [BCAliPay processOrderForAliPay:resultDic];
        }];
        return YES; //AliPay
    }
    return NO;
}

+ (void)reqAliPayment:(NSString *)out_trade_no
              subject:(NSString *)subject
                 body:(NSString *)body
             totalFee:(NSString *)total_fee
               scheme:(NSString *)scheme
             optional:(NSDictionary *)optional
             payBlock:(BCPayBlock)block {
    
   if (![BCUtil isValidString:out_trade_no] || ![BCUtil isValidTraceNo:out_trade_no] || (out_trade_no.length > 64)) {
        if (block) block(NO, @"out_trade_no 必须是长度不大于64字节的变长字母和/或数字字符串", nil);
        return;
    } else if (![BCUtil isValidString:subject] || [BCUtil getBytes:subject] > 256) {
        if (block) block(NO, @"subject 必须是长度不大于256个字节，最长为128个汉字的合法字符串", nil);
        return;
    } else if (![BCUtil isValidString:body] || [BCUtil getBytes:body] > 512) {
        if (block) block(NO, @"body 必须是长度不大于512个字节的合法字符串", nil);
        return;
    } else if (![BCUtil isValidString:total_fee] || ![BCUtil isPureFloat:total_fee]) {
        if (block) block(NO, @"total_fee 以元为单位，必须是合法的数值字符串", nil);
        return;
    } else if (![BCUtil isValidString:scheme]) {
        if (block) block(NO, @"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用", nil);
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return ;
    parameters[@"out_trade_no"] = out_trade_no;
    parameters[@"subject"] = subject;
    parameters[@"body"] = body;
    parameters[@"total_fee"] = total_fee;
    if (optional) {
        parameters[@"optional"] = optional;
    }
    
    [BCAliPay sharedInstance]->payBlock = block;
    
    NSMutableDictionary *paramWrapper = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager GET:[BCUtil getBestHostWithFormat:kApiPayAliPreSign] parameters:paramWrapper
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"Ali end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
             NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
             if (basicErrorMsg != nil) {
                 if (block) block(NO, basicErrorMsg, nil);
             } else {
                 NSString *orderString = [response objectForKey:@"orderString"];
                 BCPayLog(@"Ali Pay Start");
                 [[AlipaySDK defaultService] payOrder:orderString fromScheme:scheme
                                             callback:^(NSDictionary *resultDic) {
                                                 [BCAliPay processOrderForAliPay:resultDic];
                                             }];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (block) block(NO, @"网络请求失败", error);
             [BCUtil checkRequestFail];
         }];
}

+ (void)processOrderForAliPay:(NSDictionary *)resultDic {
    int status = [resultDic[@"resultStatus"] intValue];
    NSString *strMsg;
    BOOL bStatus = NO;
    switch (status) {
        case 9000:
            strMsg = @"订单支付成功";
            bStatus = YES;
            break;
        case 8000:
            strMsg = @"正在处理中";
            break;
        case 4000:
            strMsg = @"订单支付失败";
            break;
        case 6001:
            strMsg = @"用户中途取消";
            break;
        case 6002:
            strMsg = @"网络连接错误";
            break;
        default:
            break;
    }
    if ([BCAliPay sharedInstance]->payBlock) {
        [BCAliPay sharedInstance]->payBlock(bStatus, strMsg, nil);
    }
}

+ (void)reqAliRefund:(NSString *)out_trade_no
            refundNo:(NSString *)out_refund_no
           refundFee:(NSString *)refund_fee
        refundReason:(NSString *)refund_reason
         refundBlock:(BCPayBlock)block {
    
    if (![BCUtil isValidString:out_trade_no] || ![BCUtil isValidTraceNo:out_trade_no] || (out_trade_no.length > 64)) {
        if (block) block(NO, @"out_trade_no 必须是长度不大于64字节的变长字母和/或数字字符", nil);
        return;
    } else if (![BCUtil isValidString:out_refund_no] || (out_refund_no.length > 64)) {
        if (block) block(NO, @"refund_no 必须是长度不大于64字节的变长字母和/或数字字符", nil);
        return;
    } else if (![BCUtil isValidString:refund_fee] || ![BCUtil isPureFloat:refund_fee]) {
        NSLog(@"%@", refund_fee);
        if (block) block(NO, @"refund_fee 以元为单位，必须是只包含数字的字符串", nil);
        return;
    } else if (![BCUtil isValidString:refund_reason]) {
        if (block) block(NO, @"refund_reason 退款理由不能为空", nil);
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay:block];
    if (parameters == nil) return;
    parameters[@"out_trade_no"] = out_trade_no;
    parameters[@"batch_no"] = out_refund_no;
    parameters[@"refund_fee"] = refund_fee;
    parameters[@"refund_reason"] = refund_reason;
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    [manager POST:[BCUtil getBestHostWithFormat:kApiPayAliStartRefund] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              NSString *basicErrorMsg = [BCPayUtil getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
              if (basicErrorMsg != nil) {
                  if (block) block(NO, [BCAliPay descRefundMsg:basicErrorMsg], nil);
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

@end

