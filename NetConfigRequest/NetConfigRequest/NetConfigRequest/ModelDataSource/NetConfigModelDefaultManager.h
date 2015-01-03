//
//  NetConfigModelDefaultManager.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-4.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetConfigModelProtocol.h"

@interface NetConfigModelDefaultManager : NSObject
<
NetConfigModelProtocol
>

- (NetConfigModel *)getModel:(NSString *)modelKey;

@end
