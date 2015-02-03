//
//  VSAddressDataHandler.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-27.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSAddressDataHandler : NSObject

@property(nonatomic, strong) NSString *selectedAreaId;

+ (VSAddressDataHandler *)shareInstance;

@end
