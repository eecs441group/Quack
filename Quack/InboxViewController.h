//
//  InboxViewController.h
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandableViewController.h"

@interface InboxViewController : ExpandableViewController <UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (void)getNewData;
- (void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer;
@end
