//
//  NetConfigDefaultReflect.h
//  NetConfigRequest
//
//  Created by summer.zhu on 22/1/15.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetConfigReflectProtocol.h"

@interface NetConfigDefaultReflect : NSObject
<
NetConfigReflectProtocol
>

/**
 *  根据配制数据（configModel）和对象（requestObj， 请求数据的来源）生成请求数据（NSDictionary）
 *
 *  @param configModel 配制数据
 *  @param requestObj  对象
 *
 *  @return 请求数据
 */
- (NSDictionary *)requestDataFromConfig:(NetConfigModel *)configModel requestObject:(NSObject *)requestObj;

/**
 *  根据配制数据（configModel）,数据（contentData） 和对象（responseObject， 返回数据的对象）填充返回对象
 *
 *  @param configModel    配制数据
 *  @param contentData    数据
 *  @param responseObject 对象
 *
 */
- (void)responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObject:(NSObject *)responseObject;

@end
