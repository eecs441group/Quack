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
#import <MBProgressHUD/MBProgressHUD.h>
@interface QuestionViewController ()


@end

@implementation QuestionViewController {
    NSString *_emptyString;
    NSDictionary *arguments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    _emptyString = [NSString stringWithFormat:@""];
    // Do any additional setup after loading the view.
}

-(void)dismissKeyboard {
    [self.questionTextView resignFirstResponder];
    [self.answer1 resignFirstResponder];
    [self.answer2 resignFirstResponder];
    [self.answer3 resignFirstResponder];
    [self.answer4 resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quackPressed:(id)sender {
    // Create PFObject for Question
    PFObject *question = [PFObject objectWithClassName:@"Question"];
    question[@"question"] = self.questionTextView.text;
    question[@"answers"] = @[self.answer1.text, self.answer2.text, self.answer3.text, self.answer4.text];
    question[@"counts"] = @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];
    
    // Get fb id and save the question
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 question[@"authorId"] = userId;
                 question[@"askerName"] = [result objectForKey:@"name"];
                 
                 [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     [self sendToAllFriends:question];
                     //send push notifications to all friends
                     [hud hide:YES];
                     
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

- (void) sendToAllFriends:(PFObject*) question {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     for (NSDictionary *friend in friends) {
                         
                         // Call Parse Cloud Code function to add question to friend's inbox relations
                         [PFCloud callFunctionInBackground:@"sendQuestionToUserInbox"
                                withParameters:@{@"friend": friend, @"question": question.objectId}
                                    block:^(id object, NSError *error) {
                                        NSLog(@"success: %@", object);
                                    }];
                         
                         PFQuery *pushQuery = [PFInstallation query];
                         NSString* pushMessage = [result[@"first_name"] stringByAppendingString:@" quacked you a question!!"];
                         [pushQuery whereKey:@"FBUserID" equalTo: [friend objectForKey:@"id"]];
                         [PFPush sendPushMessageToQueryInBackground:pushQuery
                                                        withMessage:pushMessage];
                     }
                 }];
             }
         }];
    }
}

@end
