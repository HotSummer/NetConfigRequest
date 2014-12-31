//
//  VSClassAndRequest.h
//  VSBuyComponent
//
//  Created by summer.zhu on 18/11/14.
//  Copyright (c) 2014年 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSClassAndRequest : NSObject

/**
 *  获取Class和其对应请求数组
 *
 *  @return Class和其对应请求数组的dictionary
 */
+ (NSDictionary *)getClassAndRequests;

@end
