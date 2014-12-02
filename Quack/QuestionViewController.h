//
//  QuestionViewController.h
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *questionHeading;
@property (strong, nonatomic) IBOutlet UILabel *answerHeading;

@property (strong, nonatomic) IBOutlet UITextView *questionTextView;
@property (strong, nonatomic) IBOutlet UITextField *answer1;
@property (strong, nonatomic) IBOutlet UITextField *answer2;
@property (strong, nonatomic) IBOutlet UITextField *answer3;
@property (strong, nonatomic) IBOutlet UITextField *answer4;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) UIView *inputAccView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITextField *curActiveField;
- (IBAction)quackPressed:(id)sender;

- (void) clearFields;

@end
