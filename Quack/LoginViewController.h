//
//  LoginViewController.h
//  Quack
//
//  Created by Connie Qi on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface LoginViewController : UIViewController <FBLoginViewDelegate>

- (void)setWelcome:(BOOL)is_welcome;

@end
