//
//  SendToViewController.m
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SendToViewController.h"
#import "FacebookInfo.h"
#import "Question.h"
#import "QuackColors.h"

@implementation SendToViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendPressed)];
    self.navigationItem.rightBarButtonItem = sendButton;
//    [sendButton release];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    self._friends = [[NSMutableArray alloc] init];
    
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     [self._friends addObjectsFromArray:friends];
                 }];
             }
         }];
    }
}

- (IBAction)sendPressed {
    NSLog(@"send pressed");
}


- (void)send:(NSArray *)selectedUsers {
    // Call Parse Cloud Code function to add question to selected users' inbox relations
    [PFCloud callFunctionInBackground:@"sendQuestionToUsers"
                       withParameters:@{@"users": selectedUsers, @"question": self._question.objectId}
                                block:^(id object, NSError *error) {
                                    NSLog(@"success: %@", object);
                                }];
}

@end
