//
//  SendToViewController.m
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SendToViewController.h"
#import "FacebookInfo.h"
#import "Question.h"
#import "QuackColors.h"

@implementation SendToViewController

// Setter for QuestionViewController to pass in the question and answers
- (void)setQuestion:(NSString *)question
            answers:(NSArray *)answers {
    self._question = question;
    self._answers = answers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendPressed)];
    self.navigationItem.rightBarButtonItem = sendButton;
}

- (void) viewDidAppear:(BOOL)animated {
    self._friends = [[NSMutableArray alloc] init];
    
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     [self._friends addObjectsFromArray:friends];
                 }];
             }
         }];
    }
}

- (IBAction)sendPressed {
    [self saveQuestion];
    
    [self.navigationController popViewControllerAnimated:NO];
}

// Save question to parse
- (void)saveQuestion {
    PFObject *question = [PFObject objectWithClassName:@"Question"];
    question[@"question"] = self._question;
    question[@"answers"] = self._answers;
    
    question[@"counts"] = [[NSMutableArray alloc] init];
    for (NSString *answer in self._answers) {
        [question[@"counts"] addObject:[NSNumber numberWithInt:0]];
    }
    
    PFUser *user = [PFUser currentUser];
    question[@"authorId"] = user[@"FBUserID"];
    question[@"askerName"] = user[@"username"];
    
    // Get fb id and save the question
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      [self sendToUsers:question.objectId
                                  Users:self._friends];
                      [hud hide:YES];
                      
                  }];
             }
         }];
    }
}

- (void)sendToUsers:(NSString *)questionId
              Users:(NSArray *)selectedUsers {
    // Call Parse Cloud Code function to add question to selectedUsers' inbox relations
    [PFCloud callFunctionInBackground:@"sendQuestionToUsers"
                       withParameters:@{@"question": questionId, @"users": selectedUsers}
                                block:^(id object, NSError *error) {
                                    NSLog(@"success: %@", object);
                                }];
}

@end
