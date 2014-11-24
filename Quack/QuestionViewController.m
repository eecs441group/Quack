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
        tf.textColor = [UIColor quackCharcoalColor];
    }
    self.questionTextView.delegate = self;
    self.questionTextView.returnKeyType = UIReturnKeyNext;
    
    self.questionTextView.textColor = [UIColor quackCharcoalColor];
    self.questionHeading.textColor = [UIColor quackCharcoalColor];
    self.answerHeading.textColor = [UIColor quackCharcoalColor];
    
    _questionTextView.layer.cornerRadius = 5;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    _emptyString = [NSString stringWithFormat:@""];
    
    //style navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor quackSeaColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    

    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSLog(@"%f", self.view.frame.size.width);
    
    [_sendButton setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(quackPressed:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.backgroundColor = [UIColor quackSeaColor];

    
    self.inputAccView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];
    [self.inputAccView setBackgroundColor:[UIColor clearColor]];
    [self.inputAccView setAlpha: 0.8];
    [self.inputAccView addSubview:_sendButton];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(![self.questionTextView.text isEqualToString:@""] && ![self.answer1.text isEqualToString:@""]) {
        [textField setInputAccessoryView:self.inputAccView];
    } else {
        [textField setInputAccessoryView:nil];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChangeText = YES;
    
    if ([text isEqualToString:@"\n"]) {
        [[_textFields objectAtIndex:0] becomeFirstResponder];
        shouldChangeText = NO;  
    }  
    
    return shouldChangeText;
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
            [textField resignFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[self quackPressed:self.sendButton];
    NSInteger index = [_textFields indexOfObject:textField];
    if(index < _textFields.count - 1) {
        UITextField *next = [_textFields objectAtIndex:index + 1];
        [next becomeFirstResponder];
    }
    return YES;
}


@end
