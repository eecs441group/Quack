//
//  InboxViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "InboxViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Question.h"
#import "QuestionTableViewCell.h"
#import "QuackColors.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface InboxViewController ()

@end

@implementation InboxViewController {
    PFObject *_user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //style navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor quackSeaColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //set selected tab bar item image
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    UIImage* selectedImage = [UIImage imageNamed:@"inbox_active"];
    tabBarItem.selectedImage = selectedImage;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (FBSession.activeSession.isOpen) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 PFUser *user = [PFUser currentUser];
                 PFRelation *relation = [user relationForKey:@"inbox"];
                 
                 // Find user's inbox questions, add them to the _userInbox array and reload the tableView
                 PFQuery *questionQuery = [relation query];
                 [questionQuery orderByDescending:@"createdAt"];
                 questionQuery.limit = 100;
                 
                 [questionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (error) {
                         // There was an error
                     } else {
                         for (PFObject *question in objects) {
                             if(question && ![question isKindOfClass:[NSNull class]]) {
                                 [self.questions addObject:[[Question alloc] initWithDictionary:(NSDictionary *)question]];
                             }
                         }
                         [self.tableView reloadData];
                     }
                 }];
             }
             [hud hide:YES];
         }];
    } else {
        NSLog(@"fb session not active");
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    Question *q = [self.questions objectAtIndex:indexPath.row];
    QuestionTableViewCell *cell = (QuestionTableViewCell *)[super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    cell.askerLabel.text = [NSString stringWithFormat:@"%@ wants to know:", q.askerName];
    return cell;
}

- (void)addDataToCell:(UITableViewCell *)cell question:(Question *)question{
    int i = 0;
    for(; i < [question.answers count]; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 55 + i*55, 40, 40)];
        button.tag = i + 1;
        [button setBackgroundImage:[UIImage imageNamed:@"first.png"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(selectAnswer:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 55 + i*55, 200, 40)];
        answerLabel.text = question.answers[i];
        [cell addSubview:answerLabel];
        [cell addSubview:button];
    }
    
    // Add uitextfield to see if people want to comment
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 55 + i * 55, 306, 30)];
    tf.placeholder = @"Comment";
    tf.delegate = self;
    [cell addSubview:tf];
}

- (void)selectAnswer:(id)sender {
    UIButton *button = (UIButton *)sender;
    QuestionTableViewCell *cell = (QuestionTableViewCell *)button.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Question *q = (Question *)[self.questions objectAtIndex:indexPath.row];
    
    if(!q.answerSet) {
        [button setBackgroundImage:[UIImage imageNamed:@"sent_green.png"] forState:UIControlStateNormal];
        q.answerSet = true;
        q.curSelected = button.tag;
    } else if (q.curSelected == button.tag) {
        [self.questions removeObject:q];
        [self.expandedCells removeObject:indexPath];
        [self removeDataFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
        [self.tableView reloadData];
        
        // get question from Parse
        PFQuery *query = [PFQuery queryWithClassName:@"Question"];
        [query getObjectInBackgroundWithId:q.questionId block:^(PFObject *question, NSError *error) {
            if (!error) {
                // Remove question from user's inbox
                PFUser *user = [PFUser currentUser];
                PFRelation *relation = [user relationForKey:@"inbox"];
                [relation removeObject:question];
                [user saveInBackground];
                
                // Update question's counts
                NSMutableArray *counts = question[@"counts"];
                counts[button.tag - 1] = [NSNumber numberWithInt:[counts[button.tag - 1] intValue] + 1];
                [question saveInBackground];
            }
        }];
        
    } else if(q.answerSet) {
        // swap selected
        UIButton *oldSelection = (UIButton *)[cell viewWithTag:q.curSelected];
        [oldSelection setBackgroundImage:[UIImage imageNamed:@"first.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"sent_green.png"] forState:UIControlStateNormal];
        q.curSelected = button.tag;

    }
}

- (void)removeDataFromCell:(UITableViewCell *)cell {
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma text field

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    PFQuery *query = [PFQuery queryWithClassName:@"Data"];
    [query getObjectInBackgroundWithId:@"oIi5UPXKCc" block:^(PFObject *data, NSError *error) {
        if (!error) {
            data[@"clickedComment"] = [NSNumber numberWithInt:[data[@"clickedComment"] intValue] + 1];
            [data saveInBackground];
        }
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                    message:@"This feature has not been implemented yet"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
