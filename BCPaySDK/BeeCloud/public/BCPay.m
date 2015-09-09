//
//  BCPay.m
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPay.h"

#import "BCPayUtil.h"
#import "WXApi.h"
#import "AlipaySDK.h"
#import "UPPayPlugin.h"

@interface BCPay ()<WXApiDelegate, UPPayPluginDelegate>

@property (nonatomic, assign) BOOL registerStatus;
@property (nonatomic, weak) id<BCApiDelegate> deleagte;

@end


@implementation BCPay

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCPay *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCPay alloc] init];
        instance.registerStatus = NO;
    });
    return instance;
}

+ (void)initWithAppID:(NSString *)appId andAppSecret:(NSString *)appSecret {
    BCPayCache *instance = [BCPayCache sharedInstance];
    instance.appId = appId;
    instance.appSecret = appSecret;
}

+ (BOOL)initWeChatPay:(NSString *)wxAppID {
    BCPay *instance = [BCPay sharedInstance];
    instance.registerStatus =  [WXApi registerApp:wxAppID];
    return instance.registerStatus;
}

+ (void)initPayPal:(NSString *)clientID secret:(NSString *)secret sanBox:(BOOL)isSandBox {
    if(clientID.isValid && secret.isValid) {
        BCPayCache *instance = [BCPayCache sharedInstance];
        instance.payPalClientID = clientID;
        instance.payPalSecret = secret;
        instance.isPayPalSandBox = isSandBox;
        
        if (isSandBox) {
            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_PRODUCTION_CLIENT_ID",
                                                                   PayPalEnvironmentSandbox : clientID}];
             [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
        } else {
            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : clientID,
                                                                   PayPalEnvironmentSandbox : @"YOUR_SANDBOX_CLIENT_ID"}];
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
        }
       
    }
}

+ (void)setBCApiDelegate:(id<BCApiDelegate>)delegate {
    [BCPay sharedInstance].deleagte = delegate;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    BCPay *instance = [BCPay sharedInstance];
    
    if (BCPayUrlWeChat == [BCPayUtil getUrlType:url]) {
        return [WXApi handleOpenURL:url delegate:instance];
    } else if (BCPayUrlAlipay == [BCPayUtil getUrlType:url]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [instance processOrderForAliPay:resultDic];
        }];
        return YES;
    }
    return NO;
}

+ (NSString *)getBCApiVersion {
    return kApiVersion;
}

+ (void)setWillPrintLog:(BOOL)flag {
    [BCPayCache sharedInstance].willPrintLogMsg = flag;
}

+ (void)setNetworkTimeout:(NSTimeInterval)time {
    [BCPayCache sharedInstance].networkTimeout = time;
}

+ (void)sendBCReq:(BCBaseReq *)req {
    BCPay *instance = [BCPay sharedInstance];
    switch (req.type) {
        case BCObjsTypePayReq:
            [instance reqPay:(BCPayReq *)req];
            break;
        case BCObjsTypeQueryReq:
            [instance reqQueryOrder:(BCQueryReq *)req];
            break;
        case BCObjsTypeQueryRefundReq:
            [instance reqQueryOrder:(BCQueryRefundReq *)req];
            break;
        case BCObjsTypeRefundStatusReq:
            [instance reqRefundStatus:(BCRefundStatusReq *)req];
            break;
        case BCObjsTypePayPal:
            [instance  reqPayPal:(BCPayPalReq *)req];
            break;
        case BCObjsTypePayPalVerify:
            [instance reqPayPalVerify:(BCPayPalVerifyReq *)req];
            break;
        default:
            break;
    }
}

#pragma mark private class functions

#pragma mark Pay Request

- (void)reqPay:(BCPayReq *)req {
    if (![[BCPay sharedInstance] checkParameters:req]) return;
    
    NSString *cType = [BCPayUtil getChannelString:req.channel];
    
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
    
    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
           
              BCBaseResp *resp = [self getErrorInResponse:response];
              if (resp.result_code != 0) {
                  if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
                      [_deleagte onBCPayResp:resp];
                  }
              } else {
                  BCPayLog(@"channel=%@,resp=%@", cType, response);
                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
                                              (NSDictionary *)response];
                  if (req.channel == PayChannelAliApp) {
                     [dic setObject:req.scheme forKey:@"scheme"];
                  } else if (req.channel == PayChannelUnApp) {
                     [dic setObject:req.viewController forKey:@"viewController"];
                  }
                  [self doPayAction:req.channel source:dic];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self doErrorResponse:kNetWorkError];
          }];
}

#pragma mark - Pay Action

- (void)doPayAction:(PayChannel)channel source:(NSMutableDictionary *)dic {
    if (dic) {
        switch (channel) {
            case PayChannelWxApp:
                [self doWXPay:dic];
                break;
            case PayChannelAliApp:
                [self doAliPay:dic];
                break;
            case PayChannelUnApp:
                [self doUnionPay:dic];
                break;
            default:
                break;
        }
    }
}

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

- (void)doAliPay:(NSMutableDictionary *)dic {
    BCPayLog(@"Ali Pay Start");
    NSString *orderString = [dic objectForKey:@"order_string"];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:dic[@"scheme"]
                                callback:^(NSDictionary *resultDic) {
                                    [self processOrderForAliPay:resultDic];
                                }];
}

- (void)doUnionPay:(NSMutableDictionary *)dic {
    NSString *tn = [dic objectForKey:@"tn"];
    BCPayLog(@"Union Pay Start %@", dic);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UPPayPlugin startPay:tn mode:@"00" viewController:dic[@"viewController"] delegate:[BCPay sharedInstance]];
    });
}

#pragma mark PayPal

- (void)reqPayPal:(BCPayPalReq *)req {
    
    if (![self checkParameters:req]) return;
    
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:req.items];
    
    // Optional: include payment details
    NSDecimalNumber *dShipping = [[NSDecimalNumber alloc] initWithString:req.shipping];
    NSDecimalNumber *dTax = [[NSDecimalNumber alloc] initWithString:req.tax];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:dShipping
                                                                                    withTax:dTax];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:dShipping] decimalNumberByAdding:dTax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = ((PayPalItem *)req.items.lastObject).currency;
    payment.shortDescription = req.shortDesc;
    payment.items = req.items;
    payment.paymentDetails = paymentDetails;
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:req.payConfig
                                                                                                     delegate:req.viewController];
    [(UIViewController *)req.viewController presentViewController:paymentViewController animated:YES completion:nil];
    
}

- (void)reqPayPalVerify:(BCPayPalVerifyReq *)req {
    [self reqPayPalAccessToken:req];
}

- (void)reqPayPalAccessToken:(BCPayPalVerifyReq *)req {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = NO;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:[BCPayCache sharedInstance].payPalClientID password:[BCPayCache sharedInstance].payPalSecret];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:@"client_credentials" forKey:@"grant_type"];
    
    [manager POST:[BCPayCache sharedInstance].isPayPalSandBox?kPayPalAccessTokenSandBox:kPayPalAccessTokenProduction parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
        BCPayLog(@"token %@", response);
        NSDictionary *dic = (NSDictionary *)response;
        [self doPayPalVerify:req accessToken:[NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"token_type"],[dic objectForKey:@"access_token"]]];
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self doErrorResponse:kNetWorkError];
    }];
}

- (void)doPayPalVerify:(BCPayPalVerifyReq *)req accessToken:(NSString *)accessToken {
    
    if (req == nil || req.payment == nil) {
        [self doErrorResponse:@"请求参数格式不合法"];
        return ;
    }
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    if ([BCPayCache sharedInstance].isPayPalSandBox) {
        parameters[@"channel"] = @"PAYPAL_SANDBOX";
    } else {
        parameters[@"channel"] = @"PAYPAL";
    }
    parameters[@"title"] = @"PayPal Verify Payment";
    parameters[@"total_fee"] = @((int)([req.payment.amount floatValue] * 100));
    parameters[@"currency"] = req.payment.currencyCode;
    parameters[@"bill_no"] = [[req.payment.confirmation[@"response"] objectForKey:@"id"] stringByReplacingOccurrencesOfString:@"PAY-" withString:@""];
    parameters[@"access_token"] = accessToken;
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
              BCBaseResp *resp = [self getErrorInResponse:response];
              if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
                  [_deleagte onBCPayResp:resp];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self doErrorResponse:kNetWorkError];
          }];
}

#pragma mark Query Bills/Refunds

- (void)reqQueryOrder:(BCQueryReq *)req {
    if (req == nil) {
        [self doErrorResponse:@"请求结构体不合法"];
        return;
    }
    
    NSString *cType = [BCPayUtil getChannelString:req.channel];
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    NSString *reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryBills];
    
    if (req.billno.isValid) {
        parameters[@"bill_no"] = req.billno;
    }
    if (req.starttime.isValid) {
        parameters[@"start_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.starttime]];
    }
    if (req.endtime.isValid) {
        parameters[@"end_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.endtime]];
    }
    if (req.type == BCObjsTypeQueryRefundReq) {
        BCQueryRefundReq *refundReq = (BCQueryRefundReq *)req;
        if (refundReq.refundno.isValid) {
            parameters[@"refund_no"] = refundReq.refundno;
        }
        reqUrl = [BCPayUtil getBestHostWithFormat:kRestApiQueryRefunds];
    }
    if (cType.isValid) {
        parameters[@"channel"] = cType;
    }
    parameters[@"skip"] = [NSNumber numberWithInteger:req.skip];
    parameters[@"limit"] = [NSNumber numberWithInteger:req.limit];
    
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    [manager GET:reqUrl parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"resp = %@", response);
             [self doQueryResponse:(NSDictionary *)response];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self doErrorResponse:kNetWorkError];
         }];
}

- (void)doQueryResponse:(NSDictionary *)dic {
    BCQueryResp *resp = [[BCQueryResp alloc] init];
    resp.result_code = [dic[kKeyResponseResultCode] intValue];
    resp.result_msg = dic[kKeyResponseResultMsg];
    resp.err_detail = dic[kKeyResponseErrDetail];
    resp.count = [[dic objectForKey:@"count"] integerValue];
    resp.results = [self parseResults:dic];
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
    }
}

- (NSMutableArray *)parseResults:(NSDictionary *)dic {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    if ([[dic allKeys] containsObject:@"bills"]) {
        for (NSDictionary *result in [dic objectForKey:@"bills"]) {
            [array addObject:[self parseQueryResult:result]];
        } ;
    } else if ([[dic allKeys] containsObject:@"refunds"]) {
        for (NSDictionary *result in [dic objectForKey:@"refunds"]) {
            [array addObject:[self parseQueryResult:result]];
        } ;
    }
    return array;
}

- (BCBaseResult *)parseQueryResult:(NSDictionary *)dic {
    if (dic) {
        if ([[dic allKeys] containsObject:@"spay_result"]) {
            BCQueryBillResult *qResp = [[BCQueryBillResult alloc] init];
            for (NSString *key in [dic allKeys]) {
                [qResp setValue:[dic objectForKey:key] forKey:key];
            }
            return qResp;
        } else if ([[dic allKeys] containsObject:@"refund_no"]) {
            BCQueryRefundResult *qResp = [[BCQueryRefundResult alloc] init];
            for (NSString *key in [dic allKeys]) {
                [qResp setValue:[dic objectForKey:key] forKey:key];
            }
            return qResp;
        }
    }
    return nil;
}

#pragma mark Refund Status

- (void)reqRefundStatus:(BCRefundStatusReq *)req {
    if (req == nil) {
        [self doErrorResponse:@"请求结构体不合法"];
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    
    if (req.refundno.isValid) {
        parameters[@"refund_no"] = req.refundno;
    }
    parameters[@"channel"] = @"WX";
    
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    
    [manager GET:[BCPayUtil getBestHostWithFormat:kRestApiRefundState] parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             [self doQueryRefundStatus:(NSDictionary *)response];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self doErrorResponse:kNetWorkError];
         }];
}

- (void)doQueryRefundStatus:(NSDictionary *)dic {
    BCRefundStatusResp *resp = [[BCRefundStatusResp alloc] init];
    resp.result_code = [dic[kKeyResponseResultCode] intValue];
    resp.result_msg = dic[kKeyResponseResultMsg];
    resp.err_detail = dic[kKeyResponseErrDetail];
    resp.refundStatus = [dic objectForKey:@"refund_status"];

    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
    }
}

#pragma mark Util Function

- (void)doErrorResponse:(NSString *)errMsg {
    BCBaseResp *resp = [[BCBaseResp alloc] init];
    resp.result_code = BCErrCodeCommon;
    resp.result_msg = errMsg;
    resp.err_detail = errMsg;
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
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
    
    if (request == nil) {
        [self doErrorResponse:@"请求结构体不合法"];
    } else if (request.type == BCObjsTypePayReq) {
        BCPayReq *req = (BCPayReq *)request;
        if (!req.title.isValid || [BCPayUtil getBytes:req.title] > 32) {
            [self doErrorResponse:@"title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串"];
            return NO;
        } else if (!req.totalfee.isValid || !req.totalfee.isPureInt) {
            [self doErrorResponse:@"totalfee 以分为单位，必须是只包含数值的字符串"];
            return NO;
        } else if (!req.billno.isValid || !req.billno.isValidTraceNo || (req.billno.length < 8) || (req.billno.length > 32)) {
            [self doErrorResponse:@"billno 必须是长度8~32位字母和/或数字组合成的字符串"];
            return NO;
        } else if ((req.channel == PayChannelAliApp) && !req.scheme.isValid) {
            [self doErrorResponse:@"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用"];
            return NO;
        } else if ((req.channel == PayChannelUnApp) && (req.viewController == nil)) {
            [self doErrorResponse:@"viewController 不合法，将导致无法正常执行银联支付"];
            return NO;
        } else if (req.channel == PayChannelWxApp && ![WXApi isWXAppInstalled]) {
            [self doErrorResponse:@"未找到微信客户端，请先下载安装"];
            return NO;
        }
        return YES;
    } else if (request.type == BCObjsTypePayPal) {
        BCPayPalReq *req = (BCPayPalReq *)request;
        if (req.items == nil || req.items.count == 0) {
            [self doErrorResponse:@"payitem 格式不合法"];
            return NO;
        } else if (!req.shipping.isValid) {
            [self doErrorResponse:@"shipping 格式不合法"];
             return NO;
        }  else if (!req.tax.isValid) {
            [self doErrorResponse:@"tax 格式不合法"];
             return NO;
        } else if (req.payConfig == nil) {
            [self doErrorResponse:@"payConfig 格式不合法"];
            return NO;
        } else if (req.viewController == nil) {
            [self doErrorResponse:@"viewController 格式不合法"];
            return NO;
        }
        return YES;
    }
    return NO ;
}

#pragma mark - Implementation WXApiDelegate

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
        NSString *result = tempResp.errStr.isValid?[NSString stringWithFormat:@"%@,%@",strMsg,tempResp.errStr]:strMsg;
        BCBaseResp *resp = [[BCBaseResp alloc] init];
        resp.result_code = errcode;
        resp.result_msg = result;
        resp.err_detail = result;
        if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
            [_deleagte onBCPayResp:resp];
        }
    }
}

#pragma mark - Implementation AliPayDelegate

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
    resp.err_detail = strMsg;
    resp.paySource = resultDic;
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
    }
}

#pragma mark - Implementation UnionPayDelegate

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
    resp.err_detail = strMsg;
    if (_deleagte && [_deleagte respondsToSelector:@selector(onBCPayResp:)]) {
        [_deleagte onBCPayResp:resp];
    }
}

@end
