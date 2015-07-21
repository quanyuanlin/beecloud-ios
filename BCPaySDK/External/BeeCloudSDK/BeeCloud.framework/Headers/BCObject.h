//
// BCObject.h
// BeeCloud SDK
//
// Created by Junxian Huang on 2/18/14.
// Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCConstants.h"
#import "BCLocation.h"

/**
 *  The basic element for BeeCloud data storage. A BCObject can be considered as a row in MySQL table with objectId as
 *  key, and various columns.
 */
@interface BCObject : NSObject

#pragma mark - Properties
/** @name Class Properties */

/**
 *  Each object can be considered as a row in MySQL table and this class name is the table name. All classNames are
 *  lower case strings.
 */
@property (nonatomic, strong, readonly) NSString *className;

/*!
 The object ID is a unique ID bound to this object, which looks like "BE5BA3D0-971C-4418-9ECF-E2D1ABCB66BE", it is
 allocated to the object automatically from the cloud during the first save operation. This is a system column, you
 can't modify or delete it.
 
 If objectId is @"", it means that the current object has not been saved to the cloud yet, and after a successful save,
 the objectId will be allocated from the cloud.
 */
@property (nonatomic, strong, readonly) NSString *objectId;

/**
 *  The time when this object is created. This is a system column, you can't modify or delete it.
 */
@property (nonatomic, strong, readonly) NSDate *createdAt;

/**
 *  The last time when this object is updated. This is a system column, you can't modify or delete it.
 */
@property (nonatomic, strong, readonly) NSDate *updatedAt;

#pragma mark - Create instances
/** @name Create New Object */

/*!
 Creates a new BCObject with a class name, the object can be viewed as a row in the table and the class name is the
 table name. The object does not exist in the cloud yet and the objectId is @"" until the first successful save
 operation.
 @param className A class name is a letter followed by any sequence of letters, digits, or the underscore (_). The class
 name is case insensitive and will be converted to lower case string. The class name ending with two underscores, such
 as "class__" are not permitted.
 @return Returns the object that is instantiated with the given class name and nil if the given class name is invalid.
 */
+ (instancetype)newObjectWithClassName:(NSString *)className;

/*!
 Creates an existing BCObject that exists in the cloud with the given class name and objectId. If you want to download
 all object information from the cloud, call the refresh function. If for some reason, the given ID does not exist in
 the cloud, the refresh function will fail and do nothing.
 @param className A class name is a letter followed by any sequence of letters, digits, or the underscore (_). The class
 name is case insensitive and will be converted to lower case string. The class name ending with two underscores, such
 as "class__" are not permitted.
 @param objectId The objectId must be an UUID in the format of "550e8400-e29b-41d4-a716-446655440000".
 @param cache Specifies whether to use local cached copy of this object if you have created this object previously. To
 make sure that the cached copy is not used, set cache to NO. You can clear all caches via "[BeeCloud clearAllCache];".
 @return Returns a new BCObject object.
 */
+ (instancetype)existingObjectWithClassName:(NSString *)className objectId:(NSString *)objectId usingCache:(BOOL)cache;

/*!
 Initializes a new BCObject with a class name, the object can be viewed as a row in the table and the class name is the
 table name. The object does not exist in the cloud yet and the objectId is @"" until the first successful save
 operation.
 @param className A class name is a letter followed by any sequence of letters, digits, or the underscore (_). The class
 name is case insensitive and will be converted to lower case string. The class name ending with two underscores, such
 as "class__" are not permitted.
 @return Returns the object that is instantiated with the given class name and nil if the given class name is invalid.
 */
- (instancetype)initWithClassName:(NSString *)className;

/*!
 Creates an existing BCObject that exists in the cloud with the given class name and objectId. If you want to download
 all object information from the cloud, call the refresh function. If for some reason, the given ID does not exist in
 the cloud, the refresh function will fail and do nothing.
 @param className A class name is a letter followed by any sequence of letters, digits, or the underscore (_). The class
 name is case insensitive and will be converted to lower case string. The class name ending with two underscores, such
 as "class__" are not permitted.
 @param objectId The objectId must be an UUID in the format of "550e8400-e29b-41d4-a716-446655440000".
 @return Returns a new BCObject object.
 */
- (instancetype)initWithClassName:(NSString *)className objectId:(NSString *)objectId;

#pragma mark - Getters
/** @name Get Object Contents */

/*!
 Returns an array of the keys contained in this object. This includes everything, including "objectid", "createdat"
 and "updatedat". Notice that className is not a key of the object, and hence not included. All keys are lower case
 strings.
 */
- (NSArray *)allKeys;

/*!
 Returns an array of all the user-generated keys contained in this object. This does NOT include system keys. This does
 not include className either. All keys are lower case strings.
 */
- (NSArray *)userKeys;

/**
 *  Returns the object associated with a given key. The key is case-insensitive, i.e., "game" and "GAME" all point to
 *  the same object. The key is a letter followed by any sequence of letters, digits, or the underscore (_). The key
 *  ending with two underscores, such as "key__" are not permitted.
 *
 *  @param key The key that the column is associated with.
 *
 *  @return The value associated with the given key, or nil if the key is not present or even if the key is present, no
 *          value is associated with it. Notice that for bool and number data types, the returned object is a NSNumber
 *          object, and you need to use the corresponding data methods to access the numerical value, such as
 *          [nsNumberObject boolValue].
 */
- (id)objectForKey:(NSString *)key;

/**
 *  Get the BCDataType associated with the given key. If there is no value associated with the given key (even though
 *  the table has this column in the cloud), BCDataTypeNull will be returned.
 *
 *  It is possible for a table to have a column, for example, "score" with type double, but however, for the current
 *  BCObject, the value associated with "score" is null, instead of returning BCDataTypeDouble, BCDataTypeNull will be
 *  returned.
 *
 *  If you have never called any save or refresh methods, the data type is purely determined by the local copy of the
 *  object, which might be inconsistent from the cloud. This should be avoided during the application development
 *  process.
 *
 *  @param key The associated column key. If key is nil, BCDataTypeNull will be returned.
 *
 *  @return The corresponding BCDataType, and BCDataTypeNull if there is no value associated with this key.
 */
- (BCDataType)getDataTypeForKey:(NSString *)key;

/**
 *  Convert BCObject to NSMutableDictionary for all keys.
 *
 *  @return nil or mutableDictionary with allKeys
 */
- (NSMutableDictionary *)toDictionaryWithAllKeys;

/**
 *  Convert BCObject to NSMutableDictionary for user keys.
 *
 *  @return nil or mutableDictionary with userKeys
 */
- (NSMutableDictionary *)toDictionaryWithUserKeys;

#pragma mark - Setters
/** @name Set Object Contents */

/**
 *  Sets BOOL value associated with a given key.
 *
 *  The operation could fail if the existing column associated with the key has a different type.
 *
 *  @param value The value to be set.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setBool:(BOOL)value forKey:(NSString *)key;

/**
 *  Sets 32-bit integer value associated with a given key.
 *
 *  The operation could fail if the existing column associated with the key has a different type.
 *
 *  @param value The value to be set.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setInt32:(int)value forKey:(NSString *)key;

/**
 *  Sets 64-bit integer value associated with a given key.
 *
 *  The operation could fail if the existing column associated with the key has a different type.
 *
 *  @param value The value to be set.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setInt64:(long long)value forKey:(NSString *)key;

/**
 *  Sets float value associated with a given key.
 *
 *  The operation could fail if the existing column associated with the key has a different type.
 *
 *  @param value The value to be set.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setFloat:(float)value forKey:(NSString *)key;

/**
 *  Sets double value associated with a given key.
 *
 *  The operation could fail if the existing column associated with the key has a different type.
 *
 *  @param value The value to be set.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setDouble:(double)value forKey:(NSString *)key;

/**
 *  Sets string value associated with a given key.
 *
 *  The operation could fail if value is nil, or the existing column associated with the key has a different type.
 *
 *  @param value The value to be set. It can be "" (empty string), but must not be nil.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setString:(NSString *)value forKey:(NSString *)key;

/**
 *  Sets UUID value associated with a given key.
 *  
 *  The operation could fail if value is nil, or the existing column associated with the key has a different type.
 *
 *  @param value The value to be set. The input must be standard UUID, e.g., E621E1F8-C36C-495A-93FC-0C247A3E6E5F.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setUUID:(NSString *)value forKey:(NSString *)key;

/**
 *  Sets date value associated with a given key.
 *
 *  The operation could fail if value is nil, or the existing column associated with the key has a different type.
 *
 *  @param value The value to be set. It must not be nil.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setDate:(NSDate *)value forKey:(NSString *)key;

/**
 *  Sets location value associated with a given key.
 *
 *  The operation could fail if value is nil, or the existing column associated with the key has a different type.
 *
 *  @param value The value to be set. It must not be nil.
 *  @param key The associated column key.
 *
 *  @return Indicating whether the operation is successful.
 */
- (BOOL)setLocation:(BCLocation *)value forKey:(NSString *)key;

/**
 *  Initiates an empty array object for the given key.
 *
 *  @warning This function is not fully complete yet, please use them after they are completed in later releases.
 *
 *  @param key  The associated column key.
 *  @param type Key type of the array. The type can only be primitive data types.
 *
 *  @return Returns the (NSMutableArray *), which you can manipulate on and the results are automatically saved to the
 *          object.
 */
- (NSMutableArray *)addArrayForKey:(NSString *)key withKeyType:(BCDataType)type;

/*!
 Unsets a key on the object. The key is case-insensitive, i.e., "game" and "GAME" all point to the same object.
 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

/*!
 Marked the object for the given key as modified externally, so that when the save methods are called, the object which
 is modified externally will be synced to the cloud. This is used when you manipulate the NSSet, NSArray or NSDictionary
 objects not using the interfaces provided in this class.
 @warning Please only use this method if necessary, as it may cause more network traffic than needed when an object is
 marked as modified but it is actually not.
 @param key The key, which is case insensitive.
 */
- (void)markObjectAsModifiedForKey:(NSString *)key;

#pragma mark - Loading and saving functions
/** @name Refresh, Save or Delete Object */

/*!
 Refresh the up-to-date object from cloud synchronously. If the current object has unsaved changes, calling this
 function will lose ALL of these changes. For a new BCObject, if you have never saved the object through save*
 functions, the refresh will always fail, since there is no such object in the cloud. If a refresh happens after the
 object is removed from the cloud, the object will be reset, and everything including objectId will be reset except for
 class name.
 @return Indicating whether the refresh has been successful.
 */
- (BOOL)refresh;

/*!
 Refresh the up-to-date object from cloud asynchronously. If the current object has unsaved changes, calling this
 function will lose ALL of these changes. For a new BCObject, if you have never saved the object through save*
 functions, the refresh will always fail, since there is no such object in the cloud. If a refresh happens after the
 object is removed from the cloud, the object will be reset, and everything including objectId will be reset except for
 class name.
 */
- (void)refreshInBackground;

/*!
 Refresh the up-to-date object from cloud asynchronously. If the current object has unsaved changes, calling this
 function will lose ALL of these changes. For a new BCObject, if you have never saved the object through save*
 functions, the refresh will always fail, since there is no such object in the cloud. If a refresh happens after the
 object is removed from the cloud, the object will be reset, and everything including objectId will be reset except for
 class name.
 @param block The callback block can either be nil or should have the following argument signature:
        (BOOL succeeded, NSError *error)
 It will report the whether the loading is successful with error being nil, or report the error otherwise.
 */
- (void)refreshInBackgroundWithBlock:(BCBooleanResultBlock)block;

/*!
 Saves the current object to cloud synchronously. If this is a new object, upon successful save, the objectId will be
 allocated by the cloud. Otherwise, this save will modify any existing object in the cloud. Notice that if there is any
 type mismatch for any column, the save won't be successful.
 @return Indicating whether the save has been successful.
 */
- (BOOL)save;

/*!
 Saves the current object to cloud asynchronously. If this is a new object, upon successful save, the objectId will be
 allocated by the cloud. Otherwise, this save will modify any existing object in the cloud. Notice that if there is any
 type mismatch for any column, the save won't be successful.
 */
- (void)saveInBackground;

/**
 *  Saves the current object to cloud asynchronously and executes the given callback block. If this is a new object,
 *  upon successful save, the objectId will be allocated by the cloud. Otherwise, this save will modify any existing
 *  object in the cloud. Notice that if there is any type mismatch for any column, the save won't be successful.
 *
 *  @param block The block to execute. The block should have the following argument signature:
 *         (BOOL succeeded, NSError *error)
 */
- (void)saveInBackgroundWithBlock:(BCBooleanResultBlock)block;

/*!
 Deletes the current object from cloud synchronously. After a successful delete, the object will be reset and is equal
 to a newly created object (with the original class name), saving this object will create a new object in the cloud with
 a new objectId different from the deleted one. If failed, the object will stay unchanged.
 @return Indicating whether the delete has been successful.
 */
- (BOOL)delete;

/*!
 Deletes the current object from cloud asynchronously. After a successful delete, the object will be reset and is equal
 to a newly created object (with the original class name), saving this object will create a new object in the cloud with
 a new objectId different from the deleted one. If failed, the object will stay unchanged.
 */
- (void)deleteInBackground;

/*!
 Deletes the current object from cloud asynchronously and executes the given callback block. After a successful delete,
 the object will be reset and is equal to a newly created object (with the original class name), saving this object will
 create a new object in the cloud with a new objectId different from the deleted one. If failed, the object will stay
 unchanged.
 @param block The block to execute. The block should have the following argument signature:
        (BOOL succeeded, NSError *error)
 */
- (void)deleteInBackgroundWithBlock:(BCBooleanResultBlock)block;

@end
