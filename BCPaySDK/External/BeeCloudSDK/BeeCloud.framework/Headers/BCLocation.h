//
//  BCLocation.h
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/19/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "BCConstants.h"

/**
 *  A class to represent a location in the map with latitude and longitude.
 */
@interface BCLocation : NSObject

#pragma mark - Properties
/** @name Class Properties */

/**
 *  Latitude of the location in degrees in range (-90.0, 90.0). Positive numbers for North.
 */
@property (nonatomic) double latitude;

/**
 *  Longitude of the location in degrees in range (-180.0, 180.0). Positive numbers for East.
 */
@property (nonatomic) double longitude;

#pragma mark - Create instances
/** @name Create New Location */

/**
 *  Create a new BCLocation object with both latitude and longitude set to 0.0.
 *
 *  @return Returns a new BCLocation.
 */
+ (BCLocation *)location;

/**
 *  Creates a new BCLocation object with the given latitude and longitude.
 *
 *  @param latitude Latitude of the location in degrees.
 *  @param longitude Longitude of the location in degrees.
 *
 *  @return New location object with the given latitude and longitude, or nil if input is not valid.
 */
+ (BCLocation *)locationWithLatitude:(double)latitude longitude:(double)longitude;

/**
 *  Creates a new BCLocation object with the given coordiante string in the format of "latitude,longitude".
 *
 *  @param string The given coordinate string in the format of "latitude,longitude".
 *
 *  @return New location object with the given latitude and longitude, or nil if input is not valid.
 */
+ (BCLocation *)locationWithString:(NSString *)string;

/**
 *  Get user's current location based on system's location information. If users choose not to share the accurate GPS
 *  information, the public IP address of the user will be used to infer the coarse-grained location of the user with
 *  city-level accuracy.
 *
 *  This method returns immediately and does not block.
 *
 *  @return Location object of the user's current location, or an empty location with latitude, longitude being 0 if
 *          failed.
 */
+ (BCLocation *)getCurrentLocation;

/**
 *  Get the coarse-grained location based on the given IP address.
 *
 *  This method is a synchronous network call and blocks until the network request is complete.
 *
 *  @param ip Input IP address, if nil, the current device's public IP address will be used.
 *
 *  @return Location object of the user's current location, or an empty location with latitude, longitude being 0 if
 *          failed.
 */
+ (BCLocation *)getLocationByIp:(NSString *)ip;

/**
 *  Get the coarse-grained location based on the given IP address.
 *
 *  This method is a asynchronous network call and does not block.
 *
 *  @param ip    Input IP address, if nil, the current device's public IP address will be used.
 *  @param block The block to execute. The block should have the following argument signature:
 *               (BCLocation *location, NSError *error)
 *               The location is nil if there is an error.
 */
+ (void)getLocationByIpInBackground:(NSString *)ip block:(BCLocationResultBlock)block;

#pragma mark - Calculating distance to another location
/** @name Calculating Distance to Another Location */

/**
 *  Get distance in meters from this location to the given location.
 *
 *  @param location Location of the other point.
 *
 *  @return Distance in meters.
 */
- (CLLocationDistance)distanceInMetersTo:(BCLocation*)location;

#pragma mark - Detailed info methods only for China
/** @name Get Detailed Address Info for China */

/**
 *  Get formatted address in Chinese for the current location.
 *
 *  @return Formatted address in Chinese, such as "北京市朝阳区光华路9号3-1", if the address is identified, or @"" (empty
 *          string) otherwise.
 */
- (NSString *)getFormattedAddress;

/**
 *  Get street name in Chinese for the current location.
 *
 *  @return Street name in Chinese, such as "光华路", if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getStreet;

/**
 *  Get street number in Chinese for the current location.
 *
 *  @return Street number in Chinese, such as "9号3-1", if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getStreetNumber;

/**
 *  Get district name in Chinese for the current location.
 *
 *  @return District name in Chinese, such as "朝阳区", if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getDistrict;

#pragma mark - General info methods for the world
/** @name Get General Address Info for the World */

/**
 *  Get city name in English. For Chinese locations, the name is in Chinese.
 *
 *  @return City name, if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getCity;

/**
 *  Get province/subdivision/state name in English. For Chinese locations, the name is in Chinese.
 *
 *  @return Province/subdivision/state name, if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getProvince;

/**
 *  Get country name in English. For Chinese locations, the country name is "China".
 *
 *  @return Country name, if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getCountry;

/**
 *  Get the two-character ISO 3166-1 country code for the country associated with the location.
 *
 *  @return The two-character country code for the country associated with the location, if the address is identified,
 *          or @"" (empty string) otherwise.
 */
- (NSString *)getCountryCode;

/**
 *  Get continent name in English. All continent names include "Africa", "Asia", "Europe", "North America", "Oceania"
 *  and "South America".
 *
 *  @return Continent name, if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getContinent;

/**
 *  Get the time zone associated with the location, as specified by the IANA Time Zone Database
 *  (http://www.iana.org/time-zones), e.g., "America/New_York" and "Asia/Shanghai".
 *
 *  @return The time zone associated with the location, if the address is identified, or @"" (empty string) otherwise.
 */
- (NSString *)getTimeZone;

#pragma mark - ToString method
/** @name ToString method */

/**
 *  Convert this location to string representation of "latitude,longitude".
 *
 *  @return String representation of this location.
 */
- (NSString *)toString;

@end
