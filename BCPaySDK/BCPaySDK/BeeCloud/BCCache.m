//
//  BCCache.m
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/27/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCCache.h"

#import "BCQuery.h"
#import "BCUtil.h"
#import "BCUtilPrivate.h"

static NSString * const kIdConnector = @",";

@implementation BCCache

@synthesize cacheForObjects;
@synthesize cacheForTypes;
@synthesize cacheForResults;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCCache alloc] init];
        
        instance.appId = nil;
        instance.appSecret = nil;
        instance.masterKey = nil;
        instance.networkTimeout = 5.0;
        
        instance.currentLatitude = 0.0;
        instance.currentLongitude = 0.0;
        
        instance.userId = nil;
        instance.userPayStatus = nil;
        instance.userGender = nil;
        instance.userAge = nil;
        
        instance.cacheForObjects = [NSMutableDictionary dictionary];
        instance.cacheForTypes = [NSMutableDictionary dictionary];
        instance.cacheForResults = [NSMutableDictionary dictionary];
        instance.hostRTTMap = [NSMutableDictionary dictionary];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *besthost = [userDefault objectForKey:kKeyBestHost];
      
        if ([BCUtil isValidString:besthost]) {
            instance.bestHost = besthost;
        } else {
            instance.bestHost = kBCHosts[(arc4random() % kBCHostCount)];
        }
        
        instance.isFirst = YES;
        
        instance.willPrintLogMsg = NO;
        
        instance.setForUploaders = [NSMutableSet set];
        
      });
    return instance;
}

+ (void)clearAllCache {
    [[BCCache sharedInstance].cacheForObjects removeAllObjects];
    [[BCCache sharedInstance].cacheForTypes removeAllObjects];
    [[BCCache sharedInstance].cacheForResults removeAllObjects];
}

/**
 *  Helper function to generate a cache ID from the given className and objectId.
 *
 *  @param className Class name of the cached object.
 *  @param objectId  ObjectId of the cached object, or other types if IDs, such as config names for a config object.
 *
 *  @return A string by concatinating className and objectId with a connector.
 */
+ (NSString *)getCacheIdForClassName:(NSString *)className objectId:(NSString *)objectId {
    if (className == nil || objectId == nil) return nil;
    NSString *cacheId = [NSString stringWithFormat:@"%@%@%@", className, kIdConnector, objectId];
    return cacheId.lowercaseString;
}

- (id)getCachedTypeForClassName:(NSString *)className objectId:(NSString *)objectId {
    NSString *cacheId = [BCCache getCacheIdForClassName:className objectId:objectId];
    if (cacheId == nil) return nil;
    NSDictionary *type = [cacheForTypes objectForKey:cacheId];
    [cacheForTypes removeObjectForKey:cacheId];
    return type;
}

- (id)getCachedResultForClassName:(NSString *)className objectId:(NSString *)objectId {
    NSString *cacheId = [BCCache getCacheIdForClassName:className objectId:objectId];
    if (cacheId == nil) return nil;
    NSDictionary *result = [cacheForResults objectForKey:cacheId];
    [cacheForResults removeObjectForKey:cacheId];
    return result;
}

- (void)addResult:(id)result andType:(id)type toCacheForClassName:(NSString *)className objectId:(NSString *)objectId {
    NSString *cacheId = [BCCache getCacheIdForClassName:className objectId:objectId];
    if (cacheId == nil) return;
    [cacheForTypes setObject:type forKey:cacheId];
    [cacheForResults setObject:result forKey:cacheId];
}

- (id)getCachedObjectForClassName:(NSString *)className objectId:(NSString *)objectId {
    NSString *cacheId = [BCCache getCacheIdForClassName:className objectId:objectId];
    if (cacheId == nil) return nil;
    id object = [cacheForObjects objectForKey:cacheId];
    return object;
}

- (void)addObject:(id)object toCacheForClassName:(NSString *)className objectId:(NSString *)objectId {
    NSString *cacheId = [BCCache getCacheIdForClassName:className objectId:objectId];
    if (cacheId == nil) return;
    [cacheForObjects setObject:object forKey:cacheId];
}

- (void)clearResultTypeCacheForClassName:(NSString *)className objectId:(NSString *)objectId {
    NSString *cacheId = [BCCache getCacheIdForClassName:className objectId:objectId];
    if (cacheId == nil) return;
    [cacheForTypes removeObjectForKey:cacheId];
    [cacheForResults removeObjectForKey:cacheId];
}

@end
