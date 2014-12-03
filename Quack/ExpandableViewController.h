//
//  ViewController.h
//  CPExpandableTableView
//
//  Created by Chelsea Pugh on 11/16/14.
//  Copyright (c) 2014 chelsea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *questions;
@property (strong, nonatomic) NSMutableArray *titles;
- (UILabel *)getLabelWithText:(NSString *)text;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UILabel *refreshLabel;

@end

