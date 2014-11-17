//
//  QuestionViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "QuestionViewController.h"
#import "SendToViewController.h"
#import "FacebookInfo.h"
#import "QuackColors.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface QuestionViewController ()


@end

@implementation QuestionViewController {
    NSString *_emptyString;
    NSDictionary *arguments;
    NSArray *_textFields;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _textFields = @[self.answer1, self.answer2, self.answer3, self.answer4];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    _emptyString = [NSString stringWithFormat:@""];
    // Do any additional setup after loading the view.
    
    //style navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor quackSeaColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //style send button
    _sendButton.layer.cornerRadius = 5;
    _sendButton.layer.borderWidth = 1;
    _sendButton.layer.borderColor = [UIColor quackSeaColor].CGColor;
    
}

-(void)dismissKeyboard {
    [self.questionTextView resignFirstResponder];
    for (UITextField *tf in _textFields) {
        [tf resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quackPressed:(id)sender {
    // Create PFObject for Question
    PFObject *question = [PFObject objectWithClassName:@"Question"];
    if ([self.questionTextView.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No question!"
                                                        message:@"Please add text to your question"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    question[@"question"] = self.questionTextView.text;
    question[@"answers"] = [[NSMutableArray alloc] init];// @[self.answer1.text, self.answer2.text, self.answer3.text, self.answer4.text];
    question[@"counts"] = [[NSMutableArray alloc] init];// @[[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];

    for (UITextField *tf in _textFields) {
        if(![tf.text isEqualToString:@""]) {
            [question[@"answers"] addObject:tf.text];
            [question[@"counts"] addObject:[NSNumber numberWithInt:0]];
        }
    }
    
    if (![question[@"answers"] count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No answers!"
                                                        message:@"Please add answers to your question"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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
    
    //show sendTo view
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SendToViewController *viewController = (SendToViewController *)[storyboard instantiateViewControllerWithIdentifier:@"sendToView"];
//    viewController._question = question;
//    [self.navigationController pushViewController:viewController animated:YES];
    
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
                     }
                 }];
             }
         }];
    }
}

@end
