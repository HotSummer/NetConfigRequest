//
//  ViewController.m
//  NetConfigRequest
//
//  Created by summer.zhu on 31/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    IBOutlet UIView *viewTest1;
    UIView *viewTest;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    viewTest.frame = CGRectMake(100, 200, 300, 400);
    //左侧为0
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:0 constant:0]];
    //宽度为200
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0 constant:200]];
    //上侧为0
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:0 constant:0]];
    //高度为200
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:200]];
    
    //以下是手动创建的
    viewTest = [[UIView alloc] initWithFrame:CGRectZero];
    viewTest.backgroundColor = [UIColor greenColor];
    [self.view addSubview:viewTest];
    viewTest.translatesAutoresizingMaskIntoConstraints = NO;
    
    //居中约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //距离底部20
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20]];
    //高度0.3
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.3 constant:0]];
    //宽度0.3
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0]];
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewTest attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0]];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
//    viewTest.frame = CGRectMake(100, 200, 150, 200);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
