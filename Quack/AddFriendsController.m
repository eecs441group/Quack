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
    MBProgressHUD *hud;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    PFUser *currentUser = [PFUser currentUser];
    self.friendSet = [[NSMutableSet alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud hide:YES];
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
                     [self.friendSet addObjectsFromArray:friendArray];
                     NSLog(@"%@", self.friendSet);
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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(cell.frame.origin.x + 300, cell.frame.origin.y + 10, 100, 30);
    if ([self.friendSet containsObject:friend]) {
        NSLog(@"true");
        [button setTitle:@"-" forState:UIControlStateNormal];
    } else {
        NSLog(@"false");
        [button setTitle:@"+" forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor= [UIColor clearColor];
    button.tag = indexPath.row;
    
    [cell.contentView addSubview:button];

    return cell;
}

- (void)buttonClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSDictionary *friend = [self.friends objectAtIndex:btn.tag];

    if ([self.friendSet containsObject:friend]) {
        //friend set contains friend, so remove friend
        [self.friendSet removeObject:friend];
        [btn setTitle:@"+" forState:UIControlStateNormal];
    } else {
        //friend set does not contains friend, so add friend
        [self.friendSet addObject:friend];
        [btn setTitle:@"-" forState:UIControlStateNormal];
    }
    NSLog(@"%@", self.friendSet);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (IBAction)saveFriends:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    //sort array alphabetically.
    NSArray* friends = [[self.friendSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = a[@"name"];
        NSString *second = b[@"name"];
        return [first compare:second];
    }];
    currentUser[@"friends"] = friends;
    
    NSLog(@"saving friends: %@",friends);
    [hud hide:NO];
    [currentUser saveInBackground];
    //[hud hide:YES];
}




@end
