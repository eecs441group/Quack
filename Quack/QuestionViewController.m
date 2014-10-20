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
    
    [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        NSLog(@"%@", question.objectId);
        [self saveAuthor:question.objectId];
    }];
    
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

- (void) saveAuthor:(NSString*) questionId {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 // Find the user's MyQuestions
                 PFQuery * query = [PFQuery queryWithClassName:@"MyQuestions"];
                 [query whereKey:@"userId" equalTo:userId];
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (!error) {
                         // The find succeeded.
                         
                         if (!objects.count){
                             // This is user's first question. Add object row to parse
                             PFObject *myQuestions = [PFObject objectWithClassName:@"MyQuestions"];
                             myQuestions[@"userId"] = userId;
                             myQuestions[@"questionIds"] = @[questionId];
                             
                             NSLog(@"saving user's first question");
                             [myQuestions saveInBackground];
                         } else {
                             // User has existing questions. Add newest one to questionIds
                             PFObject *myQuestions = objects[0];
                             NSMutableArray *questions = myQuestions[@"questionIds"];
                             [questions addObject: questionId];
                             myQuestions[@"questionIds"] = questions;
                             
                             NSLog(@"updating user's questions");
                             [myQuestions saveInBackground];
                         }
                     } else {
                         // Log details of the failure
                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                     }
                 }];
             }
         }];
    }
}

- (void) sendToAllFriends {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     NSLog(@"in question");
                     for (NSDictionary *friend in friends) {
                         for (id key in friend)
                             NSLog(@"key=%@ value=%@", key, [friend objectForKey:key]);
                     }
                 }];
             }
         }];
    }
}

@end
