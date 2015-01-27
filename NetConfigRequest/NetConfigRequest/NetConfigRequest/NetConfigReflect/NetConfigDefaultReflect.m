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
        if (array.count == 1) {
            [paramers setObject:array[0] forKey:key];
        }else{
            NSString *strClass = array[0];
            NSObject *object;
            NSString *requestClassName = NSStringFromClass([requestObj class]);
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
        }
    }];
    
    return nil;
}

- (void)responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObject:(NSObject *)responseObject{
}


@end
