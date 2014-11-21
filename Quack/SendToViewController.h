//
//  SendToViewController.h
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SendToViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString * question;
@property (strong, nonatomic) NSArray * answers;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *selectedIndices;
@property (strong, nonatomic) NSMutableArray *selectedUsers;
@property (strong, nonatomic) NSMutableArray * tableSectionTitles;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)setQuestion:(NSString *)question
            answers:(NSArray *)answers;
- (IBAction)sendPressed;
- (void)sendToUsers:(NSString *)questionId
              Users:(NSArray *)selectedUsers;

@end
