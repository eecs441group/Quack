//
//  AddFriendsController.m
//  Quack
//
//  Created by Feng on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "AddFriendsController.h"
#import "Question.h"
#import "FacebookInfo.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHud.h"


@interface AddFriendsController ()

@end

@implementation AddFriendsController {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo *fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     
                     NSLog(@"%@", friends);
                 }];
             }
         }];
    }
}


@end
