//
//  NetConfigModelDefaultManagerTest.m
//  NetConfigRequest
//
//  Created by summer.zhu on 22/1/15.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigModelDefaultManagerTest.h"
#import "NetConfigModelDefaultManager.h"
#import "NetConfigDefine.h"

@implementation NetConfigModelDefaultManagerTest

+ (void)test{
    NetConfigModelDefaultManager *modelManager = [[NetConfigModelDefaultManager alloc] init];
    NetConfigModel *model = [modelManager getModel:@"addAddress"];
    NCLog(@"%@", model.configkey);
}

@end
