//
//  ReadValue.h
//  ReadValueFromPath
//
//  Created by summer.zhu on 31/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadValue : NSObject

/**
 *  根据路径从object读取对应的值。例如：ClassA.proprtyA,表示从ClassA获取proprtyA属性。
 *
 *  @param path   值的路径
 *  @param object 原对象
 *
 *  @return 返回对应的值
 */
+ (id)readValueFromPath:(NSString *)path sourceObject:(NSObject *)object;

@end
