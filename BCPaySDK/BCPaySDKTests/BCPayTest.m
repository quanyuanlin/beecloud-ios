//
//  BCPayTest.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/21.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+AsyncTesting.h"
#import "BCPaySDK.h"
@interface BCPayTest : XCTestCase

@end

@implementation BCPayTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testQueryOrder {
    NSArray *array = [BCQueryOrder queryOrder:@"11" orderid:@"20150721232920558"];
}

@end
