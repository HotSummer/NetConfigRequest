//
//  NetConfigSignProtocol.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-3.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetConfigSignProtocol <NSObject>

@required
//给body中的参数使用
- (NSString *)signString:(NSDictionary *)dic;
//给header中的参数使用
- (NSString *)headerSignString:(NSDictionary *)dic;

@end
