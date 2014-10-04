//
//  FirstViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"hello log");
    FBLoginView *loginView = [[FBLoginView alloc] init];
    NSLog(@"after loginview init");
    loginView.center = self.view.center;
    NSLog(@"After center");
    [self.view addSubview:loginView];
    NSLog(@"after add subview");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
