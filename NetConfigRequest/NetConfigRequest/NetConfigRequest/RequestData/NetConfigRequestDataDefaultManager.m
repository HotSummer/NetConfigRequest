//
//  NetConfigRequestDataDefaultManager.m
//  NetConfigRequest
//
//  Created by zbq on 15-1-4.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigRequestDataDefaultManager.h"

@implementation NetConfigRequestDataDefaultManager

- (NSString *)url{
    return nil;
}

- (NSDictionary *)baseRequestData{
    return nil;
}

- (NSString *)urlByModel:(NetConfigModel *)model{
    return @"";
}

- (NSString *)sslByModel:(NetConfigModel *)model{
    return @"";
}

@end
