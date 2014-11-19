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
#import "Title.h"

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
                                 [self.titles addObject:[[Title alloc] initWithTitle:question[@"question"]]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Question *q = (Question *)[self.questions objectAtIndex:indexPath.section];
    Title *t = (Title *)[self.titles objectAtIndex:indexPath.section];
    if(!q.answerSet) {
        // Select an answer
        q.answerSet = true;
        NSLog(@"index path row: %ld", indexPath.row);
        q.curSelected = indexPath.row + 1;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submit?"
                                                       message:@"Click yes to confirm your answer!"
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        alert.delegate = self;
        [alert show];
        
    } else if (q.curSelected == indexPath.row + 1) {
        // Confirm an answer
        [self.questions removeObject:q];
        [self.titles removeObject:t];
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
                counts[indexPath.row] = [NSNumber numberWithInt:[counts[indexPath.row] intValue] + 1];
                [question saveInBackground];
            }
        }];
        
    } else if(q.answerSet) {
        // Different answer selected
        q.curSelected = indexPath.row + 1;

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        NSLog(@"Cancelled!");
    } else {
        NSLog(@"Submitted!");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
