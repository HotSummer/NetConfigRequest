//
//  NetWorkConfig.m
//  BFM
//
//  Created by xiangying on 14-9-2.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import "NetWorkConfig.h"
#import <AFNetworking/AFNetworking.h>
@implementation BaseNetwork

@end


#pragma mark -

@interface NetWorkConfig()

@property(nonatomic,strong)NSMutableDictionary* allRes;

@end

@implementation NetWorkConfig

+(instancetype)shareInstance{
    static NetWorkConfig *netConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!netConfig) {
            netConfig = [[NetWorkConfig alloc] init];
            
    
        }
    });
    return netConfig;
}

- (id)init{
    self = [super init];
    if (self) {
        self.allRes = [NSMutableDictionary dictionary];
        [self loadFile];
    }
    return self;
}

- (void)loadFile
{
    NSString *homeDir = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error ;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:homeDir error:&error];
    
    [fileList enumerateObjectsUsingBlock:^(id obj,NSUInteger index,BOOL *stop){
        NSString *path = (NSString *)obj;
        NSRange rang = [path rangeOfString:@".bundle"];
        if (rang.location != NSNotFound ) {
            NSBundle *bundel = [NSBundle bundleWithPath:[homeDir stringByAppendingPathComponent:path]];
            NSArray *list = [NSBundle pathsForResourcesOfType:@"reqconfig" inDirectory:[bundel resourcePath]];
            if (list && [list count]>0) {
                [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [self setConfig:obj];
                }];
            }
        }
    }];
}


-(BaseNetwork*)getNetWorkByKey:(NSString*)key{
    return self.allRes[key];
}

-(void)setConfig:(NSString*)filePath{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"file not");
    }
    NSError *error;
    NSDictionary *configs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"%@",error.description);
    }else{
        if (configs) {
            [configs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                BaseNetwork *config = [[BaseNetwork alloc] init];
                config.configName = key;
                config.url = obj[@"url"];
                config.method = obj[@"method"];
                if ([obj objectForKey:@"serverName"]) {
                    config.serverName = obj[@"serverName"];
                }
                if ([obj objectForKey:@"ssl"]) {
                    config.ssl = obj[@"ssl"];
                }
                config.reqParam = obj[@"reqParam"];
                config.resParam = obj[@"resParam"];
                [self.allRes setObject:config forKey:config.configName];
            }];
        }
    }
}

@end
