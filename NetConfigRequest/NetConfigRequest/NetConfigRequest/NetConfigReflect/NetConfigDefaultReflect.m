//
//  NetConfigDefaultReflect.m
//  NetConfigRequest
//
//  Created by summer.zhu on 22/1/15.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigDefaultReflect.h"
#import "ReflectionException.h"
#import "NetConfigDefine.h"
#import "NetConfigModel.h"

@implementation NetConfigDefaultReflect

- (NSDictionary *)requestDataFromConfig:(NetConfigModel *)configModel requestObject:(NSObject *)requestObj{
    NSMutableDictionary *paramers = [NSMutableDictionary dictionary];
    [configModel.reqParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *array = [(NSString*)obj componentsSeparatedByString:@"."];
        if (array.count == 1) {//直接赋值，无需解析
            [paramers setObject:array[0] forKey:key];
        }else{//解析
            NSString *strClass = array[0];
            NSObject *object;
            NSString *requestClassName = NSStringFromClass([requestObj class]);
            
            //第一步获取对象
            //配制的类名和对象的类名一致,则从该对象中获取值
            if ([strClass isEqualToString:requestClassName]) {
                object = requestObj;
            }else{//不一致的话，调用shareInstance方法创建该对象
                Class class = NSClassFromString(strClass);
                NSObject *obj = (NSObject *)class;
                if ([obj respondsToSelector:@selector(shareInstance)]) {
                    object = [obj performSelector:@selector(shareInstance)];
                }
            }
            
            //第二步获取对应的属性值
            if (!object) {
                NCLog(@"未找到该对象%@", strClass);
            }else{
                for (int i=1; i<array.count; i++) {
                    //该类是否有该属性
                    if ([ReflectionException hasKey:object.class propertyName:array[i]]) {
                        object = [object valueForKey:array[i]];
                    }
                }
                
                [paramers setObject:object forKey:key];
            }
        }
    }];
    
    return paramers;
}

- (NSDictionary *)requestDataFromConfig:(NetConfigModel *)configModel requestObjects:(NSArray *)requestObjs{
    NSMutableDictionary *mutableDicRequest = [NSMutableDictionary dictionary];
    for (NSObject *object in requestObjs) {
        NSDictionary *dicRequest = [self requestDataFromConfig:configModel requestObject:object];
        [mutableDicRequest addEntriesFromDictionary:dicRequest];
    }
    return mutableDicRequest;
}

/**
 *  负责解析服务器返回的数据，并将数据赋值到相关的model中
 *
 *  @param responseObject 服务器返回的数据
 *  @param config         配置信息
 *  @param requestObject  被赋值的model对象
 */
/*
+(void)parseData:(id)responseObject config:(BaseNetwork*)config :(void (^)(NSInteger code,NSString *msg)) callBack request:(NSObject *)requestObject{
    NSInteger code = -1;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        code = [responseObject[@"code"] integerValue];
        [config.resParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            //根据路径（key）获取返回数据中的值
            NSArray *keyArr = [(NSString*)key componentsSeparatedByString:@"."];
            id value = responseObject;
            for (int i = 0; i<keyArr.count; i++) {
                @try {
                    value =  [value valueForKey:keyArr[i]];
                    if (i != keyArr.count-1) {
                        if (!value) {
#ifdef SHOW_Debug
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结构化错误,路径不对" message:key delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
#endif
                        }
                    }
                }
                @catch (NSException *exception) {
                    [BFMRequest showException:exception path:key];
                }
                @finally {
                    
                }
            }
            //根据路径（obj）获取对应类的属性名
            NSArray *array = [(NSString*)obj componentsSeparatedByString:@"."];
            NSString *strClass = array[0];
            NSObject *object;
            if ([strClass isEqualToString:NSStringFromClass([requestObject class])]) {
                object = requestObject;
            }else{
                object = [NSClassFromString(array[0]) shareInstance];
            }
            for (int i = 1; i<array.count-1; i++) {
                @try {
                    object = [object valueForKey:array[i]];
                }
                @catch (NSException *exception) {
                    [BFMRequest showException:exception path:key];
                }
                @finally {
                    
                }
            }
            
            //将返回数据中的值 赋值给 对应类的属性名
            unsigned int propertyCount;
            objc_property_t *pProperty = class_copyPropertyList([object class], &propertyCount);
            NSString *type = nil;
            for (int i = 0; i<propertyCount; i++) {
                objc_property_t property = pProperty[i];
                NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                if ([propertyname isEqualToString:[array lastObject]]) {
                    //匹配的属性
                    type = [NSString stringWithUTF8String:getPropertyType(property)];
                    break;
                }
            }
            if (!type) {//当本类中不包含这个属性名，则在父类中查找
                Class A = [[object class] superclass];
                while (![NSStringFromClass(A) isEqualToString:@"NSObject"]) {
                    pProperty = class_copyPropertyList(A, &propertyCount);
                    for (int i = 0; i<propertyCount; i++) {
                        objc_property_t property = pProperty[i];
                        NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                        if ([propertyname isEqualToString:[array lastObject]]) {
                            //匹配的属性
                            type = [NSString stringWithUTF8String:getPropertyType(property)];
                            break;
                        }
                    }
                    A = [A superclass];
                }
            }
            
            NSString *propertyKey = [array lastObject];
            [BFMRequest setResponseDataToValue:type value:value key:key object:object propertyKey:propertyKey];
        }];
    }else{
        NSLog(@"%@",responseObject);
    }
    NSLog(@"code:%d, msg:%@", (int)code, responseObject[@"msg"]);
    callBack(code,responseObject[@"msg"]);
}
 */
- (void)responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObject:(NSObject *)responseObject{
    
    [configModel.resParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //根据路径（key）获取返回数据中的值
        NSArray *keyArr = [(NSString*)key componentsSeparatedByString:@"."];
        id value = responseObject;
    }];
}

- (void)responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObjects:(NSArray *)responseObjects{
    for (NSObject *object in responseObjects) {
        [self responseObjectFromConfig:configModel contentData:contentData responseObject:object];
    }
}


@end
