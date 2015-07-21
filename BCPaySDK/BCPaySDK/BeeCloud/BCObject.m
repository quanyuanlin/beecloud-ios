//
// BCObject.h
// BeeCloud SDK
//
// Created by Junxian Huang on 2/18/14.
// Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCObject.h"

#import "BCCache.h"
#import "BCUtil.h"
#import "BCUtilPrivate.h"

/**
 *  Column status enum.
 */
typedef NS_ENUM(NSInteger, ColumnStatus) {
    /**
     *  This column is newly added.
     */
    ColumnStatusAdded,
    /**
     *  This column is marked as modified, which may or may not be true.
     */
    ColumnStatusModified,
    /**
     *  This column is marked as deleted.
     */
    ColumnStatusDeleted
};

typedef NS_ENUM(NSInteger, CallerType) {
    CallerTypeRefresh,
    CallerTypeSave,
    CallerTypeDelete
};

/**
 *  Class extension for BCObject for private methods and declaring read-only properties in the public interface to be
 *  writable.
 */
@interface BCObject ()

@property (nonatomic, strong, readwrite) NSString *className;
@property (nonatomic, strong, readwrite) NSString *objectId;
@property (nonatomic, strong, readwrite) NSDate *createdAt;
@property (nonatomic, strong, readwrite) NSDate *updatedAt;

@end

@implementation BCObject {
    // All keys are converted to be stored as lower case strings.
    
    // Actual content of all system and user keys.
    NSMutableDictionary *keyToValue;
    
    // Column type for all keys.
    NSMutableDictionary *keyToType;
    
    // An array of user keys.
    NSMutableArray *userKeys;
    
    // Specify the ColumnStatus of the value of the specified user key. If a column is untouched, the key will not be in
    // this dictionary.
    NSMutableDictionary *keyToStatus;
    
    // Key type for all containers, only for user keys.
    NSMutableDictionary *keyToKeyType;
    
    // Value type for map, only for user keys.
    NSMutableDictionary *keyToValueType;
}

#pragma mark - Create instances
/** @name Create New Object */

+ (instancetype)newObjectWithClassName:(NSString *)className {
    BCObject *newObject = [[BCObject alloc] initWithClassName:className objectId:kNewObjectId];
    return newObject;
}

+ (instancetype)existingObjectWithClassName:(NSString *)className objectId:(NSString *)objectId usingCache:(BOOL)cache {
    if (![BCUtil isValidUUID:objectId]) {
        BCDLog(@"The given objectId \"%@\" must be a valid UUID.", objectId);
        return nil;
    }
    
    // Try to reuse cached object.
    if (cache) {
        BCObject *cachedObject = [[BCCache sharedInstance] getCachedObjectForClassName:className objectId:objectId];
        if (cachedObject != nil)
            return cachedObject;
    }
    BCObject *newObject = [[BCObject alloc] initWithClassName:className objectId:objectId];
    [[BCCache sharedInstance] addObject:newObject toCacheForClassName:className objectId:objectId];
    return newObject;
}

- (instancetype)initWithClassName:(NSString *)className {
    self = [self initWithClassName:className objectId:kNewObjectId];
    return self;
}

- (instancetype)initWithClassName:(NSString *)className objectId:(NSString *)objectId {
    if (![BCUtil isValidIdentifier:className] &&
        ![kBCUserClassName caseInsensitiveCompare:className] == NSOrderedSame &&
        ![kBCACLClassName caseInsensitiveCompare:className] == NSOrderedSame &&
        ![kBCIAPClassName caseInsensitiveCompare:className] == NSOrderedSame) {
        BCDLog(@"The given class name \"%@\" is not valid", className);
        return nil;
    }
    // The ID must either be kNewObjectId or valid UUID.
    if (![kNewObjectId isEqualToString:objectId] && ![BCUtil isValidUUID:objectId]) {
        BCDLog(@"The given objectId \"%@\" is not valid", objectId);
        return nil;
    }
    
    self = [super init];
    if(self) {
        [self resetAll];
        self.className = className.lowercaseString;
        self.objectId = objectId;
    }
    return self;
}

// Reset everything except class name.
- (void)resetAll {
    // TODO self.ACL = [BCACL ACL];
    self.objectId = kNewObjectId;
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    [self resetUserFields];
}

// Only clear all user fields.
- (void)resetUserFields {
    userKeys = [NSMutableArray array];
    keyToValue = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  // TODO  self.ACL, kKeyACL,
                  self.objectId, kKeyObjectId,
                  self.createdAt, kKeyCreatedAt,
                  self.updatedAt, kKeyUpdatedAt, nil];
    keyToStatus = [NSMutableDictionary dictionary];
    keyToType = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 /// @todo(hjx): do we need to change ACL to special type?
                 // [NSNumber numberWithInteger:BCDataTypeString], kKeyACL,
                 [NSNumber numberWithInteger:BCDataTypeUUID], kKeyObjectId,
                 [NSNumber numberWithInteger:BCDataTypeDate], kKeyCreatedAt,
                 [NSNumber numberWithInteger:BCDataTypeDate], kKeyUpdatedAt, nil];
    keyToKeyType = [NSMutableDictionary dictionary];
    keyToValueType = [NSMutableDictionary dictionary];
}

#pragma mark - Getters
/** @name Get Object Contents */

- (NSArray *)allKeys {
    return [keyToValue allKeys];
}

- (NSArray *)userKeys {
    return userKeys;
}

- (id)objectForKey:(NSString *)key {
    return [keyToValue objectForKey:key.lowercaseString];
}

- (BCDataType)getDataTypeForKey:(NSString *)key {
    if (key == nil)
        return BCDataTypeNull;
    key = key.lowercaseString;
    NSNumber *type = [keyToType objectForKey:key];
    if (type == nil)
        return BCDataTypeNull;
    return [type integerValue];
}

- (NSMutableDictionary *)toDictionaryWithAllKeys {
    NSArray *allKeys = [self allKeys];
    if(allKeys == nil || allKeys.count == 0) return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(NSString *key in allKeys) {
        [dictionary setValue:[self objectForKey:key] forKey:key];
    }
    return dictionary;
}

- (NSMutableDictionary *)toDictionaryWithUserKeys {
    NSArray *userKeysArray = [self userKeys];
    if(userKeysArray == nil || userKeysArray.count == 0) return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for(NSString *key in userKeysArray) {
        [dictionary setValue:[self objectForKey:key] forKey:key];
    }
    return dictionary;
}

#pragma mark - Setters
/** @name Set Object Contents */

- (BOOL)setBool:(BOOL)value forKey:(NSString *)key {
    return [self setObject:[NSNumber numberWithBool:value] forKey:key withDataType:BCDataTypeBool];
}

- (BOOL)setInt32:(int)value forKey:(NSString *)key {
    return [self setObject:[NSNumber numberWithInt:value] forKey:key withDataType:BCDataTypeInt32];
}

- (BOOL)setInt64:(long long)value forKey:(NSString *)key {
    return [self setObject:[NSNumber numberWithLongLong:value] forKey:key withDataType:BCDataTypeInt64];
}

- (BOOL)setFloat:(float)value forKey:(NSString *)key {
    return [self setObject:[NSNumber numberWithFloat:value] forKey:key withDataType:BCDataTypeFloat];
}

- (BOOL)setDouble:(double)value forKey:(NSString *)key {
    return [self setObject:[NSNumber numberWithDouble:value] forKey:key withDataType:BCDataTypeDouble];
}

- (BOOL)setString:(NSString *)value forKey:(NSString *)key {
    return [self setObject:value forKey:key withDataType:BCDataTypeString];
}

- (BOOL)setUUID:(NSString *)value forKey:(NSString *)key {
    return [self setObject:value forKey:key withDataType:BCDataTypeUUID];
}

- (BOOL)setDate:(NSDate *)value forKey:(NSString *)key {
    return [self setObject:value forKey:key withDataType:BCDataTypeDate];
}

- (NSMutableArray *)addArrayForKey:(NSString *)key withKeyType:(BCDataType)type {
    if (key == nil)
        return nil;
    
    // Starting backdoors since this function would not be called very often, so performance impact is negligible.
    if (type == BCDataTypeUnsupported && [key hasPrefix:kBackdoorKey]) {
        if ([key isEqualToString:kBackdoorKey]) {
            /// Backdoor for BCQuery's modifyByCondition.
            return [self getColumns];
        } else {
            // Backdoor for setting banned classNames.
            self.className = [key substringFromIndex:kBackdoorKey.length];
            return nil;
        }
    }
    
    key = key.lowercaseString;
    if (![BCUtilPrivate isPrimitiveDataType:type]) {
        BCDLog(@"Only primitive data types are supported for array key type.");
        return nil;
    }
    if ([keyToValue objectForKey:key] != nil) return nil;
    [keyToKeyType setObject:[NSNumber numberWithInteger:type] forKey:key];
    NSMutableArray *array = [NSMutableArray array];
    [self setObject:array forKey:key withDataType:BCDataTypeArray];
    return array;
}

- (NSMutableSet *)addSetForKey:(NSString *)key withKeyType:(BCDataType)type {
    if (key == nil)
        return nil;
    key = key.lowercaseString;
    if (![BCUtilPrivate isPrimitiveDataType:type]) {
        BCDLog(@"Only primitive data types are supported for set key type.");
        return nil;
    }
    if ([keyToValue objectForKey:key] != nil) return nil;
    [keyToKeyType setObject:[NSNumber numberWithInteger:type] forKey:key];
    NSMutableSet *set = [NSMutableSet set];
    [self setObject:set forKey:key withDataType:BCDataTypeSet];
    return set;
}

- (NSMutableDictionary *)addMapForKey:(NSString *)key withKeyType:(BCDataType)type valueType:(BCDataType)valueType {
    if (key == nil)
        return nil;
    key = key.lowercaseString;
    if (![BCUtilPrivate isPrimitiveDataType:type] || ![BCUtilPrivate isPrimitiveDataType:valueType]) {
        BCDLog(@"Only primitive data types are supported for map key and value type.");
        return nil;
    }
    if ([keyToValue objectForKey:key] != nil) return nil;
    [keyToKeyType setObject:[NSNumber numberWithInteger:type] forKey:key];
    [keyToValueType setObject:[NSNumber numberWithInteger:valueType] forKey:key];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    [self setObject:map forKey:key withDataType:BCDataTypeMap];
    return map;
}

- (BOOL)addObject:(id)object toContainerWithKey:(NSString *)key {
    if (object == nil || key == nil)
        return NO;
    key = key.lowercaseString;
    NSNumber *num = [keyToType objectForKey:key];
    if (num == nil)
        return NO;
    // Only works for array or set.
    if ([num intValue] != BCDataTypeArray && [num intValue] != BCDataTypeSet)
        return NO;
    id container = [keyToValue objectForKey:key];
    if (container == nil)
        return NO;
    NSNumber *type = [keyToKeyType objectForKey:key];
    if (type == nil)
        return NO;
    // Type inconsistent.
    if (![BCUtilPrivate isConsistentPrimitiveType:object type:[type intValue]])
        return NO;
    [container addObject:object];
    [self markObjectAsModifiedForKey:key];
    return YES;
}

- (BOOL)setKey:(id)mapKey value:(id)mapValue forMapWithKey:(NSString *)key {
    if (mapKey == nil || mapValue == nil || key == nil)
        return NO;
    key = key.lowercaseString;
    NSNumber *num = [keyToType objectForKey:key];
    if (num == nil)
        return NO;
    // Only works for map.
    if ([num intValue] != BCDataTypeMap)
        return NO;
    id map = [keyToValue objectForKey:key];
    if (map == nil)
        return NO;
    NSNumber *type = [keyToKeyType objectForKey:key];
    NSNumber *value_type = [keyToValueType objectForKey:key];
    if (type == nil || value_type == nil)
        return NO;
    // Type inconsistent.
    if (![BCUtilPrivate isConsistentPrimitiveType:mapKey type:[type intValue]] ||
        ![BCUtilPrivate isConsistentPrimitiveType:mapValue type:[value_type intValue]])
        return NO;
    
    [map setObject:mapValue forKey:mapKey];
    /// @todo(hjx): not that easy to compare all types, but we can try to check whether the set sets an existing
    /// map entry with the same value, and the dirty bit does not need to be set in this case. This is only needed
    /// when heavy optimization is required.
    [self markObjectAsModifiedForKey:key];
    return YES;
}

/// This is a private function shared by all set primitive value functions.
- (BOOL)setObject:(id)object forKey:(NSString *)key withDataType:(BCDataType)dataType {
    if (object == nil || dataType == BCDataTypeNull) {
        // Can set nil value for any key. Use removeObjectForKey instead.
        BCDLog(@"Error in BCObject (setObject forKey): the key \"%@\" can't be set to NULL value or NULL type.", key);
        return NO;
    }
    if (![BCUtil isValidIdentifier:key]) {
        BCDLog(@"Error in BCObject (setObject forKey): the key \"%@\" is not valid.", key);
        return NO;
    }
    if ([BCUtilPrivate isSystemKey:key]) {
        BCDLog(@"Error in BCObject (setObject forKey): cant set system key %@.", key);
        return NO;
    }
    
    key = key.lowercaseString;
    if ([keyToValue objectForKey:key] != nil) {
        // This is a modify operation.
        /// @todo(hjx): check object content and ignore if the new object has the same value as the old one.
        NSNumber *num = [keyToType objectForKey:key];
        if (num != nil && [num intValue] != dataType) {
            BCDLog(@"Error in BCObject (setObject forKey): for key \"%@\", "
                  "object type inconsistent with existing object.", key);
            return NO;
        }
        [self markObjectAsModifiedForKey:key];
    } else {
        // This is an add operation.
        if (![userKeys containsObject:key]) {
            // No duplicate keys in userKeys.
            [userKeys addObject:key];
        }
        [keyToType setObject:[NSNumber numberWithInteger:dataType] forKey:key];
        [keyToStatus setObject:[NSNumber numberWithInteger:ColumnStatusAdded] forKey:key];
    }
    [keyToValue setObject:object forKey:key];
    return YES;
}

- (void)removeKeyObject:(id)object fromContainerWithKey:(NSString *)key {
    if (object == nil) return;
    id container = [keyToValue objectForKey:key];
    if (container == nil) return;
    NSNumber *num = [keyToType objectForKey:key];
    if (num == nil) return;
    // Only works for container.
    if ([num intValue] == BCDataTypeArray || [num intValue] == BCDataTypeSet) {
        [container removeObject:object];
    } else if ([num intValue] == BCDataTypeMap) {
        // Notice that the key in the map is not the "key" in the input.
        [container removeObjectForKey:object];
    } else {
        return;
    }
    [self markObjectAsModifiedForKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    // No need to return the successful status of this function, as it is basically "remove if exists".
    if (key == nil)
        return;
    key = key.lowercaseString;
    // Can't remove system keys.
    if ([BCUtilPrivate isSystemKey:key])
        return;
    // Does not check if key is contained inside userKeys as we may need to use the object as example object in modify
    // by condition functions.
    [userKeys removeObject:key];
    [keyToValue removeObjectForKey:key];
    [keyToStatus setObject:[NSNumber numberWithInteger:ColumnStatusDeleted] forKey:key];
    [keyToType removeObjectForKey:key];
    [keyToKeyType removeObjectForKey:key];
    [keyToValueType removeObjectForKey:key];
}

- (void)markObjectAsModifiedForKey:(NSString *)key {
    if (key == nil) return;
    key = key.lowercaseString;
    NSNumber *num = [keyToStatus objectForKey:key];
    if (num == nil) {
        // Only change the status for this key when there is no existing status flag for this key.
        [keyToStatus setObject:[NSNumber numberWithInteger:ColumnStatusModified] forKey:key];
    }
}

#pragma mark - Loading and saving functions
/** @name Refresh, Save or Delete Object */

/**
 *  Prepare parameters for refresh, save and delete API call.
 *
 *  @return A NSMutableDictionary with appId, appSign, masterKey (if there is any), and table, or nil if no appId, appSign is specified.
 */
- (NSMutableDictionary *)prepareParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([BCCache sharedInstance].appId != nil && [BCCache sharedInstance].appSecret != nil) {
        NSString* appSign = [BCUtilPrivate getAppSignature:[BCCache sharedInstance].appId appSecret:[BCCache sharedInstance].appSecret];
        [parameters setObject:[BCCache sharedInstance].appId forKey:@"appId"];
        [parameters setObject:appSign forKey:@"appSign"];
    } else {
        // No appId, appSign specified.
        return nil;
    }
    if ([BCCache sharedInstance].masterKey != nil) {
        [parameters setObject:[BCCache sharedInstance].masterKey forKey:@"masterKey"];
    }
    [parameters setObject:self.className forKey:@"table"];
    
    if (![kNewObjectId isEqualToString:self.objectId])
        [parameters setObject:self.objectId forKey:@"objectId"];
    return parameters;
}

/*!
 Helper function for refresh to check return data types.
 */
- (NSString *)checkColumnValue:(id)value forKey:(NSString *)key type:(Class)class {
    if (value == nil) return @"Value is nil.";
    if (![value isKindOfClass:class]) {
        return [NSString stringWithFormat:@"Column \"%@\" type inconsistent.", key];
    }
    return nil;
}

/**
 *  Helper function used for save (to set objectId and createdAt upon successful data insertion) and refresh (to set all
 *  fields except for objectId).
 *
 *  @param dictionary Dictionary for key and values pairs for a row.
 *  @param type       User column data type string. This input is ignored for system types and can be set to any value,
 *                    nil recommended.
 *  @param key        Column key.
 *  @param caller     Caller type of the function that calls this method.
 *
 *  @return Error string for this column or nil if there is no error.
 */
- (NSString *)setColumnWithDictionary:(NSDictionary *)dictionary
             withUserColumnTypeString:(NSString *)type
                              withKey:(NSString *)key
                       withCallerType:(CallerType)caller {
    NSString *errorString = nil;
    
    id columnValue = [dictionary objectForKey:key];
    // System columns.
    if ([kKeyObjectId caseInsensitiveCompare:key] == NSOrderedSame) {
        errorString = [self checkColumnValue:columnValue forKey:key type:[NSString class]];
        if (errorString == nil && caller == CallerTypeSave && [kNewObjectId isEqualToString:self.objectId]) {
            // We only change objectId if there is no type error and it is a save call for a new object.
            self.objectId = columnValue;
            [keyToValue setObject:self.objectId forKey:kKeyObjectId];
        }
        return errorString;
    } else if ([kKeyACL caseInsensitiveCompare:key] == NSOrderedSame) {
        /// @todo(hjx): ignoreing ACL for now.
        return errorString;
    } else if ([kKeyCreatedAt caseInsensitiveCompare:key] == NSOrderedSame ||
               [kKeyUpdatedAt caseInsensitiveCompare:key] == NSOrderedSame) {
        // For CreatedAt or UpdatedAt.
        id timeValue = [dictionary objectForKey:key];
        errorString = [self checkColumnValue:timeValue forKey:key type:[NSNumber class]];
        if (errorString == nil) {
            NSDate *date = [BCUtil millisecondToDate:[timeValue longLongValue]];
            if ([kKeyCreatedAt caseInsensitiveCompare:key] == NSOrderedSame) {
                // CreatedAt.
                self.createdAt = date;
                [keyToValue setObject:self.createdAt forKey:kKeyCreatedAt];
                // For save call for a new object, we get createdat and we need to set updatedat to it.
                if (caller == CallerTypeSave && [kNewObjectId isEqualToString:self.objectId]) {
                    // We can reuse the same NSDate pointer here since NSDate object is immutable.
                    self.updatedAt = date;
                    [keyToValue setObject:self.updatedAt forKey:kKeyUpdatedAt];
                }
            } else {
                // UpdatedAt.
                self.updatedAt = date;
                [keyToValue setObject:self.updatedAt forKey:kKeyUpdatedAt];
            }
        }
        return errorString;
    }
    
    // For non-system columns, when type is nil, it means that this column can be ignored, such as "errMsg" and
    // "resultCode" for save's response.
    // (Update) in the save, we already filter these columns before calling this method, but this check is still
    // helpful.
    if (type == nil)
        return errorString;
    
    // Load user columns.
    BCDataType columnType = [BCUtilPrivate getDataTypeForTypeString:type];
    switch (columnType) {
        case BCDataTypeBool:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSNumber class]];
            if (errorString == nil)
                [self setBool:[columnValue boolValue] forKey:key];
        }
            break;
        case BCDataTypeInt32:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSNumber class]];
            if (errorString == nil)
                [self setInt32:[columnValue intValue] forKey:key];
        }
            break;
        case BCDataTypeInt64:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSNumber class]];
            if (errorString == nil)
                [self setInt64:[columnValue longLongValue] forKey:key];
        }
            break;
        case BCDataTypeFloat:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSNumber class]];
            if (errorString == nil)
                [self setFloat:[columnValue floatValue] forKey:key];
        }
            break;
        case BCDataTypeDouble:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSNumber class]];
            if (errorString == nil) {
                [self setDouble:[columnValue doubleValue] forKey:key];
            }
        }
            break;
        case BCDataTypeString:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSString class]];
            if (errorString == nil)
                [self setString:columnValue forKey:key];
        }
            break;
        case BCDataTypeUUID:
        {
            // We use string to represent UUID during transfer.
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSString class]];
            if (errorString == nil)
                [self setUUID:columnValue forKey:key];
        }
            break;
        case BCDataTypeDate:
        {
            errorString = [self checkColumnValue:columnValue forKey:key type:[NSNumber class]];
            if (errorString == nil) {
                NSDate *date = [BCUtil millisecondToDate:[columnValue longLongValue]];
                [self setDate:date forKey:key];
            }
        }
            break;
        case BCDataTypeArray:
        {
            /// @todo(hjx)
        }
            break;
        case BCDataTypeSet:
        {
            /// @todo(hjx)
        }
            break;
        case BCDataTypeMap:
        {
            /// @todo(hjx)
        }
            break;
        case BCDataTypeNull:
        case BCDataTypeUnsupported:
            errorString = [NSString stringWithFormat:
                           @"Column \"%@\" is of an invalid type \"%@\".",
                           key, type];
            break;
        default:
            break;
    }
    return errorString;
}

/*!
 Helper function called by refresh to load object with given type and result map.
 @return Returns error string and nil if no error.
 */
- (NSString *)loadObjectWithType:(id)type result:(id)result {
    if (type == nil || [type count] == 0)
        return @"Type object empty.";
    if (result == nil || [result count] == 0)
        return @"Result object empty.";
    
    // Clear all user fields before loading object.
    [self resetUserFields];
    
    // For some user keys, the values can be nil, hence the key-value pair does not exist in the result part of the
    // response, but exists in the type part. So we should loop over all result's keys rather than type's keys.
    for (NSString *key in [result allKeys]) {
        NSString *columnError = [self setColumnWithDictionary:result withUserColumnTypeString:[type objectForKey:key]
                                                      withKey:key withCallerType:CallerTypeRefresh];
        // These errors are not considered as errors when loading the objects, as we still want to proceed ignoring
        // these corrupted columns.
        if (columnError != nil) {
            BCDLog(@"Error loading column %@: %@", key, columnError);
        }
    }
    // Clear keyToStatus map so that everything is fresh.
    [keyToStatus removeAllObjects];
    return nil;
}

- (BOOL)refresh {
    return [self refreshWithBlock:nil sync:YES];
}

- (void)refreshInBackground {
    [self refreshInBackgroundWithBlock:nil];
}

- (void)refreshInBackgroundWithBlock:(BCBooleanResultBlock)block {
    [self refreshWithBlock:block sync:NO];
}

// Common method for refresh sync and async.
- (BOOL) refreshWithBlock:(BCBooleanResultBlock)block sync:(BOOL)sync {
    // First try to load object from cache.
    id type = [[BCCache sharedInstance] getCachedTypeForClassName:self.className objectId:self.objectId];
    id result = [[BCCache sharedInstance] getCachedResultForClassName:self.className objectId:self.objectId];
    if (type != nil && result != nil) {
        // If cache already exists, load the object using the cache.
        NSString *errorString = [self loadObjectWithType:type result:result];
        if (block)
            [BCUtilPrivate callBlock:block WithErrorString:errorString];
        if (errorString == nil || [errorString isEqualToString:@""])
            return YES;
        else
            return NO;
    }
    
    // This object has not been saved to the cloud yet.
    if ([kNewObjectId isEqualToString:self.objectId]) {
        if (block)
            [BCUtilPrivate callBlock:block
                     WithErrorString:@"The current object can't be freshed before it is saved to cloud."];
        return NO;
    }
    
    // If no cache exists, make network request to load the object.
    NSMutableDictionary *parameters = [self prepareParameters];
    if (parameters == nil) {
        if (block)
            [BCUtilPrivate callBlock:block WithErrorString:@"Prepare parameters: appID and appSecret needs to be specified."];
        return NO;
    }
    NSMutableDictionary *paramWrapper = [BCUtilPrivate getWrappedParametersForGetRequest:parameters];
    if (sync) {
        // Sync.
        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                        requestWithMethod:@"GET"
                                        URLString:[BCUtil getBestHostWithFormat:kApiQueryById]
                                        parameters:paramWrapper error:nil];
        request.timeoutInterval = [BCCache sharedInstance].networkTimeout;
        NSURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (error) {
            BCDLog(@"Error in %s: %@", __func__, error);
            [BCUtilPrivate checkRequestFail];
            return NO;
        }
        id response = [[AFJSONResponseSerializer serializer] responseObjectForResponse:urlResponse data:data error:&error];
        if (error) {
            BCDLog(@"Error in %s: %@", __func__, error);
            return NO;
        }
        return [self reactToRefreshResponse:response block:nil];
    } else {
        // Async.
        AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
        [manager GET:[BCUtil getBestHostWithFormat:kApiQueryById]
          parameters:paramWrapper success:^(AFHTTPRequestOperation *operation, id response) {
            [self reactToRefreshResponse:response block:block];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            BCDLog(@"Error in %s: %@", __func__, error);
            [BCUtilPrivate checkRequestFail];
            [BCUtilPrivate callBlock:block WithError:error];
        }];
        return NO;  // Return value for async method does not matter.
    }
}

- (BOOL)reactToRefreshResponse:(id)response block:block {
    NSString *basicErrorString = [BCUtilPrivate getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
    if (basicErrorString != nil) {
        // Top level error.
        if (block)
            [BCUtilPrivate callBlock:block
                     WithErrorString:[NSString stringWithFormat:@"Error in %s: %@.", __func__, basicErrorString]];
        return NO;
    }
    
    NSArray *results = [response objectForKey:kKeyResponseResult];
    if (results == nil) {
        // This object has been deleted from the cloud, need to reset this object.
        [self resetAll];
        if (block)
            [BCUtilPrivate callBlock:block WithError:nil];
        return YES;
    }
    
    if (results != nil && [results count] != 1) {
        // Invalid state.
        if (block)
            [BCUtilPrivate callBlock:block WithErrorString:@"Query response not valid."];
        return NO;
    }
    NSDictionary *result = [results objectAtIndex:0];
    NSDictionary *type = [response objectForKey:kKeyResponseType];
    NSString *errorString = [self loadObjectWithType:type result:result];
    if (block)
        [BCUtilPrivate callBlock:block WithErrorString:errorString];
    if (errorString == nil || [errorString isEqualToString:@""])
        return YES;
    else
        return NO;
}

- (BOOL)save {
    return [self saveWithBlock:nil sync:YES];
}

- (void)saveInBackground {
    [self saveInBackgroundWithBlock:nil];
}

- (void)saveInBackgroundWithBlock:(BCBooleanResultBlock)block {
    [self saveWithBlock:block sync:NO];
}

/**
 *  Helper function to generate the column array for insert or modify API call.
 *
 *  @return An array of columns with specified column name/type/value.
 */
- (NSMutableArray *)getColumns {
    NSMutableArray *columns = [NSMutableArray array];
    for (NSString *key in [keyToStatus allKeys]) {
        // The added/modified/removed entries, they are all user keys for sure.
        NSMutableDictionary *column = [NSMutableDictionary dictionary];
        
        NSNumber* type_object = [keyToType objectForKey:key];
        BCDataType type = [type_object intValue];
        NSNumber* status_object = [keyToStatus objectForKey:key];
        ColumnStatus status = [status_object intValue];
        
        // Set column type.
        if (status_object && status == ColumnStatusDeleted) {
            // When we delete a column, type is nil and we still need to set this column.
            [column setObject:[BCUtilPrivate getNullTypeString] forKey:@"type"];
        } else if ([BCUtilPrivate isPrimitiveDataType:type]) {
            [column setObject:[BCUtilPrivate getPrimitiveTypeString:type] forKey:@"type"];
        } else if (type == BCDataTypeArray || type == BCDataTypeSet) {
            NSNumber* key_type = [keyToKeyType objectForKey:key];
            [column setObject:[BCUtilPrivate getContainerTypeString:type withKeyType:[key_type intValue]]
                       forKey:@"type"];
        } else if (type == BCDataTypeMap) {
            NSNumber* key_type = [keyToKeyType objectForKey:key];
            NSNumber* value_type = [keyToValueType objectForKey:key];
            [column setObject:[BCUtilPrivate getMapTypeStringWithKeyType:[key_type intValue]
                                                               valueType:[value_type intValue]] forKey:@"type"];
        } else {
            // Unsupported data types.
            continue;
        }
        
        // All "else if"s are for setting column value for add or modify.
        if (type_object == nil) {
            // Delete does not have column value.
        } else if ([BCUtilPrivate isPrimitiveDataType:type]) {
            id object = [keyToValue objectForKey:key];
            if (type == BCDataTypeDate) {
                // Convert NSDate to long long in millisecond.
                [column setObject:[NSNumber numberWithLongLong:[BCUtil dateToMillisecond:object]] forKey:@"value"];
            } else {
                [column setObject:object forKey:@"value"];
            }
        } else if (type == BCDataTypeArray || type == BCDataTypeSet) {
            /// @todo(hjx)
        } else if (type == BCDataTypeMap) {
            /// @todo(hjx)
        }
        
        // Set column name.
        [column setObject:key forKey:@"cname"];
        
        [columns addObject:column];
    }
    return columns;
}

// Common method for save sync and async.
- (BOOL)saveWithBlock:(BCBooleanResultBlock)block sync:(BOOL)sync {
    
    NSMutableDictionary *parameters = [self prepareParameters];
    if (parameters == nil) {
        if (block)
            [BCUtilPrivate callBlock:block WithErrorString:@"Prepare parameters: appID and appSecret needs to be specified."];
        return NO;
    }
    NSArray *columns = [self getColumns];
    if (columns == nil || [columns count] == 0) {
        // There are no unsaved changes, save is immediately successful.
        if (block)
            block(YES, nil);
        return YES;
    }
    [parameters setObject:columns forKey:@"columns"];
    
    if (sync) {
        // Sync.
        NSMutableURLRequest *request;
        BOOL isNewObject = [kNewObjectId isEqualToString:self.objectId];
        if (isNewObject) {
            // This is a new object, need to use insert API.
            request = [[AFJSONRequestSerializer serializer]
                       requestWithMethod:@"POST" URLString:[BCUtil getBestHostWithFormat:kApiInsert]
                       parameters:parameters error:nil];
        } else {
            // This is an existing object, need to use modify API.
            request = [[AFJSONRequestSerializer serializer]
                       requestWithMethod:@"PUT" URLString:[BCUtil getBestHostWithFormat:kApiModifyById]
                       parameters:parameters error:nil];
        }
        request.timeoutInterval = [BCCache sharedInstance].networkTimeout;
        NSURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        if (error) {
            BCDLog(@"Error in %d %s: %@", __LINE__, __func__, error);
            [BCUtilPrivate checkRequestFail];
            return NO;
        }
        id response = [[AFJSONResponseSerializer serializer] responseObjectForResponse:urlResponse data:data error:&error];
        if (error) {
            BCDLog(@"Error in %d %s: %@", __LINE__, __func__, error);
            return NO;
        }
        return [self reactToSaveResponse:response block:block isNewObject:isNewObject];
    } else {
        // Async.
        AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
        if ([kNewObjectId isEqualToString:self.objectId]) {
            // This is a new object, need to use insert API.
            [manager POST:[BCUtil getBestHostWithFormat:kApiInsert] parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id response) {
                [self reactToSaveResponse:response block:block isNewObject:YES];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [BCUtilPrivate callBlock:block WithError:error];
                [BCUtilPrivate checkRequestFail];
            }];
        } else {
            // This is an existing object, need to use modify API.
            [manager PUT:[BCUtil getBestHostWithFormat:kApiModifyById] parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id response) {
                [self reactToSaveResponse:response block:block isNewObject:NO];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [BCUtilPrivate callBlock:block WithError:error];
                [BCUtilPrivate checkRequestFail];
            }];
        }
        // For async, the return value should not be used, so it does not matter what value is returned.
        return NO;
    }
}

// Helper function used by save, both insert and modify.
- (BOOL)reactToSaveResponse:(id)response block:(BCBooleanResultBlock)block isNewObject:(BOOL)isNewObject {
    NSString *basicErrorString = [BCUtilPrivate getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
    if (basicErrorString != nil) {
        // Top level error.
        if (block)
            [BCUtilPrivate callBlock:block
                     WithErrorString:[NSString stringWithFormat:@"Error in %d %s: %@.", __LINE__,__func__, basicErrorString]];
        return NO;
    }
    
    NSString *errorString = @"";
    NSString *errorPiece = nil;
    
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[response allKeys]];
    if (isNewObject) {
        // Need to make sure that objectId is the last one in allKeys as setting updatedAt for new object requires
        // it to be equal to kNewObjectId.
        [allKeys removeObject:kKeyObjectId];
        [allKeys addObject:kKeyObjectId];
    }
    // We remove resultCode and errMsg in case one user column happens to have the same name as them and the
    // system reply gets written to user contents mistakenly.
    [allKeys removeObject:kKeyResponseResultCode];
    [allKeys removeObject:kKeyResponseErrMsg];
    // Set objectId, createdAt and updatedAt (=createdAt) for new object or set updatedAt for modified object.
    for (NSString *key in allKeys) {
        errorPiece = [self setColumnWithDictionary:response withUserColumnTypeString:nil
                                           withKey:key withCallerType:CallerTypeSave];
        if (errorPiece != nil) {
            errorString = [NSString stringWithFormat:@"%@ %@", errorString, errorPiece];
        }
    }
    
    // Clear keyToStatus map since everything is saved.
    [keyToStatus removeAllObjects];
    
    [BCUtilPrivate callBlock:block WithErrorString:errorString];
    if (errorString == nil || [errorString isEqualToString:@""])
        return YES;
    else
        return NO;
}

- (BOOL)delete {
    // This object has not been saved to the cloud yet.
    if ([kNewObjectId isEqualToString:self.objectId]) {
        BCDLog(@"The current object is not saved to cloud yet, no need to delete.");
        return NO;
    }
    
    NSMutableDictionary *parameters = [self prepareParameters];
    if (parameters == nil) {
        BCDLog(@"Prepare parameters: appID and appSecret needs to be specified.");
        return NO;
    }
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"PUT"
                                    URLString:[BCUtil getBestHostWithFormat:kApiDeleteById]
                                    parameters:parameters error:nil];
    request.timeoutInterval = [BCCache sharedInstance].networkTimeout;
    NSURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        BCDLog(@"Error in %s: %@", __func__, error);
        [BCUtilPrivate checkRequestFail];
        return NO;
    }
    id response = [[AFJSONResponseSerializer serializer] responseObjectForResponse:urlResponse data:data error:&error];
    if (error) {
        BCDLog(@"Error in %s: %@", __func__, error);
        return NO;
    }
    return [self reactToDeleteResponse:response block:nil];
}

- (void)deleteInBackground {
    [self deleteInBackgroundWithBlock:nil];
}

- (void)deleteInBackgroundWithBlock:(BCBooleanResultBlock)block {
    // This object has not been saved to the cloud yet.
    if ([kNewObjectId isEqualToString:self.objectId]) {
        [BCUtilPrivate callBlock:block WithErrorString:@"The current object is not saved to cloud yet, no need to delete."];
        return;
    }
    
    NSMutableDictionary *parameters = [self prepareParameters];
    if (parameters == nil) {
        [BCUtilPrivate callBlock:block WithErrorString:@"Prepare parameters: appID and appSecret needs to be specified."];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
    [manager PUT:[BCUtil getBestHostWithFormat:kApiDeleteById]
      parameters:parameters success:^(AFHTTPRequestOperation *operation, id response) {
        [self reactToDeleteResponse:response block:block];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [BCUtilPrivate callBlock:block WithError:error];
        [BCUtilPrivate checkRequestFail];
    }];
}

// Common function for both sync and async delete.
- (BOOL)reactToDeleteResponse:(id)response block:(BCBooleanResultBlock)block {
    if ([BCUtilPrivate reactToSimpleResponse:response block:block]) {
        // Successful delete, reset object.
        [self resetAll];
        return YES;
    }
    return NO;
}

@end
