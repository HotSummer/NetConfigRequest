//
//  ReflectionException.h
//  Reflect
//
//  Created by summer.zhu on 1/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReflectionException : NSObject

/**
 *  属性不存在：对象是否含有key这个属性 
 *
 *  @param class 对象Class
 *  @param key    欲赋值的属性名
 *
 *  @return YES or NO
 */
+ (BOOL)hasKey:(Class)class propertyName:(NSString *)propertyName;

/**
 *  类型不匹配:对象的key属性类型跟value的类型是否匹配
 *
 *  @param class 对象Class
 *  @param key    待判断的属性名
 *  @param value  待判断的属性值
 *
 *  @return YES or NO
 */
+ (BOOL)matchType:(Class)class propertyName:(NSString *)propertyName value:(id)value;

/**
 *  判断类的数组属性中数据类型是否一致
 *
 *  @param class        类名
 *  @param arrayName    数组名
 *  @param classInArray 数组中数据的类名
 *  @param value        赋值对象
 *
 *  @return YES or NO
 */
+ (BOOL)matchArrayType:(Class)class arrayName:(NSString *)arrayName classInArry:(NSString *)classInArray value:(id)value;


/**
 *  能否给object赋值
 *
 *  @param object 对象
 *  @param key    赋值的key
 *  @param value  赋值的value
 *
 *  @return YES or NO
 */
+ (BOOL)canAssignment:(NSObject *)object propertyName:(NSString *)propertyName value:(id)value;

/**
 *  两个类是否是集成关系
 *
 *  @param classSub   子类
 *  @param classSuper 父类
 *
 *  @return YES or NO
 */
+ (BOOL)isSubclass:(NSString *)classSub compare:(NSString *)classSuper;

/**
 *  无法解析数组异常提示
 *
 *  @param class 类名
 */
+ (void)cantReflectionArray:(NSString *)class;

@end
