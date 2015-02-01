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
#import "VSCheckoutDataHandler.h"
#import "VSAddressDataHandler.h"
#import "VSDiscountInterface.h"
#import "NetConfigDefine.h"
#import "VSTestObject.h"

@implementation NetConfigDefaultReflectTest

+ (void)test{
    NetConfigModelDefaultManager *modelManager = [[NetConfigModelDefaultManager alloc] init];
    NetConfigModel *model = [modelManager getModel:@"checkoutamount"];
    
    VSAddressDataHandler *handler = [[VSAddressDataHandler alloc] init];
    handler.selectedAreaId = @"ssssss";
    
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    NSDictionary *dic = [netConfigReflect requestDataFromConfig:model requestObject:handler];
    NCLog(@"%@", dic);
}

+ (void)test2{
    NetConfigModel *model1 = [[NetConfigModel alloc] init];
    model1.reqParam = @{@"areaIds":@"VSAddressDataHandler.selectedAreaId", @"couponType":@"VSDiscountInterface.item.availabletypes", @"favourableId":@"VSDiscountInterface.item.availablefid"};
    
    VSAddressDataHandler *handler = [[VSAddressDataHandler alloc] init];
    handler.selectedAreaId = @"ssssss";
    
    VSDiscountInterface *discountInterface = [[VSDiscountInterface alloc] init];
    Item *item = [[Item alloc] init];
    item.availabletype = @"test123";
    item.availablefid = @"q232321";
    discountInterface.item = item;
    
    VSTestObject *testOject = [[VSTestObject alloc] init];
    testOject.test = @"hahahahah";
    
    NSArray *arrObjects = @[handler, discountInterface, testOject];
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    NSDictionary *dic = [netConfigReflect requestDataFromConfig:model1 requestObjects:arrObjects];
    NCLog(@"%@", dic);
}

+ (void)test3{
    NetConfigModel *model1 = [[NetConfigModel alloc] init];
    // "data.amount":"VSCheckoutDataHandler.checkoutamount"
    model1.resParam = @{@"data":@"VSCheckoutDataHandler.checkoutamount"};
    
    NSDictionary *dic = @{@"data":@{@"amount":@"hehehehehhe"}};
    
    VSCheckoutDataHandler *checkoutDataHandler = [[VSCheckoutDataHandler alloc] init];
    
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    
    [netConfigReflect responseObjectFromConfig:model1 contentData:dic responseObject:checkoutDataHandler];
    NCLog(@"%@", checkoutDataHandler.checkoutamount.amount);
    
}

@end
