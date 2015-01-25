//
//  NetConfigInput.m
//  NetConfigRequest
//
//  Created by zbq on 15-1-3.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigInput.h"

@implementation NetConfigInput

- (NSString *)urlHttp{
    return @"http://";
}

- (NSString *)urlHttps{
    return @"https://";
}

- (NSString *)userToken{
    return @"testUserToken";
}

- (NSString *)userSecret{
    return @"testSecret";
}

- (NSString *)userId{
    return @"testUserId";
}

- (NSString *)apiKey{
    return @"testApiKey";
}

- (NSString *)apiSecrect{
    return @"testApiSecrect";
}

- (NSString *)source{
    return @"testSource";
}

- (NSString *)appName{
    return @"testAppName";
}

- (NSString *)appVersion{
    return @"testAppVersion";
}

- (NSString *)warehouse{
    return @"testWarehouse";
}

- (NSDictionary *)dicSign{
    return nil;
}

@end
