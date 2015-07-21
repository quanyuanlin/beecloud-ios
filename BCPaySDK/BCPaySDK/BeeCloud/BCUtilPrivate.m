//
//  BCUtilPrivate.m
//  BeeCloud SDK
//
//  Created by Junxian Huang on 3/10/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "BCUtilPrivate.h"
#import "BCCache.h"
#import "BCObject.h"

@implementation BCUtilPrivate

+ (BOOL)isSystemKey:(NSString *)key {
    return [kKeyACL caseInsensitiveCompare:key] == NSOrderedSame ||
    [kKeyObjectId caseInsensitiveCompare:key] == NSOrderedSame ||
    [kKeyCreatedAt caseInsensitiveCompare:key] == NSOrderedSame ||
    [kKeyUpdatedAt caseInsensitiveCompare:key] == NSOrderedSame;
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)errorMsg {
    NSMutableDictionary *userInfo = nil;
    if (errorMsg != nil) {
        userInfo = [NSMutableDictionary dictionaryWithObject:errorMsg forKey:@"error"];
    }
    return [NSError errorWithDomain:kErrorDomain code:code userInfo:userInfo];
}

+ (BOOL)isPrimitiveDataType:(BCDataType)type {
    switch(type) {
        case BCDataTypeBool:
        case BCDataTypeInt32:
        case BCDataTypeInt64:
        case BCDataTypeFloat:
        case BCDataTypeDouble:
        case BCDataTypeString:
        case BCDataTypeUUID:
        case BCDataTypeDate:
            return YES;
        default:
            break;
    }
    return NO;
}

+ (BOOL)isConsistentPrimitiveType:(id)object type:(BCDataType)type {
    if (object == nil) return NO;
    if (![BCUtilPrivate isPrimitiveDataType:type]) return NO;
    switch(type) {
        case BCDataTypeString:
            return [object isKindOfClass:[NSString class]];
        case BCDataTypeUUID:
            return [object isKindOfClass:[NSString class]];
        case BCDataTypeDate:
            return [object isKindOfClass:[NSDate class]];
        default:
            break;
    }
    // Number types.
    return [object isKindOfClass:[NSNumber class]];
}

+ (BCDataType)getDataTypeForTypeString:(NSString *)typeString {
    if (typeString == nil) return BCDataTypeUnsupported;
    if ([kTypeEncodeBool isEqualToString:typeString]) {
        return BCDataTypeBool;
    } else if ([kTypeEncodeDouble isEqualToString:typeString]) {
        return BCDataTypeDouble;
    } else if ([kTypeEncodeFloat isEqualToString:typeString]) {
        return BCDataTypeFloat;
    } else if ([kTypeEncodeInt32 isEqualToString:typeString]) {
        return BCDataTypeInt32;
    } else if ([kTypeEncodeInt64 isEqualToString:typeString]) {
        return BCDataTypeInt64;
    } else if ([kTypeEncodeString isEqualToString:typeString]) {
        return BCDataTypeString;
    } else if ([kTypeEncodeUUID isEqualToString:typeString]) {
        return BCDataTypeUUID;
    } else if ([kTypeEncodeDate isEqualToString:typeString]) {
        return BCDataTypeDate;
    } else if ([kTypeEncodeNull isEqualToString:typeString]) {
        return BCDataTypeNull;
    }
    
    if (typeString.length == 3) {
        if ([kTypeEncodeArray characterAtIndex:0] == [typeString characterAtIndex:0] &&
            [kTypeEncodeArray characterAtIndex:3] == [typeString characterAtIndex:2]) {
            return BCDataTypeArray;
        } else if ([kTypeEncodeSet characterAtIndex:0] == [typeString characterAtIndex:0] &&
                   [kTypeEncodeSet characterAtIndex:3] == [typeString characterAtIndex:2]) {
            return BCDataTypeSet;
        }
    }
    
    if (typeString.length == 5 &&
        // <%@,%@> v.s. <s,s>
        // 0123456      01234
        [kTypeEncodeMap characterAtIndex:0] == [typeString characterAtIndex:0] &&
        [kTypeEncodeMap characterAtIndex:3] == [typeString characterAtIndex:2] &&
        [kTypeEncodeMap characterAtIndex:6] == [typeString characterAtIndex:4]) {
        return BCDataTypeMap;
    }
    
    return BCDataTypeUnsupported;
}

+ (NSString *)getPrimitiveTypeString:(BCDataType)type {
    if (![BCUtilPrivate isPrimitiveDataType:type]) return nil;
    switch (type) {
        case BCDataTypeBool:
            return kTypeEncodeBool;
        case BCDataTypeDouble:
            return kTypeEncodeDouble;
        case BCDataTypeFloat:
            return kTypeEncodeFloat;
        case BCDataTypeInt32:
            return kTypeEncodeInt32;
        case BCDataTypeInt64:
            return kTypeEncodeInt64;
        case BCDataTypeString:
            return kTypeEncodeString;
        case BCDataTypeUUID:
            return kTypeEncodeUUID;
        case BCDataTypeDate:
            return kTypeEncodeDate;
        default:
            break;
    }
    return nil;
}

+ (NSString *)getContainerTypeString:(BCDataType)type withKeyType:(BCDataType)keyType {
    if (![BCUtilPrivate isPrimitiveDataType:keyType]) return nil;
    if (type == BCDataTypeArray) {
        return [NSString stringWithFormat:kTypeEncodeArray, [BCUtilPrivate getPrimitiveTypeString:keyType]];
    } else if (type == BCDataTypeSet) {
        return [NSString stringWithFormat:kTypeEncodeSet, [BCUtilPrivate getPrimitiveTypeString:keyType]];
    }
    return nil;
}

+ (NSString *)getMapTypeStringWithKeyType:(BCDataType)keyType valueType:(BCDataType)valueType {
    if (![BCUtilPrivate isPrimitiveDataType:keyType] ||
        ![BCUtilPrivate isPrimitiveDataType:valueType]) return nil;
    return [NSString stringWithFormat:kTypeEncodeMap,
            [BCUtilPrivate getPrimitiveTypeString:keyType],
            [BCUtilPrivate getPrimitiveTypeString:valueType]];
}

+ (NSString *)getNullTypeString {
    return kTypeEncodeNull;
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

#pragma mark - Response reaction methods
/** @name React to API Response */

+ (void)callBlock:(BCBooleanResultBlock)block WithErrorString:(NSString *)errorString {
    if (errorString == nil || [errorString isEqualToString:@""])
        [self callBlock:block WithError:nil];
    else
        [self callBlock:block WithError:[BCUtilPrivate errorWithCode:0 message: errorString]];
}

+ (void)callBlock:(BCBooleanResultBlock)block WithError:(NSError *)error {
    if (block) {
        if (error)
            block(NO, error);
        else
            block(YES, nil);
    }
}

+ (NSString *)getErrorStringBasedOnResultCodeAndErrMsgInResponse:(id)response {
    NSNumber *resultCode = [response objectForKey:kKeyResponseResultCode];
    NSString *errMsg = [response objectForKey:kKeyResponseErrMsg];
    if (resultCode == nil || errMsg == nil) {
        return @"Invalid response.";
    } else if ([resultCode intValue] != 0) {
        // Result code indicating error.
        return errMsg;
    }
    return nil;
}

+ (BOOL)reactToSimpleResponse:(id)response block:(BCBooleanResultBlock)block {
    NSString *basicErrorString = [BCUtilPrivate getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
    if (basicErrorString != nil) {
        // Top level error.
        if (block)
            [BCUtilPrivate callBlock:block
                     WithErrorString:[NSString stringWithFormat:@"Error in %s: %@.", __func__, basicErrorString]];
        return NO;
    }
    // Successful operation
    if (block)
        block(YES, nil);
    return YES;
}

+ (void)setSystemClassName:(NSString *)className forObject:(BCObject *)object {
    if (object != nil)
        [object addArrayForKey:[NSString stringWithFormat:@"%@%@", kBackdoorKey, className]
                   withKeyType:BCDataTypeUnsupported];
}

+ (NSString *)getAppSignature:(NSString *)appId appSecret:(NSString *)appSecret {
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

+ (void)checkRequestFail {
   //K [BCStatus checkBestHostForFail];
}

@end

void BCDLog(NSString *format,...) {
    if ([BCCache sharedInstance].willPrintLogMsg) {
        va_list list;
        va_start(list,format);
        NSLogv(format, list);
        va_end(list);
    }
}