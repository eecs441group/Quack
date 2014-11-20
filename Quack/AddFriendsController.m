//
//  AddFriendsController.m
//  Quack
//
//  Created by Feng on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "AddFriendsController.h"
#import "FacebookInfo.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHud.h"


@implementation AddFriendsController {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    PFUser *currentUser = [PFUser currentUser];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 FacebookInfo *fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 //gets all user's facebook friends and sorts them in alphabetical order
                 [fbInfo getFriends:^(NSArray *friends){
                     self.friends = [friends sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                         NSString *first = a[@"name"];
                         NSString *second = b[@"name"];
                         return [first compare:second];
                     }];
                     //gets users's current friend list
                     NSArray *friendArray = currentUser[@"friends"];
                     //show a green button for every user in friendArray
                     NSLog(@"%@",friendArray);
                     [self.tableView reloadData];
                 }];
             }
         }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell"];

    NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
    UILabel *friendName = (UILabel *)[cell viewWithTag:101];
    friendName.text = friend[@"name"];
    UIButton *button = (UIButton *)[cell viewWithTag:102];
    [button addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
//    button.frame = CGRectMake(cell.frame.origin.x + 300, cell.frame.origin.y + 10, 100, 30);
//    [button setTitle:@"+" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(customActionPressed:) forControlEvents:UIControlEventTouchUpInside];
//    button.backgroundColor= [UIColor clearColor];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}


- (void) saveFriends:(PFObject*) question {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     for (NSDictionary *friend in friends) {
                         
                         // Call Parse Cloud Code function to add question to friend's inbox relations
                         [PFCloud callFunctionInBackground:@"sendQuestionToUserInbox"
                                            withParameters:@{@"friend": friend, @"question": question.objectId}
                                                     block:^(id object, NSError *error) {
                                                         NSLog(@"success: %@", object);
                                                     }];
                     }
                 }];
             }
         }];
    }
}


@end
