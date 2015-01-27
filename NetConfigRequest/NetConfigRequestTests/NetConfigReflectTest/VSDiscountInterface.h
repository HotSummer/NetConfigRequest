//
//  VSDiscountInterface.h
//  NetConfigRequest
//
//  Created by zbq on 15-1-27.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property(nonatomic, strong) NSString *availabletype;
@property(nonatomic, strong) NSString *availablefid;

@end

@interface VSDiscountInterface : NSObject

@property(nonatomic, strong) Item *item;

@end
