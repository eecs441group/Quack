//
//  InboxViewController.h
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandingTableViewController.h"
#import "ExpandableViewController.h"

@interface InboxViewController : ExpandableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
