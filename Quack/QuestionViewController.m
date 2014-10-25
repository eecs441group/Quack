//
//  QuestionViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "QuestionViewController.h"
#import "FacebookInfo.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface QuestionViewController ()


@end

@implementation QuestionViewController {
    NSString *_emptyString;
    NSDictionary *arguments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _emptyString = [NSString stringWithFormat:@""];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quackPressed:(id)sender {
    // Push to parse
    PFObject *question = [PFObject objectWithClassName:@"Question"];
    question[@"question"] = self.questionTextView.text;
    
    question[@"answers"] = @[self.answer1.text, self.answer2.text, self.answer3.text, self.answer4.text];
    question[@"counts"] = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];
    
    // Get fb id and save the question
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 question[@"authorId"] = userId;
                 
                 [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                      [self sendToAllFriends:question];
                     //send push notifications to all friends
                     
                 }];
             }
         }];
    }
    
    // Reload fields
    [self clearFields];
}

- (void) clearFields {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) {
            UITextField *textField = (UITextField *)view;
            textField.text = _emptyString;
        }
    }
}

//- (void) saveAuthor:(NSString*) questionId {
//    if (FBSession.activeSession.isOpen) {
//        [FBRequestConnection
//         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//             if (!error) {
//                 NSString *userId = [result objectForKey:@"id"];
//                 
//                 PFQuery * query = [PFQuery queryWithClassName:@"User"];
//                 [query whereKey:@"userId" equalTo:userId];
//                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                     if (!error) {
//                         if (objects.count) {
//                             PFObject *user = objects[0];
//                             NSMutableArray *questions = user[@"userQuestions"];
//                             [questions addObject: questionId];
//                             user[@"userQuestions"] = questions;
//                             
//                             NSLog(@"updating user's questions");
//                             [user saveInBackground];
//                         } else {
//                             NSLog(@"userId not found when adding to UserQuestions");
//                         }
//                     } else {
//                         // Log details of the failure
//                         NSLog(@"Error: %@ %@", error, [error userInfo]);
//                     }
//                 }];
//             }
//         }];
//    }
//}

- (void) sendToAllFriends:(PFObject*) question {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 // Get fb friends who use Quack
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     for (NSDictionary *friend in friends) {
                         
                         [PFCloud callFunctionInBackground:@"sendQuestionToUser"
                                withParameters:@{@"friend": friend, @"question": question.objectId}
                                    block:^(id object, NSError *error) {
                                        NSLog(@"success!! %@", object);
                                    }];
                         
                         PFQuery * query = [PFQuery queryWithClassName:@"User"];
                         // Get the User object for this friend based on fb userId
                         [query whereKey:@"userId" equalTo:[friend objectForKey:@"id"]];
                         
                         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                             if (!error) {
                                 if (objects.count) {
                                     PFObject *user = objects[0];
                                     NSMutableArray *questions = user[@"userInbox"];
                                     // Add the new question to friend's inbox
                                     [questions addObject: question];
                                     
                                     user[@"userInbox"] = questions;
                                     [user saveInBackground];
                                     
                                 } else {
                                     NSLog(@"userId not found when adding to userInbox");
                                 }
                             } else {
                                 // Log details of the failure
                                 NSLog(@"Error: %@ %@", error, [error userInfo]);
                             }
                         }];
                     }
                 }];
             }
         }];
    }
}

@end
