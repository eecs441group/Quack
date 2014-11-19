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
    for(UITextField *tf in _textFields) {
        tf.delegate = self;
    }

    
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
    NSString *question = self.questionTextView.text;
    NSMutableArray *answers = [[NSMutableArray alloc] init];
    for (UITextField *tf in _textFields) {
        if(![tf.text isEqualToString:@""]) {
            [answers addObject:tf.text];
        }
    }
    
    if ([question isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No question!"
                                                        message:@"Please add text to your question"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![answers count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No answers!"
                                                        message:@"Please add answers to your question"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //show sendTo view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SendToViewController *viewController = (SendToViewController *)[storyboard instantiateViewControllerWithIdentifier:@"sendToView"];
    [viewController setQuestion:question
                        answers:answers];
    [self.navigationController pushViewController:viewController animated:YES];
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self quackPressed:self.sendButton];
    return YES;
}


@end
