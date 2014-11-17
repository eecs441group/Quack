//
//  SendToViewController.h
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SendToViewController : UIViewController

@property (strong, nonatomic) NSString * _question;
@property (strong, nonatomic) NSArray * _answers;
@property (strong, nonatomic) NSMutableArray *_friends;
- (void)setQuestion:(NSString *)question
            answers:(NSArray *)answers;
- (IBAction)sendPressed;
- (void)sendToUsers:(NSString *)questionId
              Users:(NSArray *)selectedUsers;

@end
