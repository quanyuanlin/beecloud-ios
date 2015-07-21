//
//  BCCache.h
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/27/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

/*!
 This header file is *NOT* included in the public release.
 */

/**
 *  BCCache stores system settings and content caches.
 */
@interface BCCache : NSObject

/**
 *  App key obtained when registering this app in BeeCloud website. Change this value via [BeeCloud setAppKey:];
 */
@property (nonatomic, strong) NSString *appId;

/**
 *  App key obtained when registering this app in BeeCloud website.
 */
@property (nonatomic, strong) NSString *appSecret;

/**
 *  Master key obtained when registering this app in BeeCloud website. Change this value via [BeeCloud setAppKey:];
 */
@property (nonatomic, strong) NSString *masterKey;

/**
 *  Default network timeout in seconds for all network requests. Change this value via [BeeCloud setNetworkTimeout:];
 */
@property (nonatomic) NSTimeInterval networkTimeout;

/**
 *  server host map [host:RTT,...]
 */
@property (nonatomic, strong) NSMutableDictionary *hostRTTMap;

/**
 * best host
 */
@property (nonatomic, strong) NSString *bestHost;

/**
 *  Current latitude.
 */
@property (nonatomic) double currentLatitude;

/**
 *  Current longitude.
 */
@property (nonatomic) double currentLongitude;

/**
 *  User ID, nil for unknown.
 */
@property (nonatomic, strong) NSString *userId;

/**
 *  Pay status of the current user, @"pay", @"free", or nil for unknown.
 */
@property (nonatomic, strong) NSString *userPayStatus;

/**
 *  Gender of the current user, @"male", @"female", or nil for unknown.
 */
@property (nonatomic, strong) NSString *userGender;

/**
 *  Age of the current user, nil for unknown.
 */
@property (nonatomic, strong) NSString *userAge;

/*!
 Stores "className,objectId" => object mapping. Whenever a new object is created, always try to use the cached object.
 All className and objectId are case insensitive.
 */
@property (nonatomic, strong) NSMutableDictionary *cacheForObjects;

/*!
 Stores "className,objectId,key1,key2,..." => type mapping. All className, objectId and keys are case insensitive. The
 order of the keys does not matter.
 */
@property (nonatomic, strong) NSMutableDictionary *cacheForTypes;

/*!
 Stores "className,objectId,key1,key2,..." => result mapping. All className, objectId and keys are case insensitive. The
 order of the keys does not matter.
 */
@property (nonatomic, strong) NSMutableDictionary *cacheForResults;

/**
 *  Mark whether this is the first call to initWithAppKey.
 */
@property (nonatomic) BOOL isFirst;

/**
 *  Mark whether print log message.
 */
@property (nonatomic, assign) BOOL willPrintLogMsg;

/**
 *  Keeps all BCFileUploaderSimple objects before delegates are called.
 */
@property(nonatomic) NSMutableSet *setForUploaders;

/**
 *  Get the sharedInstance of BCCache.
 *
 *  @return BCCache shared instance.
 */
+ (instancetype)sharedInstance;

/*!
 Clear all cache.
 */
+ (void)clearAllCache;

#pragma mark - BCObject related methods
/** @name BCObject Related methods */

/*!
 Get cached type object for BCObject's refresh function to use. This function is *ONLY* called by BCObject's refresh
 function when BCQuery needs to generate BCObject. The cached copy will be deleted after one invocation of this
 function.
 */
- (id)getCachedTypeForClassName:(NSString *)className objectId:(NSString *)objectId;

/*!
 Get cached result object for BCObject's refresh function to use. This function is *ONLY* called by BCObject's refresh
 function when BCQuery needs to generate BCObject. The cached copy will be deleted after one invocation of this
 function.
 */
- (id)getCachedResultForClassName:(NSString *)className objectId:(NSString *)objectId;

/*!
 Add network reply to cache for a specific object in the given class. This function is *ONLY* called by BCQuery to pass
 contents to BCObject's refresh function.
 */
- (void)addResult:(id)result andType:(id)type toCacheForClassName:(NSString *)className objectId:(NSString *)objectId;

/**
 *  Clear result and type cache for the given objectId in the given class.
 *
 *  @param className Class name.
 *  @param objectId  objectId, which can be empty string.
 */
- (void)clearResultTypeCacheForClassName:(NSString *)className objectId:(NSString *)objectId;

/*!
 Returns the cached object if there is any, or nil otherwise.
 */
- (id)getCachedObjectForClassName:(NSString *)className objectId:(NSString *)objectId;

/*!
 Add BCObject object to cache.
 */
- (void)addObject:(id)object toCacheForClassName:(NSString *)className objectId:(NSString *)objectId;

@end
