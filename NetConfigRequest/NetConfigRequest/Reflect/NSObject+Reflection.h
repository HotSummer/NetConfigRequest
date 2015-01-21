//
//  NSObject+Reflection.h
//  BuyProgress
//
//  Created by summer.zhu on 10/9/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReflectionKeyValue.h"

/**
 *  用于获取模型类中array中存放对象映射对应class的方法名
 */
#define kClassForArrayPropertyMethodName @"classForArrayProperty"

@interface NSObject (Reflection) <ReflectionKeyValue>

@end
