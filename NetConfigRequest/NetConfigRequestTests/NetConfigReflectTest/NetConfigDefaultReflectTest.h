//
//  NetConfigDefaultReflectTest.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-27.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetConfigDefaultReflectTest : NSObject
//测试requestDataFromConfig:requestObject:
+ (void)test;

//测试requestDataFromConfig:requestObjects:
+ (void)test2;

//测试responseObjectFromConfig:contentData:responseObject:
+ (void)test3;

//测试- (void)responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObjects:(NSArray *)responseObjects
+ (void)test4;

@end
