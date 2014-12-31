//
//  ReflectionProperty.h
//  Reflect
//
//  Created by summer.zhu on 4/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReflectionProperty : NSObject

/**
 *  获取Class的属性的类型。当Class没有这个属性的时候，返回nil。获取类型的顺序时，如果在本类找不到， 就从父类中查找，依次向上查找，直到NSObject为止
 *
 *  @param class       对象class
 *  @param propertyName 属性名称
 *
 *  @return 属性类型
 */
+ (NSString *)type:(Class)class propertyName:(NSString *)propertyName;

/**
 *  仅在本类中查找该属性的类型
 *
 *  @param class        对象class
 *  @param propertyName 属性名称
 *
 *  @return 属性类型
 */
+ (NSString *)typeInThisClass:(Class)class propertyName:(NSString *)propertyName;

/**
 *  是否为基础类型（int, float, double, NSNumber等）
 *
 *  @param type 类型名
 *
 *  @return YES or NO
 */
+ (BOOL)basicType:(NSString *)type;

@end
