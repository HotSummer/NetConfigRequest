//
//  ReflectionException.m
//  Reflect
//
//  Created by summer.zhu on 1/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReflectionException.h"
#import "ReflectionProperty.h"
#import "ReflectionDefine.h"

@implementation ReflectionException

+ (BOOL)hasKey:(Class)class propertyName:(NSString *)propertyName{
    NSString *type = [ReflectionProperty type:class propertyName:propertyName];
    if (type.length > 0) {
        return YES;
    }else{
#ifdef ShowException
        NSString *strException = [NSString stringWithFormat:@"%@.%@ not found", NSStringFromClass(class), propertyName];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:strException message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
        
        NSLog(@"%@", strException);
#endif
        return NO;
    }
}

+ (BOOL)matchType:(Class)class propertyName:(NSString *)propertyName value:(id)value{
    NSString *type = [ReflectionProperty type:class propertyName:propertyName];//根据key拿到key的类型
    bool canMatch = NO;
    if ([ReflectionProperty basicType:type]) {//是基础数据类型 eg:@"i", @"l", @"f"
        canMatch = [ReflectionException basicMatchRule:value];
    }else{//id类型的判断
        canMatch = [ReflectionException idMatchRule:value class:NSClassFromString(type)];
    }
    
    if (!canMatch) {
#ifdef ShowException
        NSString *strException = [NSString stringWithFormat:@"%@.%@类型不匹配：一个是%@，一个是%@", NSStringFromClass(class), propertyName, NSStringFromClass([value class]), type];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:strException message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
        
        NSLog(@"%@", strException);
#endif
    }
    
    return canMatch;
}

+ (BOOL)matchArrayType:(Class)class arrayName:(NSString *)arrayName classInArry:(NSString *)classInArray value:(id)value{
    if ([value isKindOfClass:NSClassFromString(classInArray)]) {
        return YES;
    }else{
#ifdef ShowException
        NSString *strException = [NSString stringWithFormat:@"%@.%@数组内元素不匹配：数组内数据类型是%@，所传的值类型是%@", NSStringFromClass(class), arrayName, classInArray, NSStringFromClass([value class])];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:strException message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
        
        NSLog(@"%@", strException);
#endif
        return NO;
    }
}

/**
 *  基础数据类型是否一致的判断，只有当时NSNumber的时候才能通过
 *
 *  @param typeCompare 比较对象的类型
 *
 *  @return YES
 */
+ (BOOL)basicMatchRule:(id)value{
    if ([value isKindOfClass:[NSNumber class]]) {
        return YES;
    }else{
        return NO;
    }
}

/**
 *  非基础数据类型是否一致的判断，要用value，不可以用[value class]
 *
 *  @param value 比较对象
 *  @param class class
 *
 *  @return YES or NO
 */
+ (BOOL)idMatchRule:(id)value class:(Class)class{
    return [value isKindOfClass:class];
}

+ (BOOL)canAssignment:(NSObject *)object propertyName:(NSString *)propertyName value:(id)value{
    return [ReflectionException hasKey:[object class] propertyName:propertyName] && [ReflectionException matchType:[object class] propertyName:propertyName value:value];
}

+ (BOOL)isSubclass:(NSString *)classSub compare:(NSString *)classSuper{
    Class subClass = NSClassFromString(classSub);
    Class superClass = NSClassFromString(classSuper);
    if (subClass == superClass || superClass == [NSObject class]) {
        return YES;
    }else{
        if ([subClass isSubclassOfClass:superClass]) {
            return YES;
        }else{
#ifdef ShowException
            NSString *strException = [NSString stringWithFormat:@"%@和%@不存在继承关系", classSub, classSuper];
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:strException message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertview show];
            
            NSLog(@"%@", strException);
#endif
            return NO;
        }
    }
}

+ (void)cantReflectionArray:(NSString *)class{
#ifdef ShowException
    NSString *message = [NSString stringWithFormat:@"%@数组里面多个自定义对象无法解析", class];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertview show];
    NSLog(@"%@", message);
#endif
}

@end
