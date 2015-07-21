//
//  BCConfig.h
//  BeeCloud
//
//  Created by Junxian Huang on 7/31/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCLocation.h"

/**
 *  BCConfig provides an easy way for developers to define different types of cloud variables via
 *  http://beecloud.cn/dashboard BCConfig settings page at any time. Then, applications can access the defined variables
 *  at the clients using the following simple methods.
 *
 *  In order to save bandwidth/energy usage on end-user devices, we always try to use the local cached copy of each
 *  config value, if i) there is one (calling any get method will automatically produce a cached copy of the config);
 *  and ii) the cached copy has not expired (the age of this copy is no more than the TTL set in the website by the
 *  developer).
 *
 *  Notice that no two configs share the same name, even when they have different types, for avoiding confusion. Config
 *  names are case in-sensitive.
 *
 *  TODO: read multiple configs in one shot. Multiple configs may have multiple TTLs and each one of them will be
 *  respected respectively. This can optimize the network usage of reading multiple configs into 1 or even 0 round-trip 
 *  communications with the server.
 */
@interface BCConfig : NSObject

/**
 *  Get BOOL configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of the
 *  config value (if this function has been called before recently) will be used, instead of fetching from the cloud, if
 *  the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, NO will be returned.
 */
+ (BOOL)getBoolWithName:(NSString *)name;

/**
 *  Get int32 configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of the
 *  config value (if this function has been called before recently) will be used, instead of fetching from the cloud, if
 *  the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, 0 will be returned.
 */
+ (int)getInt32WithName:(NSString *)name;

/**
 *  Get int64 configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of the
 *  config value (if this function has been called before recently) will be used, instead of fetching from the cloud, if
 *  the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, 0 will be returned.
 */
+ (long long)getInt64WithName:(NSString *)name;

/**
 *  Get float configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of the
 *  config value (if this function has been called before recently) will be used, instead of fetching from the cloud, if
 *  the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, 0.0 will be returned.
 */
+ (float)getFloatWithName:(NSString *)name;

/**
 *  Get double configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of
 *  the config value (if this function has been called before recently) will be used, instead of fetching from the
 *  cloud, if the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig
 *  settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, 0.0 will be returned.
 */
+ (double)getDoubleWithName:(NSString *)name;

/**
 *  Get string configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of
 *  the config value (if this function has been called before recently) will be used, instead of fetching from the
 *  cloud, if the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig
 *  settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, nil will be returned.
 */
+ (NSString *)getStringWithName:(NSString *)name;

/**
 *  Get UUID configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of the
 *  config value (if this function has been called before recently) will be used, instead of fetching from the cloud, if
 *  the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, nil will be returned.
 */
+ (NSString *)getUUIDWithName:(NSString *)name;

/**
 *  Get date configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of the
 *  config value (if this function has been called before recently) will be used, instead of fetching from the cloud, if
 *  the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, nil will be returned.
 */
+ (NSDate *)getDateWithName:(NSString *)name;

/**
 *  Get location configuration value from the cloud. Notice that in order to reduce network usage, local cached copy of
 *  the config value (if this function has been called before recently) will be used, instead of fetching from the
 *  cloud, if the age of the local copy of this config is no more than its TTL, also specified in the website's BCConfig
 *  settings.
 *
 *  @param name Config name specified in the website's BCConfig settings. Config names are case-insensitive.
 *
 *  @return Config value. If no such config name exists, nil will be returned.
 */
+ (BCLocation *)getLocationWithName:(NSString *)name;

@end
