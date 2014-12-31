//
//  VSSystemConfig.h
//  testFrameWork
//
//  Created by YaoMing on 14-9-11.
//  Copyright (c) 2014年 vipshop. All rights reserved.
//

#define API_KEY                         @"f612a68e01194a17b1a4f3ed0e4dd923"//@"key_ios"
#define API_SECRET                      @"4198c6b75f36417cacdd5cd2b77cebec"//@"secret_ios"

#import <Foundation/Foundation.h>

@interface VSSystemConfig : NSObject
@property (nonatomic,copy)NSString *apiKey;
@property (nonatomic,copy)NSString *apiSecrect;
@property (nonatomic,copy)NSString *serverAppName;
@property (nonatomic,copy)NSString *appVersion;
@property (nonatomic,copy)NSString *appName;
@property (nonatomic,copy)NSString *UDID;
@property (nonatomic,copy)NSString *serverUrl;
+ (VSSystemConfig *)shareInstance;

@end
