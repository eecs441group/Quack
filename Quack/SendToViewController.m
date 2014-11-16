//
//  SendToViewController.m
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "SendToViewController.h"
#import "QuackColors.h"

@implementation SendToViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
    self.navigationItem.rightBarButtonItem = sendButton;
//    [sendButton release];
    
}

@end
