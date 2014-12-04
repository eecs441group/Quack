//
//  AddFriendsController.m
//  Quack
//
//  Created by Feng on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AddFriendsController.h"
#import "FacebookInfo.h"
#import "ClickableHeader.h"
#import "MBProgressHud.h"
#import "QuackColors.h"


static NSString *kClickableHeaderIdentifier = @"ClickableHeader";

@implementation AddFriendsController {
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ClickableHeader" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ClickableHeader"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    PFUser *currentUser = [PFUser currentUser];
    self.friendSet = [[NSMutableSet alloc] init];
    [self.friendSet addObjectsFromArray:currentUser[@"friends"]];
    NSLog(@"%@", self.friendSet);
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
                     [self.tableView reloadData];
                 }];
             }
         }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClickableHeader *cell = [tableView dequeueReusableCellWithIdentifier:kClickableHeaderIdentifier];
    cell.selectedBackgroundView.backgroundColor = [UIColor quackFoamColor];
    cell.arrowImageView.image = nil;
    NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
    cell.sectionLabel.text = friend[@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.friendSet containsObject:friend[@"id"]]) {
        cell.arrowImageView.image = [UIImage imageNamed:@"friend_icon.png"];
    } else {
        cell.arrowImageView.image = [UIImage imageNamed:@"add_icon.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClickableHeader *cell = (ClickableHeader *)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
    if ([self.friendSet containsObject:friend[@"id"]]) {
        //friend set contains friend, so remove friend
        [self.friendSet removeObject:friend[@"id"]];
        cell.arrowImageView.image = [UIImage imageNamed:@"add_icon.png"];
    } else {
        //friend set does not contains friend, so add friend
        [self.friendSet addObject:friend[@"id"]];
        cell.arrowImageView.image = [UIImage imageNamed:@"friend_icon.png"];
    }
}

- (IBAction)saveFriends:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"friends"] = [self.friendSet allObjects];
    NSLog(@"saving friends: %@",currentUser[@"friends"]);
    [currentUser saveInBackground];
    //[hud hide:YES];
}




@end
