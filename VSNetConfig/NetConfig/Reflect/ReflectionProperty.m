//
//  ReflectionProperty.m
//  Reflect
//
//  Created by summer.zhu on 4/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import "ReflectionProperty.h"
#import <objc/runtime.h>

/**
 *  当编译器遇到属性声明时，它会生成一些可描述的元数据（metadata），将其与相应的类、category和协议关联起来。存在一些函数可以通过名称在类或者协议中查找这些metadata
 *
 *  @param property 一个指向属性描述符的不透明句柄
 *
 *  @return 属性类型
 */
static const char* getPropertyType(objc_property_t property) {
    //获取编码后的属性类型, 字符串以T开头，紧接@encode type和逗号，接着以V和变量名结尾。
    //例如：@property char charDefault;  Tc,VcharDefaults  @property(retain)ididRetain;  T@,&,VidRetain @property(copy)NSString *content; T@"NSString"
    //具体@encode type参见https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
    //当是NULL类型的时候,返回值为nil
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);//复制属性的attribute列表
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

@implementation ReflectionProperty

+ (NSString *)type:(Class)class propertyName:(NSString *)propertyName{
    NSString *propertyType = nil;
    
    propertyType = [ReflectionProperty typeInThisClass:class propertyName:propertyName];//现在本类中查找
    
    if (propertyType.length == 0) {//如果在本类找不到， 就从父类中查找，一次向上查找
        Class supplerClass = class_getSuperclass(class);
        while (supplerClass != [NSObject class] && supplerClass != nil && propertyType.length == 0) {
            propertyType = [ReflectionProperty typeInThisClass:supplerClass propertyName:propertyName];
            supplerClass = [supplerClass superclass];
        }
    }
    
    return propertyType;
}

+ (NSString *)typeInThisClass:(Class)class propertyName:(NSString *)propertyName{
    unsigned int propertyCount;
    objc_property_t *pProperty = class_copyPropertyList(class, &propertyCount);
    NSString *type = nil;
    for (int i = 0; i<propertyCount; i++) {
        objc_property_t property = pProperty[i];
        NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
        if ([propertyname isEqualToString:propertyName]) {
            //匹配的属性
            type = [NSString stringWithUTF8String:getPropertyType(property)];
            break;
        }
    }
    return type;
}

+ (BOOL)basicType:(NSString *)type{
    if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"] ||
        [type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"] ||
        [type isEqualToString:@"f"] || [type isEqualToString:@"d"] || [type isEqualToString:@"B"] ||[type isEqualToString:@"NSNumber"]) {//基础类型
        return YES;
    }
    return NO;
}

@end
