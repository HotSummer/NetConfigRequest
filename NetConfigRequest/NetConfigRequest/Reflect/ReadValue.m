//
//  ReadValue.m
//  ReadValueFromPath
//
//  Created by summer.zhu on 31/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import "ReadValue.h"
#import "ReflectionException.h"

@implementation ReadValue

+ (id)readValueFromPath:(NSString *)path sourceObject:(NSObject *)object{
    NSArray *array = [(NSString*)path componentsSeparatedByString:@"."];
    
    NSObject *valueObject = object;
    for (int i = 1; i<array.count; i++) {
        NSString *strValue = array[i];
        if ([ReflectionException hasKey:[valueObject class] propertyName:strValue]) {
            NSRange rangeFun = [strValue rangeOfString:@"{"];
            if (rangeFun.length > 0) {
                NSString *selectorName = [strValue substringFromIndex:rangeFun.location+1];
                SEL function = NSSelectorFromString(selectorName);
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                valueObject = [valueObject performSelector:function];
            }else{
                valueObject = [valueObject valueForKey:array[i]];
            }
        }
    }
    return valueObject;
}

@end
