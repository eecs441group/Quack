//
//  QuestionViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "QuestionViewController.h"
#import <Parse/Parse.h>

@interface QuestionViewController ()

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    [question saveInBackground];
    
    // Reload page
}
@end
