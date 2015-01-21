//
//  NetConfigInput.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-3.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 给默认的数据源()提供数据
 */
@interface NetConfigInput : NSObject

- (NSString *)userToken;
- (NSString *)userSecret;
- (NSString *)userId;
- (NSString *)apiKey;
- (NSString *)apiSecrect;
- (NSString *)source;
- (NSString *)appName;
- (NSString *)appVersion;
- (NSString *)warehouse;

@end