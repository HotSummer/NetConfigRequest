//
//  NetConfigDefaultReflectTest.m
//  NetConfigRequest
//
//  Created by zbq on 15-1-27.
//  Copyright (c) 2015年 summer.zhu. All rights reserved.
//

#import "NetConfigDefaultReflectTest.h"
#import "NetConfigModelDefaultManager.h"
#import "NetConfigDefaultReflect.h"
#import "VSAddressDataHandler.h"
#import "VSDiscountInterface.h"

@implementation NetConfigDefaultReflectTest

+ (void)test{
    NetConfigModelDefaultManager *modelManager = [[NetConfigModelDefaultManager alloc] init];
    NetConfigModel *model = [modelManager getModel:@"checkoutamount"];
    
    VSAddressDataHandler *handler = [[VSAddressDataHandler alloc] init];
    handler.selectedAreaId = @"ssssss";
    
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    NSDictionary *dic = [netConfigReflect requestDataFromConfig:model requestObject:handler];
    NSLog(@"%@", dic);
}

+ (void)test2{
    NetConfigModelDefaultManager *modelManager = [[NetConfigModelDefaultManager alloc] init];
    NetConfigModel *model = [modelManager getModel:@"checkoutamount"];
    
    VSAddressDataHandler *handler = [[VSAddressDataHandler alloc] init];
    handler.selectedAreaId = @"ssssss";
    
    VSDiscountInterface *discountInterface = [[VSDiscountInterface alloc] init];
    Item *item = [[Item alloc] init];
    item.availabletype = @"test123";
    item.availablefid = @"q232321";
    discountInterface.item = item;
    
    NSArray *arrObjects = @[handler, discountInterface];
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    NSDictionary *dic = [netConfigReflect requestDataFromConfig:model requestObjects:arrObjects];
    NSLog(@"%@", dic);
}

@end
