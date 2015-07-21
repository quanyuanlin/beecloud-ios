//
//  BCConstants.h
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/18/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#ifndef BeeCloud_BCConstants_h
#define BeeCloud_BCConstants_h

/**
 *  Supported data types for BCObject.
 *
 *  Make sure to use the corresponding Objective-C types following the BCDataType.
 */
typedef NS_ENUM(NSInteger, BCDataType) {
    /**
     *  bool type. When in the object format, it corresponds to [NSNumber numberWithBool:].
     */
    BCDataTypeBool,
    /**
     *  int32 type. When in the object format, it corresponds to [NSNumber numberWithInt:].
     */
    BCDataTypeInt32,
    /**
     *  int64 type. When in the object format, it corresponds to [NSNumber numberWithLongLong:].
     */
    BCDataTypeInt64,
    /**
     *  float type. When in the object format, it corresponds to [NSNumber numberWithFloat:].
     */
    BCDataTypeFloat,
    /**
     *  double type. When in the object format, it corresponds to [NSNumber numberWithDouble:].
     */
    BCDataTypeDouble,
    /**
     *  string type. It corresponds to NSString.
     */
    BCDataTypeString,
    /**
     *  UUID type. It corresponds to NSString.
     *  Although in the client side, we do not distinguish UUID type from NSString, in the cloud, we store UUID as an
     *  array of bytes in its original form, providing high efficiency for storage and read/write access.
     */
    BCDataTypeUUID,
    /**
     *  date type. It corresponds to NSDate.
     */
    BCDataTypeDate,
    /**
     *  location type. It corresponds to BCLocation.
     */
    BCDataTypeLocation,
    /**
     *  array type. It corresponds to NSArray.
     */
    BCDataTypeArray,
    /**
     *  set type. It corresponds to NSSet.
     */
    BCDataTypeSet,
    /**
     *  map type. It corresponds to NSDictionary.
     */
    BCDataTypeMap,
    /**
     *  NULL type. It corresponds to nil.
     */
    BCDataTypeNull,
    /**
     *  Error type indicating that the data type is not yet supported by the cloud.
     */
    BCDataTypeUnsupported
};

/**
 *  Status of a BCFile object.
 */
typedef NS_ENUM(NSInteger, BCFileStatus) {
    /**
     *  Default status, indicating the file has not been uploaded yet.
     */
    BCFileStatusDefault,
    /**
     *  File is being uploaded.
     */
    BCFileStatusUploading,
    /**
     *  Upload succeeded.
     */
    BCFileStatusUploadSuccess,
    /**
     *  Upload failed.
     */
    BCFileStatusUploadFailure
};

/**
 *  BCPay URL type for handling URLs.
 */
typedef NS_ENUM(NSInteger, BCPayUrlType){
    /**
     *  Unknown type.
     */
    BCPayUrlUnknown,
    /**
     *  WeChat pay.
     */
    BCPayUrlWeChat,
    /**
     *  Alipay.
     */
    BCPayUrlAlipay
};

/**
 Date format with millisecond accuracy. Example: "2014-02-25 14:27:44.037 GMT-08:00".
 */
static NSString * const kBCDateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZ";

@class BCObject;
@class BCLocation;

/**
 *  Result block for boolean result.
 *
 *  @param succeeded Boolean result.
 *  @param error     Carries error if there is one, or nil otherwise.
 */
typedef void (^BCBooleanResultBlock)(BOOL succeeded, NSError *error);

/**
 *  Result block for integer result.
 *
 *  @param number Integer result.
 *  @param error  Carries error if there is one, or nil otherwise.
 */
typedef void (^BCIntegerResultBlock)(NSInteger number, NSError *error);

/**
 *  Result block for array result.
 *
 *  @param objects Array result.
 *  @param error   Carries error if there is one, or nil otherwise.
 */
typedef void (^BCArrayResultBlock)(NSArray *objects, NSError *error);

/**
 *  Result block for BCObject result.
 *
 *  @param object BCObject result.
 *  @param error  Carries error if there is one, or nil otherwise.
 */
typedef void (^BCObjectResultBlock)(BCObject *object, NSError *error);

/**
 *  Result block for BCLocation result.
 *
 *  @param location BCLocation result.
 *  @param error    Carries error if there is one, or nil otherwise.
 */
typedef void (^BCLocationResultBlock)(BCLocation *location, NSError *error);

/**
 *  Result block for id result.
 *
 *  @param objects id result, which could be any pointer type.
 *  @param error   Carries error if there is one, or nil otherwise.
 */
typedef void (^BCIdResultBlock)(id object, NSError *error);

/**
 *  Result block for purchase or restore result.
 *
 *  @param productId purchased or restored product id
 *  @param state     purchase state : 0 for succeeded, 1 for failed, 2 for restored
 *  @param error     error enum could be :
 SKErrorUnknown,
 SKErrorClientInvalid,               // client is not allowed to issue the request, etc.
 SKErrorPaymentCancelled,            // user cancelled the request, etc.
 SKErrorPaymentInvalid,              // purchase identifier was invalid, etc.
 SKErrorPaymentNotAllowed,           // this device is not allowed to make the payment
 SKErrorStoreProductNotAvailable,    // Product is not available in the current storefront
 
 */
typedef void (^BCPurchaseBlock)(NSString *productId, NSInteger state, NSError *error);

/**
 *  Result block for init products result.
 *
 *  @param products  Inited products
 *  @param failedIds Failed productIds
 *  @param error     Error
 */
typedef void (^BCProductBlock)(NSArray *products, NSArray *failedIds, NSError *error);

/**
 *  Result block for save purchase or restore record.
 *
 *  @param transaction  transaction
 *  @param error     Error
 */
typedef void (^BCIAPRecordBlock)(id transaction, NSError *error);


/// TODO(hwl): 将success\fail\cancel\invalid\ 定义成NS_ENUM, 参考BCDataType
/**
 *  Result block for pay result.
 *
 *  @param result Pay result, success\fail\cancel\invalid
 *  @param error  Error
 */
typedef void (^BCPayBlock)(BOOL success, NSString *strMsg, NSError *error);

#endif
