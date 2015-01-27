//
//  NetConfigDefaultReflect.m
//  NetConfigRequest
//
//  Created by summer.zhu on 22/1/15.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigDefaultReflect.h"
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
            
            //第二部获取对应的属性值
            if (!object) {
                NSLog(@"为找到该对象");
            }else{
                for (int i=1; i<array.count; i++) {
                    object = [object valueForKey:array[i]];
                }
                
                [paramers setObject:object forKey:key];
            }
        }
    }];
    
    return paramers;
}

- (void)responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObject:(NSObject *)responseObject{
}


@end
