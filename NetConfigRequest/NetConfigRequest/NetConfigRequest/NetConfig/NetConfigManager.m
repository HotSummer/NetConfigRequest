//
//  NetConfigManager.m
//  NetConfigRequest
//
//  Created by zbq on 15-1-3.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigManager.h"
#import "NetConfigDefine.h"

#ifdef UserDefault
#import "AFNetWorkRequest.h"
#import "NetConfigDefaultReflect.h"
#import "NetConfigModelDefaultManager.h"
#import "NetConfigRequestDataDefaultManager.h"
#import "NetConfigDefaultSign.h"
#else
#endif

@interface NetConfigManager ()

//- (void)request:(NSString *)modelKey response:(ResponseBlock)res;

@end

@implementation NetConfigManager

+ (instancetype)shareInstance{
    static NetConfigManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[NetConfigManager alloc] init];
    });
    return manager;
}

- (id)init{
    if (self = [super init]) {
#ifdef UserDefault
        _request = [[AFNetWorkRequest alloc] init];
        _netConfigReflect = [[NetConfigDefaultReflect alloc] init];
        _netConfigModel = [[NetConfigModelDefaultManager alloc] init];
        _netConfigRequestData = [[NetConfigRequestDataDefaultManager alloc] init];
        _netConfigSign = [[NetConfigDefaultSign alloc] init];
#else
        
#endif
    }
    return self;
}

- (void)request:(NSString *)modelKey requestObject:(NSObject *)req responseObject:(NSObject *)res
       response:(ResponseBlock)resblock{
    NetConfigModel *model = [_netConfigModel getModel:modelKey];
    NSDictionary *dicRequest = [_netConfigReflect requestDataFromConfig:model requestObject:req];
    [_request request:@"" sign:@"" ssl:model.ssl method:model.method requestParmers:dicRequest response:^(int code, NSString *message, id content, NSError *error) {
        [_netConfigReflect responseObjectFromConfig:model contentData:content responseObject:res];
        resblock(code, message, content, error);
    }];
    
}

- (void)request:(NSString *)modelKey requestObject:(NSObject *)req responseClass:(NSString *)className response:(ResponseBlock)resblock{
    NSObject *object = [[NSClassFromString(className) alloc] init];
    [self request:modelKey requestObject:req responseObject:object response:resblock];
}

@end
