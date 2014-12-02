//
//  AddFriendsController.h
//  Quack
//
//  Created by Feng on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendsController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSMutableSet *friendSet;
- (IBAction)saveFriends:(id)sender;

@end