//
//  VSAddressDataHandler.m
//  NetConfigRequest
//
//  Created by zbq on 15-1-27.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "VSAddressDataHandler.h"

@implementation VSAddressDataHandler

+ (VSAddressDataHandler *)shareInstance{
    static VSAddressDataHandler *dataHandler = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        dataHandler = [[VSAddressDataHandler alloc] init];
    });
    return dataHandler;
}

@end
