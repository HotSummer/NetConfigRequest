//
//  NetConfigProtocol.h
//  NetConfigRequest
//
//  Created by summer.zhu on 31/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetConfigProtocol <NSObject>

/**
 *  NetConfig网络请求的协议
 *
 *  @param url     请求的url
 *  @param method  请求的方法
 *  @param request 请求的参数
 *  @param res     返回的数据
 *  @param error   请求的错误
 */
- (void)request:(NSString *)url method:(NSString *)method requestParmers:(NSDictionary *)request response:(id)res error:(NSError *)error;

@end
