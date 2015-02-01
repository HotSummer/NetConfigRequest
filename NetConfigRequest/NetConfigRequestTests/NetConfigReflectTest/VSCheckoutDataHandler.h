//
//  VSCheckoutDataHandler.h
//  NetConfigRequest
//
//  Created by summer.zhu on 30/1/15.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checkoutamount : NSObject

@property(nonatomic, strong) NSString *amount;

@end

@interface VSCheckoutDataHandler : NSObject

@property(nonatomic, strong) Checkoutamount *checkoutamount;

@end
