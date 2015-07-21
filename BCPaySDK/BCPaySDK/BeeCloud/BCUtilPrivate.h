//
//  BCUtilPrivate.h
//  BeeCloud SDK
//
//  Created by Junxian Huang on 3/10/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

/*!
 This header file is *NOT* included in the public release.
 */

#import "AFNetworking.h"
#import "BCConstants.h"

static NSString * const kErrorDomain = @"cn.beecloud.api";

static NSUInteger const kBCHostCount = 4;
static NSString * const kBCHosts[] = {@"https://apisz.beecloud.cn",
                                      @"https://apiqd.beecloud.cn",
                                      @"https://apibj.beecloud.cn",
                                      @"https://apihz.beecloud.cn"};

static NSString * const apiVersion = @"/1";
// API urls.
static NSString * const kApiInsert = @"%@/insert";
static NSString * const kApiModifyById = @"%@/modify/byId";
static NSString * const kApiModifyByCondition = @"%@/modify/byCondition";
static NSString * const kApiQueryById = @"%@/query/byId";
static NSString * const kApiQueryByCondition = @"%@/query/byCondition";
static NSString * const kApiQueryCount = @"%@/query/count";
static NSString * const kApiDeleteById = @"%@/delete/byId";
static NSString * const kApiDeleteByCondition = @"%@/delete/byCondition";
static NSString * const kApiGetLocationInfo = @"%@/location/getInfo";
static NSString * const kApiGetGpsByIp = @"%@/location/getGpsByIp";
static NSString * const kApiLogEvent = @"%@/analysis/event";
static NSString * const kApiGetToken = @"%@/file/getToken";
static NSString * const kApiStatus = @"%@/status";	
//bcuser url
static NSString * const kApiUserRegister = @"%@/bcuser/register";
static NSString * const kApiUserCheckEmail = @"%@/bcuser/checkEmail";
static NSString * const kApiUserLogin = @"%@/bcuser/login";
static NSString * const kApiUserLogout = @"%@/bcuser/logout";
static NSString * const kApiEmailSend = @"%@/email/send";
//wxPay url
static NSString * const kApiPayWeChatPrepare = @"%@/pay/weChat/prepare";
static NSString * const kApiPayWeChatQueryBill = @"%@/pay/weChat/refund/queryBill";
static NSString * const kApiPayWeChatStartRefund = @"%@/pay/weChat/refund/startRefund";
static NSString * const kApiPayWeChatConfirmRefund = @"%@/pay/weChat/refund/confirmRefund";
//alipay url
static NSString * const kApiPayAliPreSign = @"%@/pay/ali/sign";
static NSString * const kApiPayAliStartRefund = @"%@/pay/ali/refund/startRefund";
//unionPay url
static NSString * const kApiPayUnionPayGetTN = @"%@/pay/un/sign";
static NSString * const kApiPayUnionPayRefund = @"%@/pay/un/refund/startRefund";

// System keys in lower case.
// Notice that kKeyObjectId should be "objectid" instead of "objectId" because it's used for case-insensitive
// comparison.
static NSString * const kKeyACL = @"acl";
static NSString * const kKeyObjectId = @"objectid";
static NSString * const kKeyCreatedAt = @"createdat";
static NSString * const kKeyUpdatedAt = @"updatedat";
static NSString * const kKeyBestHost = @"bestHost";

// Keys for BCFile.
static NSString * const kKeyFileURL = @"url";
static NSString * const kKeyFileSize = @"size";
static NSString * const kKeyFileName = @"name";
static NSString * const kKeyFileExtension = @"extension";
static NSString * const kKeyFileStatus = @"status";
static NSString * const kKeyFileOriginalPath = @"original_path";

// REST API response keys.
static NSString * const kKeyResponseType = @"type";
static NSString * const kKeyResponseResult = @"results";
static NSString * const kKeyResponseCount = @"total";
static NSString * const kKeyResponseResultCode = @"resultCode";
static NSString * const kKeyResponseErrMsg = @"errMsg";

// Data type encoding scheme.
static NSString * const kTypeEncodeBool = @"b";
static NSString * const kTypeEncodeInt32 = @"i";
static NSString * const kTypeEncodeInt64 = @"l";
static NSString * const kTypeEncodeFloat = @"f";
static NSString * const kTypeEncodeDouble = @"d";
static NSString * const kTypeEncodeString = @"s";
static NSString * const kTypeEncodeUUID = @"u";
static NSString * const kTypeEncodeDate = @"t";
static NSString * const kTypeEncodeLocation = @"g";
static NSString * const kTypeEncodeArray = @"[%@]";
static NSString * const kTypeEncodeSet = @"<%@>";
static NSString * const kTypeEncodeMap = @"<%@,%@>";
static NSString * const kTypeEncodeNull = @"n";

// Special event names.
static NSString * const kEventAppStart = @"app_start__";
static NSString * const kEventAppEnd = @"app_end__";

// Object ID of a new object.
static NSString * const kNewObjectId = @"";

// Backdoor key for BCQuery to access information in BCObject.
static NSString * const kBackdoorKey = @"2014bc11-b11c-bc11-1bc1-446655440000";

/// @todo(hjx): move this code into constant later if necessary.
/**
 When you create a new app in the BeeCloud website, the system will automatically create two tables for you. One is the
 user table with class name "user__" for storing BCUser objects and the other is the ACL table with class name "ACL__"
 for storing BCACL objects. You can use the website dashboard to view all user information, create role ACL, etc.
 */
static NSString * const kBCUserClassName = @"user__";
static NSString * const kBCACLClassName = @"acl__";
static NSString * const kBCConfigClassName = @"config__";
static NSString * const kBCFileClassName = @"file__";
static NSString * const kBCEventAnalysisClassName = @"analysis_event__";
static NSString * const kBCIAPClassName = @"iap_record_";
static NSString * const kBCWeChatPayClassName = @"wechat_pay_result__";
static NSString * const KBCWeChatRefundClassName = @"wechat_pre_refund__";
static NSString * const kBCAliPayClassName = @"ali_pay_result__";
static NSString * const kBCAliRefundClassName = @"ali_pre_refund__";
static NSString * const kBCUPPayClassName = @"un_pay_result__";
static NSString * const kBCUPRefundClassName = @"un_pre_refund__";

// Banned method error message.
static NSString * const kBannedMethodName = @"BannedMethods";
static NSString * const kBannedMethodReason = @"%s error: calling BCObject instance creation methods are not "
"permitted, please refer to the header file to call the corresponding instance creation methods.";


/**
 *  This is a unitility class holding functions that are useful for ourselves for developing, but not suitable for
 *  providing them to the public.
 */
@interface BCUtilPrivate : NSObject

/*!
 Returns whether the BCObject column key is a system key, including objectID, ACL, createdAt and updatedAt.
 */
+ (BOOL)isSystemKey:(NSString *)key;

/*!
 Produces an error object within BeeCloud domain with customized errorMsg.
 @param code Error code is a customized NSInteger.
 @param errorMsg Error message, which can be nil.
 */
+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)errorMsg;

/*!
 Returns YES for primitive data types including number, BOOL, string and date.
 */
+ (BOOL)isPrimitiveDataType:(BCDataType)type;

/*!
 Verifies that type is a primitive type and object is of the corresponding data type, i.e., NSDate for date, NSString
 for string, and NSNumber for number and BOOL.
 */
+ (BOOL)isConsistentPrimitiveType:(id)object type:(BCDataType)type;

/*!
 Returns the data type given the encoded data type string of a given object. All primitive and container data types are
 supported.
 */
+ (BCDataType)getDataTypeForTypeString:(NSString *)typeString;

/*!
 Returns the encoded data type string of a given object with a primitive data type (string, date, BOOL or number).
 Returns nil for unsupported or non-primitive data types or when object is nil.
 */
+ (NSString *)getPrimitiveTypeString:(BCDataType)type;

/*!
 Returns the encoded data type string of a given array or set with the specified primitive keyType.
 */
+ (NSString *)getContainerTypeString:(BCDataType)type withKeyType:(BCDataType)keyType;

/*!
 Returns the encoded data type string of a given map with the specified primitive keyType and valueType.
 */
+ (NSString *)getMapTypeStringWithKeyType:(BCDataType)keyType valueType:(BCDataType)valueType;

/*!
 Returns the encoded data type string for BCDataTypeNull.
 */
+ (NSString *)getNullTypeString;

/*!
 A wrapper for AFHTTPRequestOperationManager.
 */
+ (AFHTTPRequestOperationManager *)getAFHTTPRequestOperationManager;

/*!
 Get wrapped parameters in the format of "para" to a map for GET REST APIs.
 */
+ (NSMutableDictionary *)getWrappedParametersForGetRequest:(NSDictionary *) parameters;

#pragma mark - Response reaction methods
/** @name React to API Response */

/**
 *  Helper function to call block with given error string. If errorString is nil or @"", we assume there is no error.
 *
 *  @param block       BCBooleanResultBlock which can be nil.
 *  @param errorString Error string to be reported. If errorString is nil or @"", we assume there is no error.
 */
+ (void)callBlock:(BCBooleanResultBlock)block WithErrorString:(NSString *)errorString;

/**
 *  Helper function to call block with given error.
 *
 *  @param block BCBooleanResultBlock which can be nil.
 *  @param error NSError which can be nil.
 */
+ (void)callBlock:(BCBooleanResultBlock)block WithError:(NSError *)error;

/**
 *  Common method to get error string based on the highest level response's resultCode and errMsg field.
 *
 *  @param response JSON response object replied by the cloud.
 *
 *  @return error string if there is error; nil otherwise.
 */
+ (NSString *)getErrorStringBasedOnResultCodeAndErrMsgInResponse:(id)response;

/**
 *  Helper function to react to only resultCode and errMsg with given block. Used for API calls, such as
 *  modifyByCondition, deleteByCondition and deleteById, in which there is nothing in the reply besides resultCode and
 *  errMsg, unlike other API calls.
 *
 *  @param response JSON response object replied by the cloud.
 *  @param block    BCBooleanResultBlock which can be nil.
 *
 *  @return YES if the original operation is successful; NO otherwise.
 */
+ (BOOL)reactToSimpleResponse:(id)response block:(BCBooleanResultBlock)block;

/**
 *  Set className for a given object using backdoor method, to allow system table names, such as "config__", to be set.
 *
 *  @param className Class name to be set.
 *  @param object    Target object
 */
+ (void)setSystemClassName:(NSString *)className forObject:(BCObject *)object;

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
 * check request failed
 */
+ (void)checkRequestFail ;

@end

FOUNDATION_EXPORT void BCDLog(NSString *format,...) NS_FORMAT_FUNCTION(1,2) ;

