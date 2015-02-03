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
    model1.resParam = @{@"data":@"VSCheckoutDataHandler.checkoutamount"};
    
    NSDictionary *dic = @{@"data":@{@"amounts":@"hehehehehhe"}};
    
    VSCheckoutDataHandler *checkoutDataHandler = [[VSCheckoutDataHandler alloc] init];
    
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    
    [netConfigReflect responseObjectFromConfig:model1 contentData:dic responseObject:checkoutDataHandler];
    NCLog(@"%@", checkoutDataHandler.checkoutamount.amount);
    
    NSArray *arr = @[@{@"amount":@"hehehehehhe"}, @{@"amount":@"xxxxxxx"}, @{@"amount":@"oooooooo"}];
    NSMutableArray *arrObjects = [NSMutableArray array];
    [netConfigReflect responseObjectFromConfig:nil contentData:arr responseObject:arrObjects classNameInArray:@"Checkoutamount"];
}

+ (void)test4{
    //responseObjectFromConfig:(NetConfigModel *)configModel contentData:(id)contentData responseObjects:(NSArray *)responseObjects
    NetConfigDefaultReflect *netConfigReflect = [[NetConfigDefaultReflect alloc] init];
    NetConfigModel *model1 = [[NetConfigModel alloc] init];
    model1.resParam = @{@"data.areaIds":@"VSAddressDataHandler.selectedAreaId", @"data.couponType":@"VSDiscountInterface.item.availabletypes", @"data.favourableId":@"VSDiscountInterface.item.availablefid"};
    NSDictionary *dic = @{@"data":@{@"areaIds":@"hehehehehhe", @"couponType":@"xxxxxxx", @"favourableId":@"oooooooo"}};
    
    VSDiscountInterface *discountInterface = [[VSDiscountInterface alloc] init];
    [netConfigReflect responseObjectFromConfig:model1 contentData:dic responseObjects:@[discountInterface]];
    
    VSAddressDataHandler *addressData = [VSAddressDataHandler shareInstance];
    NCLog(@"%@, %@, %@", addressData.selectedAreaId, discountInterface.item.availabletype, discountInterface.item.availablefid);
    
}

@end
