//
//  NetConfigRequestDataProtocol.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-3.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetConfigRequestDataProtocol <NSObject>

- (NSString *)url;
- (NSDictionary *)baseRequestData;

@end
