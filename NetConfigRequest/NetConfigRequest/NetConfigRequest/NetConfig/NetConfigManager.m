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
#import "NetConfigModelDefaultManager.h"
#import "NetConfigRequestDataDefaultManager.h"
#import "NetConfigDefaultSign.h"
#else
#endif

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
        _netConfigModel = [[NetConfigModelDefaultManager alloc] init];
        _netConfigRequestData = [[NetConfigRequestDataDefaultManager alloc] init];
        _netConfigSign = [[NetConfigDefaultSign alloc] init];
#else
        
#endif
    }
    return self;
}

- (void)request:(NSString *)modelKey response:(ResponseBlock)res{
    
}

@end
