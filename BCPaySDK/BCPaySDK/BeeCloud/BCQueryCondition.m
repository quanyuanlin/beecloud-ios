//
//  BCQueryCondition.m
//  BeeCloud SDK
//
//  Created by Junxian Huang on 3/1/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCQueryCondition.h"

@implementation BCQueryCondition

+ (instancetype)queryConditionWithKey:(NSString *)key
                        conditionType:(ConditionType)type
                      objectToCompare:(id)object
                         baseLocation:(NSString *)baseLocation {
    return [[BCQueryCondition alloc] initWithKey:key
                                   conditionType:type
                                 objectToCompare:object
                                    baseLocation:baseLocation];
}

- (instancetype)initWithKey:(NSString *)key
              conditionType:(ConditionType)type
            objectToCompare:(id)object
               baseLocation:(NSString *)baseLocation {
    self = [super init];
    if (self) {
        self.key = key.lowercaseString;
        self.type = type;
        self.objectToCompare = object;
        self.baseLocation = baseLocation;
    }
    return self;
}

+ (NSString *)getEncodedStringForConditionType:(ConditionType)type {
    switch (type) {
        case ConditionTypeEqualTo:
            return @"e";
        case ConditionTypeLessThan:
            return @"l";
        case ConditionTypeLessOrEqual:
            return @"le";
        case ConditionTypeGreaterThan:
            return @"g";
        case ConditionTypeGreaterOrEqual:
            return @"ge";
        case ConditionTypeNotEqualTo:
            return @"n";
        case ConditionTypeContainedIn:
            return @"c";
        case ConditionTypePrefix:
            return @"pre";
        case ConditionTypeSuffix:
            return @"suf";
        case ConditionTypeSubstring:
            return @"sub";
        case ConditionTypeRegex:
            return @"reg";
        case ConditionTypeGeoLessOrEqual:
            return @"gl";
        default:
            return nil;
    }
}

@end
