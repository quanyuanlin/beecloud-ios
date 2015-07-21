//
// BCQuery.h
// BeeCloud SDK
//
// Created by Junxian Huang on 2/18/14.
// Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCObject.h"
#import "BCLocation.h"

/**
 *  A class that defines a query that is used to query for BCObjects.
 */
@interface BCQuery : NSObject

/**
 *  The class name to query for.
 */
@property (nonatomic, strong) NSString *className;

/**
 *  A limit on the number of objects to return. Default limit is 500.
 */
@property (nonatomic) NSUInteger limit;

/**
 *  The number of objects to skip before returning any. Default skip is 0.
 */
@property (nonatomic) NSUInteger skip;

#pragma mark - Create instances
/** @name Create a New Query */

/*!
 Returns a BCQuery for a given class.
 @param className The class to query on.
 @return A BCQuery object.
 */
+ (BCQuery *)queryWithClassName:(NSString *)className;

/*!
 Initializes the query with a class name.
 @param className The class name.
 */
- (instancetype)initWithClassName:(NSString *)className;

/**
 *  Reset everything besides the className of this query instance to default value, so that it can be reused as if it is
 *  a newly created query instance.
 */
- (void)reset;

#pragma mark - Query conditions and requirements
/** @name Adding Basic Constraints */

/**
 *  Make the results to include only the provided keys. This is similar to MySQL's "select X, Y from table". If this is
 *  called multiple times, then all of the keys specified in each of the calls will be included. ObjectId is always
 *  automatically selected as it is a required element of BCObject.
 *
 *  If one or more of the selected keys do not exist in the table being queried, the query would fail.
 *
 *  @param keys The keys to include in the result.
 */
- (void)selectKeys:(NSArray *)keys;

/*!
 Add a constraint requiring a particular key's object to be equal to the provided object.
 @param key The key to be constrained.
 @param object The object to compare with. If the object type is a number or BOOL, use [NSNumber numberwithXXX] methods
 to create the object.
 */
- (void)whereKey:(NSString *)key equalTo:(id)object;

/*!
 Add a constraint requiring a particular key's object to be less than the provided object.
 @param key The key to be constrained.
 @param object The object to compare with. If the object type is a number or BOOL, use [NSNumber numberwithXXX] methods
 to create the object.
 */
- (void)whereKey:(NSString *)key lessThan:(id)object;

/*!
 Add a constraint requiring a particular key's object to be less than or equal to the provided
 object.
 @param key The key to be constrained.
 @param object The object to compare with. If the object type is a number or BOOL, use [NSNumber numberwithXXX] methods
 to create the object.
 */
- (void)whereKey:(NSString *)key lessOrEqual:(id)object;

/*!
 Add a constraint requiring a particular key's object to be greater than the provided object.
 @param key The key to be constrained.
 @param object The object to compare with. If the object type is a number or BOOL, use [NSNumber numberwithXXX] methods
 to create the object.
 */
- (void)whereKey:(NSString *)key greaterThan:(id)object;

/*!
 Add a constraint requiring a particular key's object to be greater than or equal to the provided
 object.
 @param key The key to be constrained.
 @param object The object to compare with. If the object type is a number or BOOL, use [NSNumber numberwithXXX] methods
 to create the object.
 */
- (void)whereKey:(NSString *)key greaterOrEqual:(id)object;

/*!
 Add a constraint requiring a particular key's object to be not equal to the provided object.
 @param key The key to be constrained.
 @param object The object to compare with. If the object type is a number or BOOL, use [NSNumber numberwithXXX] methods
 to create the object.
 */
- (void)whereKey:(NSString *)key notEqualTo:(id)object;

#pragma mark - String conditions
/** @name Adding String Constraints */

/*!
 Add a constraint to find string values that start with a provided prefix.
 @param key The key that the string to match is stored in.
 @param prefix The substring that the value must start with.
 */
- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix;

/*!
 Add a constraint for finding string values that end with a provided suffix.
 This may be slow for large data classes.
 @param key The key that the string to match is stored in.
 @param suffix The substring that the value must end with.
 */
- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;

/*!
 Add a constraint to find string values that contain the given substring.
 This may be slow for large data classes.
 @param key The key that the string to match is stored in.
 @param substring The substring that the value should contain.
 */
- (void)whereKey:(NSString *)key hasSubstring:(NSString *)substring;

/*!
 Add a regular expression constraint to find string values that match the provided regular expression.
 This may be slow for large data classes.
 @param key The key that the string to match is stored in.
 @param regex The regular expression pattern to match.
 */
- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex;

#pragma mark - Geo conditions
/** @name Adding Location Constraints */

/**
 *  Add a constraint requiring the geo coordinates of a column, which must be of type BCLocation, be within the maximum
 *  distance specified (in meters). Distance is calculated based on a spherical coordinate system. Notice that the
 *  in order for the results to be sorted by distance (nearest to farthest), please call orderByDistanceToLocation.
 *
 *  @param key         The key to be constrained.
 *  @param base        The base location, which is a BCLocation.
 *  @param maxDistance Maximum distance in meters.
 */
- (void)whereKey:(NSString *)key nearLocation:(BCLocation *)base withinMeters:(double)maxDistance;

#pragma mark - Sorting
/** @name Sorting */

/**
 *  Sort the results in ascending order using the given key. If you call order by key1, and then call order by key2, the
 *  results will be first sorted based on key1 and when key1 contains the same value, key2 is used for ordering. At most
 *  5 different keys can be called consecutively to order results.
 *
 *  For performance concerns, orderByDistanceToLocation and the other two orderBy are mutually exclusive. For example,
 *  you should not call orderByDistanceToLocation first and then orderByAscending/orderByDescending, nor the opposite.
 *
 *  @param key The key to order by.
 */
- (void)orderByAscending:(NSString *)key;

/**
 *  Sort the results in descending order using the given key. If you call order by key1, and then call order by key2,
 *  the results will be first sorted based on key1 and when key1 contains the same value, key2 is used for ordering. At
 *  most 5 different keys can be called consecutively to order results.
 *
 *  For performance concerns, orderByDistanceToLocation and the other two orderBy are mutually exclusive. For example,
 *  you should not call orderByDistanceToLocation first and then orderByAscending/orderByDescending, nor the opposite.
 *
 *  @param key The key to order by.
 */
- (void)orderByDescending:(NSString *)key;

/**
 *  Sort the results by distance to a base location with shortest distance appearing first. 
 *  
 *  For performance concerns, orderByDistanceToLocation and the other two orderBy are mutually exclusive. For example,
 *  you should not call orderByDistanceToLocation first and then orderByAscending/orderByDescending, nor the opposite.
 *
 *  @param base The base Location to compute distance.
 *  @param key  Key of the column which must be of type BCLocation.
 */
- (void)orderByDistanceToLocation:(BCLocation *)base key:(NSString *)key;

#pragma mark - Find methods
/** @name Finding Objects by Condition */

/**
 *  Find objects based on the constructed query synchronously.
 *
 *  @return An array of matched objects, or any empty array if no matching object is found, or nil if any error occurs.
 */
- (NSArray *)findObjects;

/**
 *  Finds objects asynchronously and calls the given block with the results.
 *
 *  @param block The callback block to execute. The block should have the following argument signature:
 *               (NSArray *objects, NSError *error). When error happens, objects is nil; otherwise, error is nil.
 *               If no matching object is found, an empty array is returned.
 */
- (void)findObjectsInBackgroundWithBlock:(BCArrayResultBlock)block;

#pragma mark - Get object methods
/** @name Getting Object by ID */

/*!
 Returns a BCObject with the given objectId.
 @param objectId The id of the object being requested.
 @return The BCObject if found. Returns nil if the object isn't found, or if there was an error.
 */
- (BCObject *)getObjectById:(NSString *)objectId;

/**
 *  Gets a BCObject asynchronously and calls the given block with the result.
 *
 *  @param objectId objectId of the object to be fetched.
 *  @param block    The block to execute. The block should have the following argument signature:
 *                  (NSArray *object, NSError *error)
 */
- (void)getObjectByIdInBackground:(NSString *)objectId block:(BCObjectResultBlock)block;

#pragma mark - Count methods
/** @name Counting Objects */

/**
 *  Counts objects based on the current query.
 *
 *  @return Returns the number of BCObjects that match the query, or -1 if there is an error.
 */
- (NSInteger)countObjects;

/**
 *  Counts objects asynchronously and calls the given block with the counts.
 *
 *  @param block The block to execute. The block should have the following argument signature:
 *               (int count, NSError *error)
 *               The count is -1 if there is an error.
 */
- (void)countObjectsInBackgroundWithBlock:(BCIntegerResultBlock)block;

#pragma mark - Modify by condition methods
/** @name Modify Objects by Condition */

/**
 *  Synchronously modify all objects by the conditions in this query following the example BCObject's unsaved changes.
 *
 *  The example object can either be simply generated locally or loaded from the cloud. All system fields in the
 *  objects, such as objectId, createdAt and updatedAt, will not be used, as these fields can not be modified.
 *  Only user fields can be used for the modification. All field types must agree with those in the existing table (if
 *  there is any) in the cloud, and if any column type mismatches, no field will be modified. Notice that only the
 *  unsaved changes of the example object will be used, i.e., if the object is in sync with the cloud, via either save
 *  or refresh, there are no unsaved changes, and nothing will be modified. You can make unsaved changes to an object
 *  using any of BCObject's setter methods, such as set***forKey methods, markObjectAsModifiedForKey method
 *  and removeObjectForKey method. If removeObjectForKey is called for a column, this modification will remove this
 *  column (set to NULL) from all the matched objects in the cloud.
 *
 *  @param example Object used as an example to modify all match objects with unsaved changes.
 *
 *  @return Indicating whether the modification is successful.
 */
- (BOOL)modifyObjectsWithExample:(BCObject *)example;

/**
 *  Asynchronously modify all objects by the conditions in this query following the example BCObject's unsaved changes.
 *
 *  The example object can either be simply generated locally or loaded from the cloud. All system fields in the
 *  objects, such as objectId, createdAt and updatedAt, will not be used, as these fields can not be modified.
 *  Only user fields can be used for the modification. All field types must agree with those in the existing table (if
 *  there is any) in the cloud, and if any column type mismatches, no field will be modified. Notice that only the
 *  unsaved changes of the example object will be used, i.e., if the object is in sync with the cloud, via either save
 *  or refresh, there are no unsaved changes, and nothing will be modified. You can make unsaved changes to an object
 *  using any of BCObject's setter methods, such as set***forKey methods, markObjectAsModifiedForKey method
 *  and removeObjectForKey method. If removeObjectForKey is called for a column, this modification will remove this
 *  column (set to NULL) from all the matched objects in the cloud.
 *
 *  @param example Object used as an example to modify all match objects with unsaved changes.
 */
- (void)modifyObjectsWithExampleInBackground:(BCObject *)example;

/**
 *  Asynchronously modify all objects by the conditions in this query following the example BCObject's unsaved changes.
 *
 *  The example object can either be simply generated locally or loaded from the cloud. All system fields in the
 *  objects, such as objectId, createdAt and updatedAt, will not be used, as these fields can not be modified.
 *  Only user fields can be used for the modification. All field types must agree with those in the existing table (if
 *  there is any) in the cloud, and if any column type mismatches, no field will be modified. Notice that only the
 *  unsaved changes of the example object will be used, i.e., if the object is in sync with the cloud, via either save
 *  or refresh, there are no unsaved changes, and nothing will be modified. You can make unsaved changes to an object
 *  using any of BCObject's setter methods, such as set***forKey methods, markObjectAsModifiedForKey method
 *  and removeObjectForKey method. If removeObjectForKey is called for a column, this modification will remove this
 *  column (set to NULL) from all the matched objects in the cloud.
 *
 *  @param example Object used as an example to modify all match objects with unsaved changes.
 *  @param block Callback block in the format of ^(BOOL succeeded, NSError *error), indicating whether the modification
 *               is successful, with error being nil when success and not nil when error.
 */
- (void)modifyObjectsWithExampleInBackground:(BCObject *)example block:(BCBooleanResultBlock)block;

#pragma mark - Delete by condition methods
/** @name Deleting Objects by Condition */

/**
 *  Synchronously delete all objects matched by the conditions in this query, regardless of the skip and limit settings.
 *
 *  @return YES if the delete is successful; NO otherwise.
 */
- (BOOL)deleteObjects;

/**
 *  Asynchronously delete all objects matched by the conditions in this query, regardless of the skip and limit
 *  settings.
 */
- (void)deleteObjectsInBackground;

/**
 *  Asynchronously delete all objects matched by the conditions in this query, regardless of the skip and limit
 *  settings.
 *
 *  @param block Callback block with format ^(BOOL succeeded, NSError *error).
 *         When success, succeeded is YES and error is nil; when error, succeeded is NO and error is not nil.
 */
- (void)deleteObjectsInBackgroundWithBlock:(BCBooleanResultBlock)block;

#pragma mark - Debug methods
/** @name Debugging */

/*!
 Debug methods to help unit tests. Normally, this should not be used in production code.
 @param type The type of debug request. The supported types and return values are as follows:
 "ToString" => (NSString *) a string that represents the current query in a mysql like manner.
 "ConditionCount" => (NSNumber *) the number of conditions in this query.
 "SubqueryCount" => (NSNumber *) the number of OR subqueries.
 Contact us for more debugging support.
 */
- (id)debug:(NSString *)type;

@end
