//
//  BCPayTests.m
//  BCPayTests
//
//  Created by joseph on 15/11/5.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BeeCloud.h"
#import "XCTestCase+AsyncTesting.h"
#import "BeeCloud+Utils.h"

@interface BCPayTests : XCTestCase<BeeCloudDelegate> {
    int testId;
    BCBaseResp *testResp;
    BOOL bFinish;
}

@end

@implementation BCPayTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [BeeCloud initWithAppID:@"c37d661d-7e61-49ea-96a5-68c34e83db3b" andAppSecret:@"c37d661d-7e61-49ea-96a5-68c34e83db3b"];
    [BeeCloud setBeeCloudDelegate:self];
    testId = 0;
    bFinish = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testCheckParametersForReqPay {

    BeeCloud *instance = [BeeCloud sharedInstance];
    BCPayReq * req = [[BCPayReq alloc] init];
    
    req.title = @"";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.title = @"123456781234567812345678123456781";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.title = @"比可网络比可网络比可网络比可网络比可网络";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.title = @"test";
    req.totalFee = @"aaa";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.totalFee = @"";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.totalFee = @"1";
    req.billNo = @"1212";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.billNo = @"abcdefgh&*&^";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.billNo = @"123456781234567812345678123456781";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.billNo = @"2015110616001200";
    req.channel = PayChannelAliApp;
    req.scheme = @"";
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.channel = PayChannelUnApp;
    req.viewController = nil;
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.channel = PayChannelWxApp;
    XCTAssertFalse([instance checkParametersForReqPay:req]);
    
    req.channel = PayChannelBaiduApp;
    XCTAssertTrue([instance checkParametersForReqPay:req]);
}


- (void)onBeeCloudResp:(BCBaseResp *)resp {
    testResp = resp;
    bFinish = YES;
}





@end
