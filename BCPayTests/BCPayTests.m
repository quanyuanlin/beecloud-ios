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

- (void)testPayReqWithBillNo {
    
    BCPayReq *req = [[BCPayReq alloc] init];
    req.channel = PayChannelAliApp;
    req.billNo = @"617";
    req.title = @"testWithBillNo";
    req.totalFee = @"1";
    req.scheme = @"payDemo";
    [BeeCloud sendBCReq:req];
    
    [self waitForStatus:XCTAsyncTestCaseStatusFailed timeout:0.5];
    XCTAssertFalse(testResp.resultCode == 0);
    
}


- (void)onBeeCloudResp:(BCBaseResp *)resp {
    testResp = resp;
    bFinish = YES;
}





@end
