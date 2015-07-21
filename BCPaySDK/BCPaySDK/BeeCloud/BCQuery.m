//
//  BCQuery.m
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/18/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCQuery.h"

#import "BCCache.h"
#import "BCQueryCondition.h"
#import "BCUtil.h"
#import "BCUtilPrivate.h"

static NSString * const kDebugToStringTag = @"ToString";
static NSString * const kDebugConditionCountTag = @"ConditionCount";
static NSString * const kDebugSubqueryCountTag = @"SubqueryCount";

static NSUInteger const kDefaultLimit = 500;
static NSUInteger const kDefaultSkip = 0;
static NSUInteger const kOrderByCountMax = 5;
static NSString * const kOrderByAscending = @"asc";
static NSString * const kOrderByDescending = @"desc";

static NSInteger const kObjectCountWhenError = -1;

typedef enum {
    QueryTypeById,
    QueryTypeByCondition,
    QueryTypeCount,
    QueryTypeModify,
    QueryTypeDelete,
} QueryType;

// Result pair.
@interface ResultPair : NSObject
@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSError *error;
@end

@implementation ResultPair
@end

@implementation BCQuery {
    NSUInteger orderByCount;
    NSMutableArray *orderByKeys;
    NSMutableArray *orderByStrings;
    
    // nil for selecting all (*).
    NSMutableArray *selectedKeys;
    
    // subqueries is nil unless it is a or query.
    NSMutableArray *subqueries;
    
    // conditions is nil unless it contains at least one query condition.
    NSMutableArray *conditions;
}

#pragma mark - Create instances
/** @name Create a New Query */

+ (BCQuery *)queryWithClassName:(NSString *)className {
    return [[BCQuery alloc] initWithClassName:className];
}

+ (BCQuery *)queryForUser {
    return [BCQuery queryWithClassName:kBCUserClassName];
}

/*!
 Return the list of valid queries, i.e., the non-nil queries with at least one conditions. If there are two queries with
 class name mismatch, an empty array will be returned.
 */
+ (NSArray *)validOrQueries:(NSArray *)queries {
    NSMutableArray *validQueries = [NSMutableArray array];
    if (queries == nil || queries.count == 0)
        return validQueries;
    NSString *className = nil;
    for (BCQuery *query in queries) {
        if (query == nil) continue;
        if (className == nil) {
            className = query.className;
        } else if (![className isEqualToString:query.className]) {
            // Class name mismatch.
            return [NSMutableArray array];
        }
        NSNumber *conditionKeyCount = [query debug:kDebugConditionCountTag];
        if (conditionKeyCount != nil && [conditionKeyCount intValue] > 0) {
            // There is at least one condition for this query.
            [validQueries addObject:query];
        }
        // This is no valid subqueries.
    }
    return validQueries;
}

+ (BCQuery *)orQueryWithSubqueries:(NSArray *)queries {
    NSArray *validQueries = [BCQuery validOrQueries:queries];
    if (validQueries.count == 0)
        return nil;
    return [[BCQuery alloc] initWithOrSubqueries:queries];
}

/**
 *  Clear all previous settings of order by and the results are in default ordering.
 */
- (void)resetOrderBy {
    orderByCount = 0;
    orderByKeys = [NSMutableArray array];
    orderByStrings = [NSMutableArray array];
}

- (void)reset {
    self.limit = kDefaultLimit;
    self.skip = kDefaultSkip;
    
    [self resetOrderBy];
    
    selectedKeys = nil;
    subqueries = nil;
    conditions = nil;
}

- (instancetype)initWithClassName:(NSString *)className {
    self = [super init];
    if (self) {
        [self reset];
        self.className = className;
    }
    return self;
}

- (instancetype)initWithOrSubqueries:(NSArray *)queries {
    NSArray *validQueries = [BCQuery validOrQueries:queries];
    self = [super init];
    if (self) {
        [self reset];
        self.className = nil;
        for (BCQuery *query in validQueries) {
            if (self.className == nil)
                self.className = query.className;
            if (subqueries == nil)
                subqueries = [NSMutableArray array];
            [subqueries addObject:query];
        }
    }
    return self;
}

#pragma mark - Query conditions and requirements
/** @name Adding Basic Constraints */

- (void)selectKeys:(NSArray *)keys {
    for (__strong NSString *key in keys) {
        if (key == nil) continue;
        key = key.lowercaseString;
        if (![selectedKeys containsObject:key]) {
            if (selectedKeys == nil) {
                // Init selectedKeys
                selectedKeys = [NSMutableArray array];
                // We need objectId to make things work.
                [selectedKeys addObject:kKeyObjectId];
            }
            [selectedKeys addObject:key];
        }
    }
}

/**
 *  Helper function to add a new condition.
 *
 *  @param key          Column key.
 *  @param type         Condition type.
 *  @param object       Object to compare.
 *  @param baseLocation Base location to calculate distance for geo conditions, nil for other conditions.
 */
- (void)addQueryCondition:(NSString *)key conditionType:(ConditionType)type comparingValue:(id)object
             baseLocation:(NSString *)baseLocation {
    // Condition optimization should be done in server.
    if (key == nil || object == nil) {
        BCDLog(@"Error in %s: both key and comparing value should not be nil.", __func__);
        return;
    }
    BCQueryCondition *condition = [BCQueryCondition queryConditionWithKey:key conditionType:type objectToCompare:object baseLocation:baseLocation];
    if (conditions == nil)
        conditions = [NSMutableArray array];
    [conditions addObject:condition];
}

/**
 *  Wrapper function to call addQueryCondition with base location being nil.
 */
- (void)addQueryCondition:(NSString *)key conditionType:(ConditionType)type comparingValue:(id)object {
    [self addQueryCondition:key conditionType:type comparingValue:object baseLocation:nil];
}

- (void)whereKey:(NSString *)key equalTo:(id)object {
    [self addQueryCondition:key conditionType:ConditionTypeEqualTo comparingValue:object];
}

- (void)whereKey:(NSString *)key lessThan:(id)object {
    [self addQueryCondition:key conditionType:ConditionTypeLessThan comparingValue:object];
}

- (void)whereKey:(NSString *)key lessOrEqual:(id)object {
    [self addQueryCondition:key conditionType:ConditionTypeLessOrEqual comparingValue:object];
}

- (void)whereKey:(NSString *)key greaterThan:(id)object {
    [self addQueryCondition:key conditionType:ConditionTypeGreaterThan comparingValue:object];
}

- (void)whereKey:(NSString *)key greaterOrEqual:(id)object {
    [self addQueryCondition:key conditionType:ConditionTypeGreaterOrEqual comparingValue:object];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object {
    [self addQueryCondition:key conditionType:ConditionTypeNotEqualTo comparingValue:object];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array {
    [self addQueryCondition:key conditionType:ConditionTypeContainedIn comparingValue:array];
}

#pragma mark - String conditions
/** @name Adding String Constraints */

/**
 *  Check string can be used as prefix/suffix/substring.
 *
 *  @param string String to be check.
 *
 *  @return YES if string is nil or empty; NO otherwise.
 */
- (BOOL)checkString:(NSString *)string {
    if (string == nil || string.length == 0)
        return NO;
    return YES;
}

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix {
    if ([self checkString:prefix])
        [self addQueryCondition:key conditionType:ConditionTypePrefix comparingValue:prefix];
    else
        BCDLog(@"Error in %s: nil or empty string as input is not allowed.", __func__);
}

- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix {
    if ([self checkString:suffix])
        [self addQueryCondition:key conditionType:ConditionTypeSuffix comparingValue:suffix];
    else
        BCDLog(@"Error in %s: nil or empty string as input is not allowed.", __func__);
}

- (void)whereKey:(NSString *)key hasSubstring:(NSString *)substring {
    if ([self checkString:substring])
        [self addQueryCondition:key conditionType:ConditionTypeSubstring comparingValue:substring];
    else
        BCDLog(@"Error in %s: nil or empty string as input is not allowed.", __func__);
}

- (void)whereKey:(NSString *)key matchesRegex:(NSString *)regex {
    if ([self checkString:regex])
        [self addQueryCondition:key conditionType:ConditionTypeRegex comparingValue:regex];
    else
        BCDLog(@"Error in %s: nil or empty string as input is not allowed.", __func__);
}


#pragma mark - Sorting
/** @name Sorting */

/**
 *  Check whether the given key should be added to the order by list.
 *
 *  @param key Key to be checked.
 *
 *  @return NO if orderByKeys is full, or key is nil or empty, or is already in the order by list, hence it should not
 *  be added to the list again; YES otherwise.
 */
- (BOOL)keyShouldBeAddedToOrderBy:(NSString *)key {
    if ([orderByKeys count] >= kOrderByCountMax) return NO;
    if (key == nil || key.length == 0)
        return NO;
    key = key.lowercaseString;
    for (NSUInteger i = 0; i < orderByCount; i++)
        if ([orderByKeys[i] isEqualToString:key])
            return NO;
    return YES;
}

- (void)orderByAscending:(NSString *)key {
    if ([self keyShouldBeAddedToOrderBy:key]) {
        key = key.lowercaseString;
        [orderByKeys addObject:key];
        [orderByStrings addObject:[NSString stringWithFormat:@"%@,%@", key, kOrderByAscending]];
        orderByCount++;
    }
}

- (void)orderByDescending:(NSString *)key {
    if ([self keyShouldBeAddedToOrderBy:key]) {
        key = key.lowercaseString;
        [orderByKeys addObject:key];
        [orderByStrings addObject:[NSString stringWithFormat:@"%@,%@", key, kOrderByDescending]];
        orderByCount++;
    }
}

#pragma mark - Find methods
/** @name Getting Matched Objects for a Query */

/**
 *  Prepare parameters for query API call.
 *
 *  @param type Query type.
 *  @param param String parameter, which normally will be nil and will be objectId for getById methods.
 *
 *  @return For GET methods, returns a wrapped in the format of "para" to a NSMutableDictionary with appId, appSign, masterKey (if there is any), and table, or nil if no appId, appSign is specified. For PUT/POST methods, no need to wrap.
 */
- (NSMutableDictionary *)prepareParametersForQueryType:(QueryType)type stringParameter:(NSString *)param {
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
    [parameters setObject:self.className.lowercaseString forKey:@"table"];
    
    if (type == QueryTypeById) {
        if (![BCUtil isValidUUID:param]) return nil;
        [parameters setObject:param forKey:@"objectId"];
    } else {
        if (subqueries == nil) {
            // And query
            [parameters setObject:@"and" forKey:@"conditionConnector"];
        } else {
            // Or query.
            [parameters setObject:@"or" forKey:@"conditionConnector"];
        }
        
        if (type == QueryTypeModify || type == QueryTypeDelete)
            if (conditions == nil || [conditions count] == 0)
                // For modifyByCondition and deleteByCondition, we don't allow empty conditions.
                return nil;

        // Add conditions.
        NSMutableArray *condition_array = [NSMutableArray array];
        if (conditions && [conditions count] > 0) {
            for (BCQueryCondition *condition in conditions) {
                NSMutableDictionary *condition_map = [NSMutableDictionary dictionary];
                [condition_map setObject:condition.key forKey:@"cname"];
                [condition_map setObject:[BCQueryCondition getEncodedStringForConditionType:condition.type] forKey:@"type"];
                [condition_map setObject:condition.objectToCompare forKey:@"value"];
                if (condition.type == ConditionTypeGeoLessOrEqual) {
                    if (condition.baseLocation == nil) {
                        BCDLog(@"Error: geo condition should contain base location for key %@.", condition.key);
                    } else {
                        [condition_map setObject:condition.baseLocation forKey:@"base"];
                    }
                }
                [condition_array addObject:condition_map];
            }
            [parameters setObject:condition_array forKey:@"conditions"];
        }
        
        if (type == QueryTypeByCondition) {
            [parameters setObject:[NSNumber numberWithUnsignedInteger:self.skip] forKey:@"skip"];
            [parameters setObject:[NSNumber numberWithUnsignedInteger:self.limit] forKey:@"limit"];
            // Set order by.
            if (orderByCount > 0) {
                NSString *orderByString = orderByStrings[0];
                for (NSUInteger i = 1; i < orderByCount; i++) {
                    orderByString = [NSString stringWithFormat:@"%@;%@", orderByString, orderByStrings[i]];
                }
                [parameters setObject:orderByString forKey:@"order"];
            }
        }
    }
    // Selected keys.
    if (selectedKeys != nil && [selectedKeys count] > 0)
        if (type == QueryTypeByCondition || type == QueryTypeById)
            [parameters setObject:selectedKeys forKey:@"selectedKeys"];
    
    // No need to wrap for non-GET methods.
    if (type == QueryTypeModify || type == QueryTypeDelete)
        return parameters;
    
    // Wrap the map to be "para" => value.
    return [BCUtilPrivate getWrappedParametersForGetRequest:parameters];
}

- (NSArray *)findObjects {
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeByCondition stringParameter:nil];
    if (parameters == nil) {
        BCDLog(@"Error in %s: parameter incomplete.", __func__);
        return nil;
    }
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"GET"
                                    URLString:[BCUtil getBestHostWithFormat:kApiQueryByCondition]
                                    parameters:parameters error:nil];
    request.timeoutInterval = [BCCache sharedInstance].networkTimeout;
    
    NSURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        BCDLog(@"Error in %s: %@", __func__, error);
        [BCUtilPrivate checkRequestFail];
    }
    id response = [[AFJSONResponseSerializer serializer] responseObjectForResponse:urlResponse data:data error:&error];
    if (error)
        BCDLog(@"Error in %s: %@", __func__, error);
    ResultPair *resultPair = [self findObjectsWithResponse:response block:nil caller:QueryTypeByCondition];
    return resultPair.result;
}

- (void)findObjectsInBackgroundWithBlock:(BCArrayResultBlock)block {
    // If block is nil, there is no way to report result, so we don't do anything.
    if (block == nil) return;
    AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeByCondition stringParameter:nil];
    if (parameters == nil) {
        block(nil, [BCUtilPrivate errorWithCode:0 message:
                    [NSString stringWithFormat:@"Error in %s: parameter incomplete.", __func__]]);
        return;
    }
    [manager GET:[BCUtil getBestHostWithFormat:kApiQueryByCondition] parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id response) {
        ResultPair *resultPair = [self findObjectsWithResponse:response block:block caller:QueryTypeByCondition];
        if (block)
            block(resultPair.result, resultPair.error);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
        [BCUtilPrivate checkRequestFail];
    }];
}

// Common method called by both sync and async methods of find objects and getObject(s) by ID.
- (ResultPair *)findObjectsWithResponse:(id)response block:(BCIdResultBlock)block caller:(QueryType)caller {
    ResultPair *resultPair = [[ResultPair alloc] init];
    resultPair.result = nil;
    resultPair.error = nil;
    
    NSString *basicErrorString = [BCUtilPrivate getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
    if (basicErrorString != nil) {
        // Top level error.
        resultPair.error = [BCUtilPrivate errorWithCode:0 message:
                            [NSString stringWithFormat:@"Error in %s: %@.", __func__, basicErrorString]];
        return resultPair;
    }
    
    NSMutableArray *results = [response objectForKey:kKeyResponseResult];
    NSMutableArray *type = [response objectForKey:kKeyResponseType];
    if (results == nil) {
        resultPair.error = [BCUtilPrivate errorWithCode:0 message:@"Query response does not contain results."];
        return resultPair;
    }
    if ([results count] > 0 && type == nil) {
        // For empty results, no type is valid.
        resultPair.error = [BCUtilPrivate errorWithCode:0 message:@"Query response has non-empty results but no type."];
        return resultPair;
    }
    NSMutableArray *objects = [NSMutableArray array];
    for (id result in results) {
        NSString *resultObjectId = [result objectForKey:kKeyObjectId];
        if (resultObjectId == nil)
            resultObjectId = kNewObjectId;
        // Add network results to cache.
        [[BCCache sharedInstance] addResult:result andType:type toCacheForClassName:self.className
                                   objectId:resultObjectId];
        // Generate BCObject whose refresh will automatically check the cache first.
        BCObject *object = [BCObject existingObjectWithClassName:@"tmp" objectId:resultObjectId usingCache:NO];
        // First generate object with valid className, then set className using backdoor method, to allow system table
        // names, such as "config__", to be set.
        [BCUtilPrivate setSystemClassName:self.className forObject:object];
        // This is actually not network request, since cached contents will be used and should be very fast.
        [object refresh];
        [objects addObject:object];
        // Clear the cache immediately after use.
        [[BCCache sharedInstance] clearResultTypeCacheForClassName:self.className objectId:resultObjectId];
    }
    
    if (caller == QueryTypeByCondition) {
        resultPair.result = objects;
    } else {
        if ([objects count] == 1) {
            BCObject *object = [objects objectAtIndex:0];
            resultPair.result = object;
        } else {
            resultPair.error = [BCUtilPrivate errorWithCode:0 message:@"Query result should have one object."];
        }
    }
    return resultPair;
}

#pragma mark - Get object methods
/** @name Getting Object by ID */

- (BCObject *)getObjectById:(NSString *)objectId {
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeById stringParameter:objectId];
    if (parameters == nil) {
        BCDLog(@"Error in %s: parameter incomplete.", __func__);
        return nil;
    }
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"GET"
                                    URLString:[BCUtil getBestHostWithFormat:kApiQueryById]
                                    parameters:parameters error:nil];
    request.timeoutInterval = [BCCache sharedInstance].networkTimeout;
    
    NSURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        BCDLog(@"Error in %s: %@", __func__, error);
        [BCUtilPrivate checkRequestFail];
    }
    id response = [[AFJSONResponseSerializer serializer] responseObjectForResponse:urlResponse data:data error:&error];
    if (error)
        BCDLog(@"Error in %s: %@", __func__, error);
    ResultPair *resultPair = [self findObjectsWithResponse:response block:nil caller:QueryTypeById];
    return resultPair.result;
}

- (void)getObjectByIdInBackground:(NSString *)objectId block:(BCObjectResultBlock)block {
    // If block is nil, there is no way to report result, so we don't do anything.
    if (block == nil) return;
    AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeById stringParameter:objectId];
    if (parameters == nil) {
        block(nil, [BCUtilPrivate errorWithCode:0 message:
                    [NSString stringWithFormat:@"Error in %s: parameter incomplete.", __func__]]);
        return;
    }

    [manager GET:[BCUtil getBestHostWithFormat:kApiQueryById] parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id response) {
        ResultPair *resultPair = [self findObjectsWithResponse:response block:block caller:QueryTypeById];
        if (block)
            block(resultPair.result, resultPair.error);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
        [BCUtilPrivate checkRequestFail];
    }];
}

#pragma mark - Count methods
/** @name Counting Objects */

- (NSInteger)countObjects {
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeCount stringParameter:nil];
    if (parameters == nil) {
        BCDLog(@"Error in %s: parameter incomplete.", __func__);
        return kObjectCountWhenError;
    }
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"GET"
                                    URLString:[BCUtil getBestHostWithFormat:kApiQueryCount]
                                    parameters:parameters error:nil];
    request.timeoutInterval = [BCCache sharedInstance].networkTimeout;
    
    NSURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (error) {
        BCDLog(@"Error in %s: %@", __func__, error);
        [BCUtilPrivate checkRequestFail];
    }
    id response = [[AFJSONResponseSerializer serializer] responseObjectForResponse:urlResponse data:data error:&error];
    if (error)
        BCDLog(@"Error in %s: %@", __func__, error);
    return [self countObjectsWithResponse:response block:nil];
}

- (void)countObjectsInBackgroundWithBlock:(BCIntegerResultBlock)block {
    // If block is nil, there is no way to report result, so we don't do anything.
    if (block == nil) return;
    AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeCount stringParameter:nil];
    if (parameters == nil) {
        block(kObjectCountWhenError, [BCUtilPrivate errorWithCode:0 message:
                                      [NSString stringWithFormat:@"Error in %s: parameter incomplete.", __func__]]);
        return;
    }
    [manager GET:[BCUtil getBestHostWithFormat:kApiQueryCount]
      parameters:parameters success:^(AFHTTPRequestOperation *operation, id response) {
        [self countObjectsWithResponse:response block:block];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(kObjectCountWhenError, error);
        [BCUtilPrivate checkRequestFail];
    }];
}

// Common method called by both sync and async methods.
- (NSInteger)countObjectsWithResponse:(id)response block:(BCIntegerResultBlock)block {
    NSString *basicErrorString = [BCUtilPrivate getErrorStringBasedOnResultCodeAndErrMsgInResponse:response];
    if (basicErrorString != nil) {
        // Top level error.
        if (block)
            block(kObjectCountWhenError, [BCUtilPrivate errorWithCode:0 message:
                                          [NSString stringWithFormat:@"Error in %s: %@.", __func__, basicErrorString]]);
        return kObjectCountWhenError;
    }
    
    NSNumber *total = [response objectForKey:kKeyResponseCount];
    if (total == nil) {
        if (block)
            block(kObjectCountWhenError,
                  [BCUtilPrivate errorWithCode:0 message:
                   [NSString stringWithFormat:@"Error in %s: response should contain total.", __func__]]);
        return kObjectCountWhenError;
    }
    if (block)
        block([total intValue], nil);
    return [total intValue];
}

#pragma mark - Modify by condition methods
/** @name Modify Objects by Condition */

- (BOOL)modifyObjectsWithExample:(BCObject *)example {
    if (example == nil) {
        BCDLog(@"Error in %s: example object should not be nil.", __func__);
        return NO;
    }
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeModify stringParameter:nil];
    if (parameters == nil) {
        BCDLog(@"Error in %s: parameter incomplete.", __func__);
        return NO;
    }
    // Use BCObject's backdoor to access. A little hacky, but no better way for now. :(
    NSArray *columns = [example addArrayForKey:kBackdoorKey withKeyType:BCDataTypeUnsupported];
    if (columns == nil || [columns count] == 0) {
        BCDLog(@"Error in %s: example object should have unsaved changes.", __func__);
        return NO;
    }
    [parameters setObject:columns forKey:@"columns"];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"PUT"
                                    URLString:[BCUtil getBestHostWithFormat:kApiModifyByCondition]
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
    return [BCUtilPrivate reactToSimpleResponse:response block:nil];
}

- (void)modifyObjectsWithExampleInBackground:(BCObject *)example {
    [self modifyObjectsWithExampleInBackground:example block:nil];
}

- (void)modifyObjectsWithExampleInBackground:(BCObject *)example block:(BCBooleanResultBlock)block {
    if (example == nil) {
        if (block)
            block(NO, [BCUtilPrivate errorWithCode:0 message:
                       [NSString stringWithFormat:@"Error in %s: example object should not be nil.", __func__]]);
        return;
    }
    AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeModify stringParameter:nil];
    if (parameters == nil) {
        if (block)
            block(NO, [BCUtilPrivate errorWithCode:0 message:
                       [NSString stringWithFormat:@"Error in %s: parameter incomplete.", __func__]]);
        return;
    }
    // Use BCObject's backdoor to access. A little hacky, but no better way for now. :(
    NSArray *columns = [example addArrayForKey:kBackdoorKey withKeyType:BCDataTypeUnsupported];
    if (columns == nil || [columns count] == 0) {
        if (block)
            block(NO, [BCUtilPrivate errorWithCode:0 message:
                       [NSString stringWithFormat:
                        @"Error in %s: example object should have unsaved changes.", __func__]]);
        return;
    }
    [parameters setObject:columns forKey:@"columns"];
    [manager PUT:[BCUtil getBestHostWithFormat:kApiModifyByCondition] parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id response) {
        [BCUtilPrivate reactToSimpleResponse:response block:block];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block)
            block(NO, error);
        [BCUtilPrivate checkRequestFail];
    }];
}

#pragma mark - Delete by condition methods
/** @name Deleting Objects by Condition */

- (BOOL)deleteObjects {
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeDelete stringParameter:nil];
    if (parameters == nil) {
        BCDLog(@"Error in %s: parameter incomplete.", __func__);
        return NO;
    }
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"PUT"
                                    URLString:[BCUtil getBestHostWithFormat:kApiDeleteByCondition]
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
    return [BCUtilPrivate reactToSimpleResponse:response block:nil];
}

- (void)deleteObjectsInBackground {
    [self deleteObjectsInBackgroundWithBlock:nil];
}

- (void)deleteObjectsInBackgroundWithBlock:(BCBooleanResultBlock)block {
    AFHTTPRequestOperationManager *manager = [BCUtilPrivate getAFHTTPRequestOperationManager];
    NSMutableDictionary *parameters = [self prepareParametersForQueryType:QueryTypeDelete stringParameter:nil];
    if (parameters == nil) {
        if (block)
            block(NO, [BCUtilPrivate errorWithCode:0 message:
                       [NSString stringWithFormat:@"Error in %s: parameter incomplete.", __func__]]);
        return;
    }
    [manager PUT:[BCUtil getBestHostWithFormat:kApiDeleteByCondition]
      parameters:parameters success:^(AFHTTPRequestOperation *operation, id response) {
        [BCUtilPrivate reactToSimpleResponse:response block:block];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block)
            block(NO, error);
        [BCUtilPrivate checkRequestFail];
    }];
}

#pragma mark - Debug methods
/** @name Debugging */

- (id)debug:(NSString *)type {
    if (type == nil) return nil;
    if ([kDebugConditionCountTag isEqualToString:type]) {
        if (conditions == nil)
            return [NSNumber numberWithInt:0];
        return [NSNumber numberWithInt:(int)[conditions count]];
    } else if ([kDebugSubqueryCountTag isEqualToString:type]) {
        if (subqueries == nil)
            return [NSNumber numberWithInt:0];
        return [NSNumber numberWithInt:(int)[subqueries count]];
    } else if ([kDebugToStringTag isEqualToString:type]) {
        // @todo(hjx): convert query to string.
    }
    return nil;
}

@end
