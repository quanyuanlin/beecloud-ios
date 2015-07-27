//
//  BCBaseResult.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark BCBaseResult

@interface BCBaseResult : NSObject

@property (nonatomic, retain) NSString  *bill_no;
@property (nonatomic, assign) NSNumber  *total_fee;//NSInteger
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, retain) NSNumber  *created_time;//long long
@property (nonatomic, retain) NSString  *channel;

@end
