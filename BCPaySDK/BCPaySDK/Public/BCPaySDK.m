//
//  BCPay.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPaySDK.h"

#import "BCPayUtil.h"
#import "WXApi.h"
#import "AlipaySDK.h"
#import "UPPayPlugin.h"

@interface BCPaySDK ()<WXApiDelegate, UPPayPluginDelegate> {
    BOOL registerStatus;
}
@property (nonatomic, weak) id<BCApiDelegate> deleagte;

- (void)reqPay:(BCPayReq *)req;
- (void)reqQueryOrder:(BCQueryReq *)req;
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
    BCPaySDK *instance = [BCPaySDK sharedInstance];
    instance->registerStatus =  [WXApi registerApp:wxAppID];
    return instance->registerStatus;
}

+ (BOOL)handleOpenUrl:(NSURL *)url delegate:(id<BCApiDelegate>)delegate {
    BCPaySDK *instance = [BCPaySDK sharedInstance];
    instance.deleagte = delegate;
    if (BCPayUrlWeChat == [BCPayUtil getUrlType:url]) {
        return [WXApi handleOpenURL:url delegate:instance];
    } else if (BCPayUrlAlipay == [BCPayUtil getUrlType:url]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [instance processOrderForAliPay:resultDic];
        }];
        return YES; //AliPay
    }
    return NO;
}

+ (NSString *)getBCApiVersion {
    return kApiVersion;
}

+ (void)setWillPrintLog:(BOOL)flag {
    [BCPayCache sharedInstance].willPrintLogMsg = flag;
}

- (NSString *)getChannelString:(PayChannel)channel {
    NSString *cType = @"";
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
    return cType;
}

+ (BOOL)sendBCReq:(BCBaseReq *)req {
    if (req.type == 1) {
        [[BCPaySDK sharedInstance] reqPay:(BCPayReq *)req];
    } else if (req.type == 2 ) {
        [[BCPaySDK sharedInstance] reqQueryOrder:(BCQueryReq *)req];
    } else if (req.type == 3) {
        [[BCPaySDK sharedInstance] reqQueryOrder:(BCQRefundReq *)req];
    }
    return YES;
}

- (void)reqPay:(BCPayReq *)req {
    if (![[BCPaySDK sharedInstance] checkParameters:req]) return;
    
    NSString *cType = [self getChannelString:req.channel];
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    
    parameters[@"channel"] = cType;
    parameters[@"total_fee"] = [NSNumber numberWithInteger:[req.totalfee integerValue]];
    parameters[@"bill_no"] = req.billno;
    parameters[@"title"] = req.title;
    if (req.optional) {
        parameters[@"optional"] = req.optional;
    }
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              BCPayLog(@"wechat end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
              BCBaseResp *resp = [self getErrorInResponse:response];
              if (resp.result_code != 0) {
                  if (_deleagte && [_deleagte respondsToSelector:@selector(doBCResp:)]) {
                      [_deleagte doBCResp:resp];
                  }
              } else {
                  NSLog(@"channel=%@,resp=%@", cType, response);
                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
                                              (NSDictionary *)response];
                  [dic setObject:req.scheme forKey:@"scheme"];
                  [dic setObject:req.viewController forKey:@"viewController"];
                  [self doPayAction:req.channel source:dic];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self doErrorResponse:kNetWorkError];
          }];
}

- (void)reqQueryOrder:(BCQueryReq *)req {
    if (req == nil) {
        [self doErrorResponse:@"请求结构体不合法"];
        return;
    }
    
    NSString *cType = [[BCPaySDK sharedInstance] getChannelString:req.channel];
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    NSString *reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryBills];
    
    if ([BCUtil isValidString:req.billno]) {
        parameters[@"bill_no"] = req.billno;
    }
    if ([BCUtil isValidString:req.starttime]) {
        parameters[@"start_time"] = [BCUtil getTimeStampFromString:req.starttime];
    }
    if ([BCUtil isValidString:req.endtime]) {
        parameters[@"end_time"] = [BCUtil getTimeStampFromString:req.endtime];
    }
    if (req.type == 3) {
        BCQRefundReq *refundReq = (BCQRefundReq *)req;
        if ([BCUtil isValidString:refundReq.refundno]) {
            parameters[@"refund_no"] = refundReq.refundno;
        }
        reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryRefunds];
    }
    parameters[@"channel"] = [[cType componentsSeparatedByString:@"_"] firstObject];
    parameters[@"skip"] = [NSNumber numberWithInteger:req.skip];
    parameters[@"limit"] = [NSNumber numberWithInteger:req.limit];
    
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    __block NSTimeInterval tStart = [NSDate timeIntervalSinceReferenceDate];
    
    [manager GET:reqUrl parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"query end time = %f", [NSDate timeIntervalSinceReferenceDate] - tStart);
             NSLog(@"channel=%@, resp=%@", cType, response);
             NSDictionary *dic = (NSDictionary *)response;
             BCQueryResp *resp = [[BCQueryResp alloc] init];
             resp.result_code = [dic[kKeyResponseResultCode] intValue];
             resp.result_msg = dic[kKeyResponseResultMsg];
             resp.err_detail = dic[kKeyResponseErrDetail];
             resp.count = [[dic objectForKey:@"count"] integerValue];
             if (req.type == 2) {
                 resp.results = [dic objectForKey:@"bills"];
             } else if (req.type == 3) {
                 resp.results = [dic objectForKey:@"refunds"];
             }
             if (_deleagte && [_deleagte respondsToSelector:@selector(doBCResp:)]) {
                 [_deleagte doBCResp:resp];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self doErrorResponse:kNetWorkError];
         }];
}

- (void)doErrorResponse:(NSString *)errMsg {
    BCBaseResp *resp = [[BCBaseResp alloc] init];
    resp.result_code = BCErrCodeCommon;
    resp.err_detail = errMsg;
    if (_deleagte && [_deleagte respondsToSelector:@selector(doBCResp:)]) {
        [_deleagte doBCResp:resp];
    }
}

- (BCBaseResp *)getErrorInResponse:(id)response {
    NSDictionary *dic = (NSDictionary *)response;
    BCBaseResp *resp = [[BCBaseResp alloc] init];
    resp.result_code = [dic[kKeyResponseResultCode] intValue];
    resp.result_msg = dic[kKeyResponseResultMsg];
    resp.err_detail = dic[kKeyResponseErrDetail];
    return resp;
}

- (BOOL)checkParameters:(BCBaseReq *)request {
    if (request.type == 1) {
        BCPayReq *req = (BCPayReq *)request;
        if (![BCUtil isValidString:req.title] || [BCUtil getBytes:req.title] > 32) {
            [self doErrorResponse:@"title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串"];
            return NO;
        } else if (![BCUtil isValidString:req.totalfee] || ![BCUtil isPureInt:req.totalfee]) {
            [self doErrorResponse:@"totalfee 以分为单位，必须是只包含数值的字符串"];
            return NO;
        } else if (![BCUtil isValidString:req.billno] || (![BCUtil isValidTraceNo:req.billno]) || (req.billno.length < 8) || (req.billno.length > 32)) {
            [self doErrorResponse:@"billno 必须是长度8~32位字母和/或数字组合成的字符串"];
            return NO;
        } else if ((req.channel == Ali) && ![BCUtil isValidString:req.scheme]) {
            [self doErrorResponse:@"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用"];
            return NO;
        } else if ((req.channel == Union) && (req.viewController == nil)) {
            [self doErrorResponse:@"viewController 不合法，将导致无法正常执行银联支付"];
            return NO;
        }
    }
    return YES ;
}

#pragma mark WXPay
- (void)doWXPay:(NSMutableDictionary *)dic {
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

#pragma mark AliPay
- (void)doAliPay:(NSMutableDictionary *)dic {
    BCPayLog(@"Ali Pay Start");
    NSString *orderString = [dic objectForKey:@"order_string"];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:dic[@"scheme"]
                                callback:^(NSDictionary *resultDic) {
                                    [self processOrderForAliPay:resultDic];
                                }];
}

#pragma mark UnionPay

- (void)doUnionPay:(NSMutableDictionary *)dic {
    NSString *tn = [dic objectForKey:@"tn"];
    BCPayLog(@"Union Pay Start %@", dic);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UPPayPlugin startPay:tn mode:@"00" viewController:dic[@"viewController"] delegate:[BCPaySDK sharedInstance]];
    });
}

#pragma mark do pay
- (void)doPayAction:(PayChannel)channel source:(NSMutableDictionary *)dic {
    if (dic) {
        switch (channel) {
            case WX:
                [self doWXPay:dic];
                break;
            case Ali:
                [self doAliPay:dic];
                break;
            case Union:
                [self doUnionPay:dic];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Implementation WXApiDelegate
/** @name  WxApiDelegate_onResp*/

- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *tempResp = (PayResp *)resp;
        NSString *strMsg = nil;
        int errcode = 0;
        switch (tempResp.errCode) {
            case WXSuccess:
                strMsg = @"支付成功";
                errcode = BCSuccess;
                break;
            case WXErrCodeUserCancel:
                strMsg = @"支付取消";
                errcode = BCErrCodeUserCancel;
                break;
            default:
                strMsg = @"支付失败";
                errcode = BCErrCodeSentFail;
                break;
        }
        NSString *result = [BCUtil isValidString:tempResp.errStr]?[NSString stringWithFormat:@"%@,%@",strMsg,tempResp.errStr]:strMsg;
        BCBaseResp *resp = [[BCBaseResp alloc] init];
        resp.result_code = errcode;
        resp.result_msg = result;
        if (_deleagte && [_deleagte respondsToSelector:@selector(doBCResp:)]) {
            [_deleagte doBCResp:resp];
        }
    }
}

#pragma mark - Implementation AliPayDelegate
/** @name  AliPayDelegate*/

- (void)processOrderForAliPay:(NSDictionary *)resultDic {
    int status = [resultDic[@"resultStatus"] intValue];
    NSString *strMsg;
    int errcode = 0;
    switch (status) {
        case 9000:
            strMsg = @"支付成功";
            errcode = BCSuccess;
            break;
        case 4000:
        case 6002:
            strMsg = @"支付失败";
            errcode = BCErrCodeSentFail;
            break;
        case 6001:
            strMsg = @"支付取消";
            errcode = BCErrCodeUserCancel;
            break;
        default:
            strMsg = @"未知错误";
            errcode = BCErrCodeUnsupport;
            break;
    }
    BCPayResp *resp = [[BCPayResp alloc] init];
    resp.result_code = errcode;
    resp.result_msg = strMsg;
    resp.paySource = resultDic;
    if (_deleagte && [_deleagte respondsToSelector:@selector(doBCResp:)]) {
        [_deleagte doBCResp:resp];
    }
}

#pragma mark - Implementation UnionPayDelegate
/** @name  UnionPayDelegate*/

- (void)UPPayPluginResult:(NSString *)result {
    int errcode = BCErrCodeSentFail;
    NSString *strMsg = @"支付失败";
    if ([result isEqualToString:@"success"]) {
        errcode = BCSuccess;
        strMsg = @"支付成功";
    } else if ([result isEqualToString:@"cancel"]) {
        errcode = BCErrCodeUserCancel;
        strMsg = @"支付取消";
    }
    
    BCBaseResp *resp = [[BCBaseResp alloc] init];
    resp.result_code = errcode;
    resp.result_msg = strMsg;
    if (_deleagte && [_deleagte respondsToSelector:@selector(doBCResp:)]) {
        [_deleagte doBCResp:resp];
    }
}

@end
