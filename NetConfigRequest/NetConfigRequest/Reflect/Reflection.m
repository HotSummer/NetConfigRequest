//
//  Reflection.m
//  Reflect
//
//  Created by summer.zhu on 1/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reflection.h"
#import <objc/runtime.h>
#import "ReflectionException.h"
#import "ReflectionProperty.h"
#import "NSObject+Reflection.h"

@interface Reflection ()

@end

@implementation Reflection

#pragma mark - Data To Class
+ (NSObject *)objectFromContent:(id)content className:(NSString *)className{
    NSObject *object = [[NSClassFromString(className) alloc] init];
    [Reflection objectFromContent:content object:&object];
    return object;
}

+ (void)objectFromContent:(id)content object:(NSObject **)object{
    if ([content isKindOfClass:[NSDictionary class]]) {//字典映射成对象
        [Reflection objectFromJSONDictionary:(NSDictionary *)content object:object];
    }else if ([content isKindOfClass:[NSArray class]]){//数组映射成对象(数组对象)
        if ([*object isKindOfClass:[NSArray class]]) {
            if ([*object respondsToSelector:@selector(classForArrayProperty)]) {
                NSDictionary *dic = [*object classForArrayProperty];
                if (dic.count > 1) {//数组里面是自定义的对象不止一个，这时无法解析
                    [ReflectionException cantReflectionArray:NSStringFromClass([*object class])];
                }else if(dic.count == 1) {//数组里面是自定义的对象
//                    NSString *className = [dic allValues][0];
                    NSString *arrayName = [dic allKeys][0];
                    NSArray *datas = [Reflection parseObjectArrayFromArray:*object arrayName:arrayName contents:(NSArray *)content];
                    *object = [NSArray arrayWithArray:datas];
                }else{//数组里面不是自定义的对象
                    *object = [NSArray arrayWithArray:(NSArray *)content];
                }
            }else{
                *object = [NSArray arrayWithArray:(NSArray *)content];
            }
        }else{
            if ([*object respondsToSelector:@selector(classForArrayProperty)]) {
                NSDictionary *dic = [*object classForArrayProperty];
                if (dic.count > 1) {//数组里面是自定义的对象不止一个，这时无法解析
                    [ReflectionException cantReflectionArray:NSStringFromClass([*object class])];
                }else if(dic.count == 1) {//数组里面是自定义的对象
//                    NSString *className = [dic allValues][0];
                    NSString *arrayName = [dic allKeys][0];
                    NSArray *datas = [Reflection parseObjectArrayFromArray:*object arrayName:arrayName contents:(NSArray *)content];
                    [*object setValue:datas forKey:arrayName];
                }else{//数组里面不是自定义的对象
                    
                }
            }
        }
    }
}

+ (NSObject *)objectFromJSONDictionary:(NSDictionary *)jsonDictionary className:(NSString *)className{
    Class class = NSClassFromString(className);
    NSObject *reflectionObject = [[class alloc] init];
    
    [Reflection objectFromJSONDictionary:jsonDictionary object:&reflectionObject];
    
    return reflectionObject;
}

+ (void)objectFromJSONDictionary:(NSDictionary *)jsonDictionary object:(NSObject **)object{
    [jsonDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [Reflection setValueForKey:*object propertyName:key value:obj];
    }];
}

+ (void)setValueForKey:(NSObject *)object propertyName:(NSString *)propertyName value:(id)value{
    NSString *type = [ReflectionProperty type:[object class] propertyName:propertyName];
    if ([ReflectionException canAssignment:object propertyName:propertyName value:value]) {//如果可以赋值（存在并且类型一致）
        if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"]) {
            [object setValue:[NSNumber numberWithInteger:[value integerValue]] forKey:propertyName];
        }else if ([type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"]) {
            [object setValue:[NSNumber numberWithLongLong:[value longLongValue]] forKey:propertyName];
        }else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
            [object setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:propertyName];
        }else if ([type isEqualToString:@"B"]){
            [object setValue:[NSNumber numberWithInteger:[value boolValue]] forKey:propertyName];
        }else if([type isEqualToString:@"NSNumber"]){
            [object setValue:value forKey:propertyName];
        }else if ([type isEqualToString:@"NSString"]) {
            [object setValue:[NSString stringWithFormat:@"%@",value] forKey:propertyName];
        }else if (type == nil){
            [object setValue:[NSNull null] forKey:propertyName];
        }else if ([type isEqualToString:@"NSArray"]){
            [Reflection setArrayToObject:&object propertyName:propertyName data:(NSArray *)value];
        }else if ([type isEqualToString:@"NSDictionary"]){
            [object setValue:value forKey:propertyName];
        }else{//自定义的类
            id objectParam = [Reflection objectFromContent:value className:type];//根据value创建一个对应的id数据
            [object setValue:objectParam forKey:propertyName];
        }
    }else if (type.length > 0){//属性存在，但是类型不一致
        NSObject *obj = [Reflection objectFromContent:value className:type];//将数据变成type的对象(NSDictionary到class)
        if ([obj isKindOfClass:NSClassFromString(type)]) {//如果类型正确，则赋值
            [object setValue:obj forKey:propertyName];
        }else{//否则报错
            [ReflectionException matchType:[object class] propertyName:propertyName value:obj];
        }
    }
}

+ (void)setArrayToObject:(NSObject **)object propertyName:(NSString *)property data:(NSArray *)array{
    if ([ReflectionProperty type:[*object class] propertyName:property].length > 0) {//object有这个属性
        if ([*object respondsToSelector:@selector(classForArrayProperty)]) {//指定数组里面的数据类型，则解析后赋值
            NSArray *arr = [Reflection parseObjectArrayFromArray:*object arrayName:property contents:array];
            [*object setValue:arr forKey:property];
        }else{//没有指定数组里面的数据类型，则直接赋值
            [*object setValue:array forKey:property];
        }
    }
}

+ (NSArray *)parseObjectArrayFromArray:(NSObject *)object arrayName:(NSString *)arrayName contents:(NSArray *)contents{
    NSMutableArray *arrRecursion = [[NSMutableArray alloc] init];
    for (id content in contents) {
        NSString *className = @"";
        if ([object respondsToSelector:@selector(classForArrayProperty)]) {
            NSDictionary *dic = [object classForArrayProperty];
            className = dic[arrayName];
        }
        if ([ReflectionException hasKey:[object class] propertyName:arrayName]) {
            if ([content isKindOfClass:NSClassFromString(className)]) {
                Class theClass = NSClassFromString(className);
                NSObject *objectContent = [[theClass alloc] init];
                [Reflection objectFromContent:content object:&objectContent];
                [arrRecursion addObject:objectContent];
            }else{
                NSObject *obj = [Reflection objectFromContent:content className:className];
                if ([obj isKindOfClass:NSClassFromString(className)]) {//如果类型正确，则添加到数据
                    [arrRecursion addObject:obj];
                }else{//否则报错
                    [ReflectionException matchArrayType:[object class] arrayName:arrayName classInArry:className value:obj];
                }
            }
        }
    }
    return arrRecursion;
}

+ (NSArray *)parseArrayData:(NSArray *)data classNameInArray:(NSString *)className{
    if (className.length == 0) {
        return data;
    }else{
        NSMutableArray *objectsArray = [NSMutableArray array];
        for (id content in data) {
            NSObject *object = [Reflection objectFromContent:content className:className];
            if (object) {
                [objectsArray addObject:object];
            }
        }
        return objectsArray;
    }
}

#pragma mark - Class To Data
+ (NSDictionary *)dictionaryFromObject:(NSObject *)object{
    NSMutableDictionary *finalDict = [NSMutableDictionary dictionary];
    if (object) {
        NSDictionary *dic = [Reflection dictionaryFromObject:object class:NSStringFromClass([object class])];
        [finalDict addEntriesFromDictionary:dic];
        
        Class supplerClass = class_getSuperclass([object class]);
        while (supplerClass != [NSObject class]) {
            NSDictionary *dic = [Reflection dictionaryFromObject:object class:NSStringFromClass(supplerClass)];
            supplerClass = class_getSuperclass(supplerClass);
            [finalDict addEntriesFromDictionary:dic];
        }
    }
    return finalDict;
}

+ (NSDictionary *)dictionaryFromObject:(NSObject *)object class:(NSString *)class{
    if ([ReflectionException isSubclass:NSStringFromClass([object class]) compare:class]) {
        NSMutableDictionary *finalDict = [NSMutableDictionary dictionary];
        
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(NSClassFromString(class), &outCount);
        
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *name = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            NSString *type = [ReflectionProperty type:[object class] propertyName:name];
            SEL selector = NSSelectorFromString(name);
            if ([object respondsToSelector:selector]) {//保证取到共有属性
                id value = [object valueForKey:name];//[object performSelector:selector];
                if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"]) {
                    [finalDict setObject:[NSNumber numberWithInteger:[value integerValue]] forKey:name];
                } else if ([type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"]) {
                    [finalDict setObject:[NSNumber numberWithLongLong:[value longLongValue]] forKey:name];
                } else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
                    [finalDict setObject:[NSNumber numberWithDouble:[value doubleValue]] forKey:name];
                } else if ([type isEqualToString:@"NSString"]) {
                    [finalDict setObject:[NSString stringWithFormat:@"%@", value] forKey:name];
                }else if ([type isEqualToString:@"B"]){
                    [finalDict setObject:[NSNumber numberWithBool:[value boolValue]] forKey:name];
                } else if ([type isEqualToString:@"c"]) {
                    [finalDict setObject:[NSNumber numberWithChar:[value charValue]] forKey:name];
                } else if ([type isEqualToString:@"NSNumber"]){
                    [finalDict setObject:value forKey:name];
                } else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSArray"]) {
                    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:value];
                    NSMutableArray *results = [[NSMutableArray alloc] init];
                    for (id onceId in array) {
                        [results addObject:[Reflection dictionaryFromObject:onceId]];
                    }
                    [finalDict setObject:results forKey:name];
                } else if ([type isEqualToString:@"NSMutableDictionary"] || [type isEqualToString:@"NSDictionary"]){
                    [finalDict setObject:value forKey:name];
                }else if([type isEqualToString:@"NSNull"]){//自定义的类
                    [finalDict setObject:[NSNull null] forKey:name];
                }else{//自定义的类
                    NSDictionary *dic = [Reflection dictionaryFromObject:value];
                    [finalDict setObject:dic forKey:name];
                }
            }
        }
        free(properties);
        return finalDict;
    }else{
        return nil;
    }
}

@end
