//
//  NetConfigRequestTests.m
//  NetConfigRequestTests
//
//  Created by summer.zhu on 31/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NetConfigModelDefaultManagerTest.h"
#import "NetConfigDefaultReflectTest.h"

@interface NetConfigRequestTests : XCTestCase

@end

@implementation NetConfigRequestTests

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
//    [NetConfigModelDefaultManagerTest test];
    [NetConfigDefaultReflectTest test];
    [NetConfigDefaultReflectTest test2];
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
