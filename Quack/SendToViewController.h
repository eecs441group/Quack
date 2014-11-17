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

@property (nonatomic, copy) PFObject * _question;
@property (strong, nonatomic) NSMutableArray *_friends;
- (IBAction)sendPressed;

@end
