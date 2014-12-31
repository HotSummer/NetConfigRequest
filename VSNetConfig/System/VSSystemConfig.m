//
//  VSSystemConfig.m
//  testFrameWork
//
//  Created by YaoMing on 14-9-11.
//  Copyright (c) 2014年 vipshop. All rights reserved.
//

#import "VSSystemConfig.h"
#import "OpenUDID.h"
static VSSystemConfig *_systemConfig;
@implementation VSSystemConfig

- (id)init
{
    self = [super init];
    if (self) {
        self.apiKey = API_KEY;
        self.apiSecrect = API_SECRET;
    }
    return self;
}

- (NSString *)UDID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *udid = [defaults stringForKey:@"ConfigOpenUDID"];
    if (!udid || [udid length] <= 0) {
        udid = [OpenUDID value];
        [defaults setObject:udid forKey:@"ConfigOpenUDID"];
        [defaults synchronize];
    }
    return udid;
}

+ (VSSystemConfig *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == _systemConfig) {
            _systemConfig = [[VSSystemConfig alloc] init];
        }
    });
    return _systemConfig;
}

- (NSString *)appVersion
{
    NSBundle *bundle = [NSBundle mainBundle];

    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    return appVersion;
}

- (NSString *)appName
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    // Attempt to find a name for this application
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding] ;
    
    return appName;
}
@end
