//
//  BCPayUtil.h
//  BCPay
//
//  Created by Ewenlong03 on 15/7/9.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPayObject.h"
#import "AFNetworking.h"
#import "BeeCloud.h"
#import "BCPayConstant.h"
#import "BCPayCache.h"


@interface BCPayUtil : NSObject

/** @name util functions*/

/**
 *  Produces an error object within BeeCloud domain with customized errorMsg.
 *
 *  @param code     Error code is a customized NSInteger.
 *  @param errorMsg Error message, which can be nil.
 *
 *  @return Error
 */
+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)errorMsg;

/*!
 A wrapper for AFHTTPRequestOperationManager.
 */
+ (AFHTTPRequestOperationManager *)getAFHTTPRequestOperationManager;

/**
 *  Get wrapped parameters in the format of "para" to a map for GET REST APIs.
 *
 *  @param parameters map
 *
 *  @return new map
 */
+ (NSMutableDictionary *)getWrappedParametersForGetRequest:(NSDictionary *) parameters;

/**
 *  Common method to get error string based on the highest level response's resultCode and errMsg field.
 *
 *  @param response JSON response object replied by the cloud.
 *
 *  @return error string if there is error; nil otherwise.
 */
+ (NSString *)getErrorStringBasedOnResultCodeAndErrMsgInResponse:(id)response;

/**
 *   Get app signature.
 *
 *   @param appId
 *
 *   @param appSecret
 *
 *   @return app signature using MD5
 */
+ (NSString *)getAppSignature:(NSString*)appId appSecret:(NSString *)appSecret;

/**
 *  prepare parameters
 *
 *  @param block result block
 *
 *  @return default request map
 */
+ (NSMutableDictionary *)prepareParametersForPay:(BCPayBlock)block;

/**
 *  获取url的类型，微信或者支付宝
 *
 *  @param url 渠道返回的url
 *
 *  @return 微信或者支付宝
 */
+ (BCPayUrlType)getUrlType:(NSURL *)url;

@end

FOUNDATION_EXPORT void BCPayLog(NSString *format,...) NS_FORMAT_FUNCTION(1,2) ;
