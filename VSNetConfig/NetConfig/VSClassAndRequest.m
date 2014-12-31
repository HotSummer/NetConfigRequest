//
//  VSClassAndRequest.m
//  VSBuyComponent
//
//  Created by summer.zhu on 18/11/14.
//  Copyright (c) 2014年 test. All rights reserved.
//

#import "VSClassAndRequest.h"
#import "VSStartManager.h"

@implementation VSClassAndRequest

+ (NSDictionary *)getClassAndRequests{
    /**
     *  NSString *configurl = [VSSystemConfig shareInstance].serverUrl;
     if (configurl && ![configurl isEqualToString:@""] ) {
     url = [NSString stringWithFormat:@"%@%@",configurl,config.url];
     }
     */
    return @{@"VSCartViewController": @[[NSString stringWithFormat:@"VSCartViewController:%@/cart/get/v1", [VSStartManager shareInstance].externParam.serverUrl],
                                        [NSString stringWithFormat:@"VSCartViewController:%@/cart/extend_time/v1", [VSStartManager shareInstance].externParam.serverUrl],
                                        [NSString stringWithFormat:@"VSCartViewController:%@/cart/delete/v1", [VSStartManager shareInstance].externParam.serverUrl],
                                        [NSString stringWithFormat:@"VSCartViewController:%@/cart/update/v1", [VSStartManager shareInstance].externParam.serverUrl],]};
}

@end
