//
//  NSObject+Reflection.h
//  BuyProgress
//
//  Created by summer.zhu on 10/9/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用于获取模型类中array中存放对象映射对应class的方法名
 */
#define kClassForArrayPropertyMethodName @"classForArrayProperty"

@protocol ReflectionKeyValue <NSObject>

@optional
/**
 *  调用该方法返回模型array属性中存放对象的class
 */
- (NSDictionary *)classForArrayProperty;
@end

@interface NSObject (Reflection) <ReflectionKeyValue>

@end
