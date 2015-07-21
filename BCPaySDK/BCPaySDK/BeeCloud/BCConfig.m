//
//  BCConfig.m
//  BeeCloud
//
//  Created by Junxian Huang on 7/31/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCConfig.h"

#import "BCCache.h"
#import "BCObject.h"
#import "BCQuery.h"
#import "BCUtil.h"
#import "BCUtilPrivate.h"

/**
 *  Last download time of a config object, this is set by SDK and should not be saved to the cloud.
 */
static NSString * const kKeyLastDownloadTime = @"lastDownloadTime";
static NSString * const kKeyName = @"name";
static NSString * const kKeyType = @"type";
static NSString * const kKeyValue = @"value";
static NSString * const kKeyTTL = @"TTL";

static NSString * const kErrorFormat = @"BCConfig error: config not found or type mismatch (%@ expected)";

@implementation BCConfig

/**
 *  Helper function called by all config getter functions to get a BCObject for the given config name. It tries to use
 *  the cached object if it has not expired.
 *
 *  @param name Config name.
 *
 *  @return BCObject for that config, or nil of the config object can not be found.
 */
+ (BCObject *)getObjectWithName:(NSString *)name {
    if (name == nil || name.length == 0)
        return nil;
    BCObject *object = [[BCCache sharedInstance] getCachedObjectForClassName:kBCConfigClassName objectId:name];
    if (object != nil) {
        // Decide whether to use cached object
        NSDate *lastDownloadTime = [object objectForKey:kKeyLastDownloadTime];
        NSNumber *ttl = [object objectForKey:kKeyTTL];
        // TTL is in millisecond.
        NSTimeInterval ttl_sec = (double)[ttl longLongValue] / 1000.0;
        if (lastDownloadTime != nil && ttl != nil) {
            if ([[NSDate date] timeIntervalSinceDate:lastDownloadTime] <= ttl_sec) {
                // Cache age <= TTL, use cache.
                return object;
            }
        }
    }
    // Fetch config object from cloud.
    BCQuery *q = [BCQuery queryWithClassName:kBCConfigClassName];
    [q whereKey:kKeyName equalTo:name];
    NSArray *objects = [q findObjects];
    if (objects == nil || [objects count] == 0)
        return nil;
    
    if ([objects count] >= 2)
        BCDLog(@"BCConfig Error: There are %d config objects with name \"%@\".", (int)[objects count], name);
    
    object = objects[0];
    [object setDate:[NSDate date] forKey:kKeyLastDownloadTime];
    // Set cache.
    [[BCCache sharedInstance] addObject:object toCacheForClassName:kBCConfigClassName objectId:name];
    return object;
}

+ (BOOL)getBoolWithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeBool]) {
        BCDLog(kErrorFormat, kTypeEncodeBool);
        return NO;
    }
    return [[config objectForKey:kKeyValue] boolValue];
}

+ (int)getInt32WithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeInt32]) {
        BCDLog(kErrorFormat, kTypeEncodeInt32);
        return 0;
    }
    return [[config objectForKey:kKeyValue] intValue];
}

+ (long long)getInt64WithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeInt64]) {
        BCDLog(kErrorFormat, kTypeEncodeInt64);
        return 0;
    }
    return [[config objectForKey:kKeyValue] longLongValue];
}

+ (float)getFloatWithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeFloat]) {
        BCDLog(kErrorFormat, kTypeEncodeFloat);
        return 0.0;
    }
    return [[config objectForKey:kKeyValue] floatValue];
}

+ (double)getDoubleWithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeDouble]) {
        BCDLog(kErrorFormat, kTypeEncodeDouble);
        return 0.0;
    }
    return [[config objectForKey:kKeyValue] doubleValue];
}

+ (NSString *)getStringWithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeString]) {
        BCDLog(kErrorFormat, kTypeEncodeString);
        return nil;
    }
    return [config objectForKey:kKeyValue];
}

+ (NSString *)getUUIDWithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeUUID]) {
        BCDLog(kErrorFormat, kTypeEncodeUUID);
        return nil;
    }
    return [config objectForKey:kKeyValue];
}

+ (NSDate *)getDateWithName:(NSString *)name {
    BCObject *config = [BCConfig getObjectWithName:name];
    if (config == nil || ![[config objectForKey:kKeyType] isEqualToString:kTypeEncodeDate]) {
        BCDLog(kErrorFormat, kTypeEncodeDate);
        return nil;
    }
    NSString *value = [config objectForKey:kKeyValue];
    return [BCUtil millisecondToDate:[value longLongValue]];
}

@end
