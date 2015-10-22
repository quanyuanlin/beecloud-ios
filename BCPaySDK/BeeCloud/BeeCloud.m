//
//  BeeCloud.m
//  BeeCloud
//
//  Created by Ewenlong03 on 15/9/7.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//
#import "BeeCloud.h"

#import "BCPayUtil.h"
#import "BCPayCache.h"
#import "BeeCloudAdapter.h"

@interface BeeCloud ()
@property (nonatomic, weak) id<BeeCloudDelegate> delegate;
@end


@implementation BeeCloud

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BeeCloud *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BeeCloud alloc] init];
    });
    return instance;
}

+ (void)initWithAppID:(NSString *)appId andAppSecret:(NSString *)appSecret {
    BCPayCache *instance = [BCPayCache sharedInstance];
    instance.appId = appId;
    instance.appSecret = appSecret;
}

+ (BOOL)initWeChatPay:(NSString *)wxAppID {
    return [BeeCloudAdapter beeCloudRegisterWeChat:wxAppID];
}

+ (void)initPayPal:(NSString *)clientID secret:(NSString *)secret sanBox:(BOOL)isSandBox {
    
    if(clientID.isValid && secret.isValid) {
        BCPayCache *instance = [BCPayCache sharedInstance];
        instance.payPalClientID = clientID;
        instance.payPalSecret = secret;
        instance.isPayPalSandBox = isSandBox;
        
        [BeeCloudAdapter beeCloudRegisterPayPal:clientID secret:secret sanBox:isSandBox];
    }
}

+ (void)setBeeCloudDelegate:(id<BeeCloudDelegate>)delegate {
    [BeeCloud sharedInstance].delegate = delegate;
}

+ (id<BeeCloudDelegate>)getBeeCloudDelegate {
    return [BeeCloud sharedInstance].delegate;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    if (BCPayUrlWeChat == [BCPayUtil getUrlType:url]) {
        return [BeeCloudAdapter beeCloud:kAdapterWXPay handleOpenUrl:url];
    } else if (BCPayUrlAlipay == [BCPayUtil getUrlType:url]) {
        return [BeeCloudAdapter beeCloud:kAdapterAliPay handleOpenUrl:url];
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
    BeeCloud *instance = [BeeCloud sharedInstance];
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
        case BCObjsTypeOfflinePayReq:
            [instance reqOfflinePay:req];
            break;
        case BCObjsTypeOfflineBillStatusReq:
            [instance reqOfflineBillStatus:req];
            break;
        case BCObjsTypeOfflineRevertReq:
            [instance reqOfflineBillRevert:req];
            break;
        default:
            break;
    }
}

#pragma mark private class functions

#pragma mark Pay Request

- (void)reqPay:(BCPayReq *)req {
    [BCPayCache sharedInstance].bcResp = [[BCPayResp alloc] initWithReq:req];
    if (![self checkParameters:req]) return;
    
    NSString *cType = [BCPayUtil getChannelString:req.channel];
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    
    parameters[@"channel"] = cType;
    parameters[@"total_fee"] = [NSNumber numberWithInteger:[req.totalFee integerValue]];
    parameters[@"bill_no"] = req.billNo;
    parameters[@"title"] = req.title;
    if (req.billTimeOut > 0) {
        parameters[@"bill_timeout"] = @(req.billTimeOut);
    }
    if (req.optional) {
        parameters[@"optional"] = req.optional;
    }
  
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    __weak BeeCloud *weakSelf = [BeeCloud sharedInstance];
    
    [manager POST:[BCPayUtil getBestHostWithFormat:kRestApiPay] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id response) {
            
              if ([[response objectForKey:kKeyResponseResultCode] intValue] != 0) {
                  [weakSelf getErrorInResponse:response];
              } else {
                  BCPayLog(@"channel=%@,resp=%@", cType, response);
                  NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:
                                              (NSDictionary *)response];
                  if (req.channel == PayChannelAliApp) {
                      [dic setObject:req.scheme forKey:@"scheme"];
                  } else if (req.channel == PayChannelUnApp) {
                      [dic setObject:req.viewController forKey:@"viewController"];
                  }
                  [BCPayCache sharedInstance].bcResp.bcId = [dic objectForKey:@"id"];
                  [weakSelf doPayAction:req.channel source:dic];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [weakSelf doErrorResponse:kNetWorkError];
          }];
}

#pragma mark - Pay Action

- (void)doPayAction:(PayChannel)channel source:(NSMutableDictionary *)dic {
    if (dic) {
        BCPayLog(@"payment====%@", dic);
        switch (channel) {
            case PayChannelWxApp:
                [BeeCloudAdapter beeCloudWXPay:dic];
                break;
            case PayChannelAliApp:
                [BeeCloudAdapter beeCloudAliPay:dic];
                break;
            case PayChannelUnApp:
                [BeeCloudAdapter beeCloudUnionPay:dic];
                break;
            case PayChannelBaiduApp:
                [BeeCloudAdapter beeCloudBaiduPay:dic];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Offline Pay

- (void)reqOfflinePay:(id)req {
    [BeeCloudAdapter beeCloudOfflinePay:[NSMutableDictionary dictionaryWithObjectsAndKeys:req,kAdapterOffline, nil]];
}

#pragma mark - OffLine BillStatus

- (void)reqOfflineBillStatus:(id)req {
    [BeeCloudAdapter beeCloudOfflineStatus:[NSMutableDictionary dictionaryWithObjectsAndKeys:req,kAdapterOffline, nil]];
}

#pragma mark - OffLine BillRevert

- (void)reqOfflineBillRevert:(id)req {
    [BeeCloudAdapter beeCloudOfflineRevert:[NSMutableDictionary dictionaryWithObjectsAndKeys:req,kAdapterOffline, nil]];
}

#pragma mark PayPal

- (void)reqPayPal:(BCPayPalReq *)req {
    [BeeCloudAdapter beeCloudPayPal:[NSMutableDictionary dictionaryWithObjectsAndKeys:req, kAdapterPayPal,nil]];
}

- (void)reqPayPalVerify:(BCPayPalVerifyReq *)req {
    [BeeCloudAdapter beeCloudPayPalVerify:[NSMutableDictionary dictionaryWithObjectsAndKeys:req,kAdapterPayPal, nil]];
}

#pragma mark Query Bills/Refunds

- (void)reqQueryOrder:(BCQueryReq *)req {
    [BCPayCache sharedInstance].bcResp = [[BCQueryResp alloc] initWithReq:req];
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
    
    if (req.billNo.isValid) {
        parameters[@"bill_no"] = req.billNo;
    }
    if (req.startTime.isValid) {
        parameters[@"start_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.startTime]];
    }
    if (req.endTime.isValid) {
        parameters[@"end_time"] = [NSNumber numberWithLongLong:[BCPayUtil dateStringToMillisencond:req.endTime]];
    }
    if (req.type == BCObjsTypeQueryRefundReq) {
        BCQueryRefundReq *refundReq = (BCQueryRefundReq *)req;
        if (refundReq.refundNo.isValid) {
            parameters[@"refund_no"] = refundReq.refundNo;
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
    __weak BeeCloud *weakSelf = [BeeCloud sharedInstance];
    [manager GET:reqUrl parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             BCPayLog(@"resp = %@", response);
             [weakSelf doQueryResponse:(NSDictionary *)response];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [weakSelf doErrorResponse:kNetWorkError];
         }];
}

- (void)doQueryResponse:(NSDictionary *)dic {
    BCQueryResp *resp = (BCQueryResp *)[BCPayCache sharedInstance].bcResp;
    resp.resultCode = [dic[kKeyResponseResultCode] intValue];
    resp.resultMsg = dic[kKeyResponseResultMsg];
    resp.errDetail = dic[kKeyResponseErrDetail];
    resp.count = [[dic objectForKey:@"count"] integerValue];
    resp.results = [self parseResults:dic];
    [BCPayCache beeCloudDoResponse];
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
            return [[BCQueryBillResult alloc] initWithResult:dic];
        } else if ([[dic allKeys] containsObject:@"refund_no"]) {
            return [[BCQueryRefundResult alloc] initWithResult:dic];
        }
    }
    return nil;
}

#pragma mark Refund Status For WeChat

- (void)reqRefundStatus:(BCRefundStatusReq *)req {
    [BCPayCache sharedInstance].bcResp = [[BCRefundStatusResp alloc] initWithReq:req];
    if (req == nil) {
        [self doErrorResponse:@"请求结构体不合法"];
        return;
    }
    
    NSMutableDictionary *parameters = [BCPayUtil prepareParametersForPay];
    if (parameters == nil) {
        [self doErrorResponse:@"请检查是否全局初始化"];
        return;
    }
    
    if (req.refundNo.isValid) {
        parameters[@"refund_no"] = req.refundNo;
    }
    parameters[@"channel"] = @"WX";
    
    NSMutableDictionary *preparepara = [BCPayUtil getWrappedParametersForGetRequest:parameters];
    
    AFHTTPRequestOperationManager *manager = [BCPayUtil getAFHTTPRequestOperationManager];
    __weak BeeCloud *weakSelf = [BeeCloud sharedInstance];
    [manager GET:[BCPayUtil getBestHostWithFormat:kRestApiRefundState] parameters:preparepara
         success:^(AFHTTPRequestOperation *operation, id response) {
             [weakSelf doQueryRefundStatus:(NSDictionary *)response];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [weakSelf doErrorResponse:kNetWorkError];
         }];
}

- (void)doQueryRefundStatus:(NSDictionary *)dic {
    BCRefundStatusResp *resp = (BCRefundStatusResp *)[BCPayCache sharedInstance].bcResp;
    resp.resultCode = [dic[kKeyResponseResultCode] intValue];
    resp.resultMsg = dic[kKeyResponseResultMsg];
    resp.errDetail = dic[kKeyResponseErrDetail];
    resp.refundStatus = [dic objectForKey:@"refund_status"];
    [BCPayCache beeCloudDoResponse];
}

#pragma mark Util Function

- (void)doErrorResponse:(NSString *)errMsg {
    BCBaseResp *resp = [BCPayCache sharedInstance].bcResp;
    resp.resultCode = BCErrCodeCommon;
    resp.resultMsg = errMsg;
    resp.errDetail = errMsg;
    [BCPayCache beeCloudDoResponse];
}

- (void)getErrorInResponse:(id)response {
    NSDictionary *dic = (NSDictionary *)response;
    BCBaseResp *resp = [BCPayCache sharedInstance].bcResp;
    resp.resultCode = [dic[kKeyResponseResultCode] intValue];
    resp.resultMsg = dic[kKeyResponseResultMsg];
    resp.errDetail = dic[kKeyResponseErrDetail];
    [BCPayCache beeCloudDoResponse];
}

- (BOOL)checkParameters:(BCBaseReq *)request {
    
    if (request == nil) {
        [self doErrorResponse:@"请求结构体不合法"];
    } else if (request.type == BCObjsTypePayReq) {
        BCPayReq *req = (BCPayReq *)request;
        if (!req.title.isValid || [BCPayUtil getBytes:req.title] > 32) {
            [self doErrorResponse:@"title 必须是长度不大于32个字节,最长16个汉字的字符串的合法字符串"];
            return NO;
        } else if (!req.totalFee.isValid || !req.totalFee.isPureInt) {
            [self doErrorResponse:@"totalfee 以分为单位，必须是只包含数值的字符串"];
            return NO;
        } else if (!req.billNo.isValid || !req.billNo.isValidTraceNo || (req.billNo.length < 8) || (req.billNo.length > 32)) {
            [self doErrorResponse:@"billno 必须是长度8~32位字母和/或数字组合成的字符串"];
            return NO;
        } else if ((req.channel == PayChannelAliApp) && !req.scheme.isValid) {
            [self doErrorResponse:@"scheme 不是合法的字符串，将导致无法从支付宝钱包返回应用"];
            return NO;
        } else if ((req.channel == PayChannelUnApp) && (req.viewController == nil)) {
            [self doErrorResponse:@"viewController 不合法，将导致无法正常执行银联支付"];
            return NO;
        } else if (req.channel == PayChannelWxApp && ![BeeCloudAdapter beeCloudIsWXAppInstalled]) {
            [self doErrorResponse:@"未找到微信客户端，请先下载安装"];
            return NO;
        }
        return YES;
    }
    return NO ;
}

@end
