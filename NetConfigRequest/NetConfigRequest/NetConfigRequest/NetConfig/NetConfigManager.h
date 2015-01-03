//
//  NetConfigManager.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-3.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetConfigModel.h"
#import "NetConfigSignProtocol.h"
#import "NetConfigModelProtocol.h"
#import "NetConfigRequestProtocol.h"
#import "NetConfigRequestDataProtocol.h"

@interface NetConfigManager : NSObject

@property(nonatomic, strong) id<NetConfigRequestProtocol> request;
@property(nonatomic, strong) id<NetConfigModelProtocol> netConfigModel;
@property(nonatomic, strong) id<NetConfigRequestDataProtocol> netConfigRequestData;
@property(nonatomic, strong) id<NetConfigSignProtocol> netConfigSign;

+ (instancetype)shareInstance;

- (void)request:(NSString *)modelKey requestObject:(NSObject *)req responseObject:(NSObject *)res
       response:(ResponseBlock)resblock;

@end
