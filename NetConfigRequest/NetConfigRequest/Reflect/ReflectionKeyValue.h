//
//  ReflectionKeyValue.h
//  Reflect
//
//  Created by summer.zhu on 31/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReflectionKeyValue <NSObject>

@optional
/**
 *  调用该方法返回模型array属性中存放对象的class
 */
- (NSDictionary *)classForArrayProperty;

@end
