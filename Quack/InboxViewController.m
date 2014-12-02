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
#import "AnswerTableViewCell.h"
#import "QuackColors.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Title.h"

static NSString *kAnswerCellIdentifier = @"AnswerTableViewCell";

@interface InboxViewController ()

@end

@implementation InboxViewController {
    PFObject *_user;
    UILabel *_noQuestionssLabel;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self getNewData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:nil
                            action:@selector(getNewData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    _noQuestionssLabel = [self getLabelWithText:@"You have no questions in your feed :-("];
    [self.view addSubview:_noQuestionssLabel];
    
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
}

- (void)getNewData {
    self.questions = [NSMutableArray new];
    self.titles = [NSMutableArray new];
    if (FBSession.activeSession.isOpen) {
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
                         NSLog(@"error");
                     } else {
                         for (PFObject *question in objects) {
                             if(question && ![question isKindOfClass:[NSNull class]]) {
                                 Question *q = [[Question alloc] initWithDictionary:(NSDictionary *)question];
                                 [self.titles addObject:[[Title alloc] initWithTitle:q.question]];
                                 [self.questions addObject:q];
                             }
                         }
                         if([self.questions count]) {
                             _noQuestionssLabel.hidden = YES;
                         } else {
                             _noQuestionssLabel.hidden = NO;
                         }
                         
                         [self.tableView reloadData];
                         [self updateBadge];
                         
                         if (self.refreshControl) {
                             
                             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                             [formatter setDateFormat:@"MMM d, h:mm a"];
                             NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                             NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                                         forKey:NSForegroundColorAttributeName];
                             NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                             self.refreshControl.attributedTitle = attributedTitle;
                             [self.refreshControl endRefreshing];
                         }
                         
                     }
                 }];
             }
         }];
    } else {
        NSLog(@"fb session not active");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Question *q = (Question *)[self.questions objectAtIndex:indexPath.section];
    if(!q.answerSet) {
        // Select an answer
        q.answerSet = true;
        q.curSelected = indexPath.row + 1;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submit?"
                                                       message:@"Click yes to confirm your answer!"
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        alert.delegate = self;
        alert.tag = indexPath.section + 1;
        [alert show];
        
        // If they end up not submitting, need to re-alert them
        q.answerSet = false;
    } else if(q.answerSet) {
        // Different answer selected
        q.curSelected = indexPath.row + 1;

    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAnswerCellIdentifier];
    Question *q = [self.questions objectAtIndex:indexPath.section];
    cell.answerLabel.text = q.answers[indexPath.row];
    [cell setClipsToBounds:YES];
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor quackFoamColor];
    return cell;
}

- (void)submitAnswerForQuestionAtIndex:(NSInteger)index {
    Question *q = [self.questions objectAtIndex:index];
    Title *t = [self.titles objectAtIndex:index];
    [self.questions removeObject:q];
    [self.titles removeObject:t];
    [self.tableView reloadData];
    [self updateBadge];
    
    if([self.questions count]) {
        _noQuestionssLabel.hidden = YES;
    } else {
        _noQuestionssLabel.hidden = NO;
    }
    
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
            counts[q.curSelected - 1] = [NSNumber numberWithInt:[counts[q.curSelected - 1] intValue] + 1];
            [question saveInBackground];
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) {
        [self submitAnswerForQuestionAtIndex:alertView.tag - 1];
    } else {
        Question *q = [self.questions objectAtIndex:(alertView.tag - 1)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(q.curSelected - 1) inSection:(alertView.tag - 1)];
        AnswerTableViewCell *cell = (AnswerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// update tab bar item badge to be the number of questions a user has in their inbox
- (void)updateBadge {
    if ([self.questions count]) {
        NSString *questionCount = [@([self.questions count]) stringValue];
        [[[[[self tabBarController] tabBar] items]
          objectAtIndex:0] setBadgeValue:questionCount];
    } else {
        [[[[[self tabBarController] tabBar] items]
          objectAtIndex:0] setBadgeValue:nil];
    }
    
}


@end
