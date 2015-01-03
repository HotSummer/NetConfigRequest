//
//  NetConfigRequestDataDefaultManager.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-4.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetConfigRequestDataProtocol.h"

@interface NetConfigRequestDataDefaultManager : NSObject
<
NetConfigRequestDataProtocol
>

- (NSString *)url;
- (NSDictionary *)baseRequestData;


@end
