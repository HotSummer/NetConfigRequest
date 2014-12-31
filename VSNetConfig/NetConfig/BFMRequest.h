//
//  BFM.h
//  BFM
//
//  Created by xiangying on 14-8-29.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "NetWorkConfig.h"

#define VSSERVERURL [NSString stringWithFormat:@"%@%@", @"http://kidapi.vipkid.com", @"/neptune"]

@interface BFMRequest : NSObject

#pragma mark - Service

//+(void)requsetConfig:(BaseNetwork*)config :(void (^)(NSInteger code)) callBack;

/**
 @brief 根据配置类进行映射，然后请求
 @param config        网络请求的配置类
 @param requestObject 请求参数所在的对象
 @param callBack      请求的回掉
 */
+(void)requsetConfig:(BaseNetwork*)config requestObj:(NSObject *)requestObject  :(void (^)(NSInteger code,NSString *msg)) callBack ;

/**
 @brief 根据配置类进行映射，然后请求
 @param config        网络请求的配置类
 @param requestObject 请求参数所在的对象
 @param responseObj   返回参数所在的对象
 @param callBack      请求的回掉
 */
+(void)requsetConfig:(BaseNetwork*)config requestObj:(NSObject *)requestObject responseObj:(NSObject *)responseObj :(void (^)(NSInteger code,NSString *msg)) callBack;


/**
 @brief 根据配置类进行映射，然后请求，基础请求，不增加全局请求参数，网络回调后不判断code数值。
 @param config        网络请求的配置类
 @param requestObject 请求参数所在的对象
 @param callBack      请求的回掉
 */
+(void)baserequsetConfig:(BaseNetwork*)config requestObj:(NSObject *)requestObject :(void (^)(NSInteger code,NSString *msg)) callBack;

/**
 *  拼接请求的基础数据,加签
 *
 *  @param parmers 用来存储基础数据的dictionary
 */
+ (void)assembleBaseRequest:(NSMutableDictionary *)parmers;


/**
 *  加签
 *
 *  @param dic         数据源
 *  @param userSecrect 用户私密
 *
 *  @return 加签后的字符串
 */
+ (NSString *)sha1SignString:(NSDictionary *)dic  withUserSecrect:(NSString *)userSecrect;
@end


@interface BFMRequestManager : NSObject
@property(nonatomic, strong) AFHTTPRequestOperation *currentRequest;

+ (BFMRequestManager *)shareInstance;

/**
 *  记录url和request
 *
 *  @param url     请求的url
 *  @param request 请求的request
 */
- (void)addUrlAndRequest:(NSString *)url request:(AFHTTPRequestOperation *)request;

/**
 *  当请求结束时候，删除url对应的请求
 *
 *  @param url 请求的url
 */
- (void)removeRequest:(NSString *)url;

/**
 *  取消类（UIViewController或者UIView）的请求
 *
 *  @param className 类名（UIViewController或者UIView）
 */
- (void)cancelClassRequest:(NSString *)className;

/**
 *  取消当前请求
 */
- (void)cancelCurrentRequest;




@end