//
//  NetWorkConfig.h
//  BFM
//
//  Created by xiangying on 14-9-2.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - BaseNetwork
@interface BaseNetwork : NSObject

@property(nonatomic,strong)NSString *configName;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *ssl;
@property(nonatomic,strong)NSString *method;
@property(nonatomic,copy)NSString *serverName;
@property(nonatomic,strong)NSDictionary *reqParam;
@property(nonatomic,strong)NSDictionary *resParam;

@end


#pragma mark - NetWorkConfig
@interface NetWorkConfig : NSObject

+(instancetype)shareInstance;

-(void)setConfig:(NSString*)filePath;

-(BaseNetwork*)getNetWorkByKey:(NSString*)key;

@end
