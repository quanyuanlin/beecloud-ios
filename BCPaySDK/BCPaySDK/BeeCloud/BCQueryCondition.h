//
//  BCQueryCondition.h
//  BeeCloud SDK
//
//  Created by Junxian Huang on 3/1/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

/*!
 This header file is *NOT* included in the public release.
 */

typedef enum {
    // General condition.
    ConditionTypeEqualTo,
    ConditionTypeLessThan,
    ConditionTypeLessOrEqual,
    ConditionTypeGreaterThan,
    ConditionTypeGreaterOrEqual,
    ConditionTypeNotEqualTo,
    ConditionTypeContainedIn,
    // String related.
    ConditionTypePrefix,
    ConditionTypeSuffix,
    ConditionTypeSubstring,
    ConditionTypeRegex,
    // Geo related.
    ConditionTypeGeoLessOrEqual
} ConditionType;

@interface BCQueryCondition : NSObject

@property (nonatomic, strong) NSString *key;

@property (nonatomic) ConditionType type;

@property (nonatomic, strong) id objectToCompare;

// Base location only needed for geo conditions, in the format of "lat,lon".
@property (nonatomic, strong) NSString *baseLocation;

/**
 * Creates a new QueryCondition object.
 */
+ (instancetype)queryConditionWithKey:(NSString *)key
                        conditionType:(ConditionType)type
                      objectToCompare:(id)object
                         baseLocation:(NSString *)baseLocation;

/**
 *  Initializes a QueryCondition object.
 */
- (instancetype)initWithKey:(NSString *)key
              conditionType:(ConditionType)type
            objectToCompare:(id)object
               baseLocation:(NSString *)baseLocation;

/**
 *  Helper function to get operation encoded string for a given ConditionType.
 *
 *  @param type Condition type.
 *
 *  @return Encoded condition type string.
 */
+ (NSString *)getEncodedStringForConditionType:(ConditionType)type;

@end
