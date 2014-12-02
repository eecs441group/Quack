//
//  LoginViewController.m
//  Quack
//
//  Created by Connie Qi on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "LoginViewController.h"
#import "FacebookInfo.h"
#import "QuackColors.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicView;
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
- (IBAction)inviteFriends:(id)sender;
- (IBAction)twitterSignIn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *inviteFriendsButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.loginView =
        [[FBLoginView alloc] initWithReadPermissions:
         @[@"public_profile", @"email", @"user_friends"]];
    self.loginView.delegate = self;
    self.loginView.center = self.view.center;
    
    //style navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor quackSeaColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //set selected tab bar item image
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:3];
    UIImage* selectedImage = [UIImage imageNamed:@"user_male_active"];
    tabBarItem.selectedImage = selectedImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.nameLabel.text = user.name;
    
    //set profile picture
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=400&height=400", user.objectID];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]];
    UIImage *image = [UIImage imageWithData:imageData];
    
    //Resize the image to be for retina
    image = [UIImage imageWithCGImage:[image CGImage]
                                scale:image.size.height/200
                          orientation:UIImageOrientationUp];
    
    self.profilePicView.image = image;
    
    //Check if logged in user exists in PFUser
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FBUserID" equalTo:user.objectID];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (!objects.count) {
                // User not found, sign them up
                PFUser *newUser = [PFUser user];
                newUser.username = user.name;
                newUser.password = @"password";
                newUser[@"FBUserID"] = user.objectID;
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"signup successful!");
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        installation[@"user"] = [PFUser currentUser];
                        installation[@"FBUserID"] = user.objectID;
                        [installation saveInBackground];
                        NSLog(@"pfinstallation initialized");
                        
                    } else {
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@" %@", errorString);
                    }
                }];
            } else {
                [PFUser logInWithUsernameInBackground:user.name password:@"password"
                        block:^(PFUser *user, NSError *error) {
                            if (user) {
                                NSLog(@"login successful!");
                                PFInstallation *installation = [PFInstallation currentInstallation];
                                installation[@"user"] = [PFUser currentUser];
                                installation[@"FBUserID"] = user[@"FBUserID"];
                                [installation saveInBackground];
                                NSLog(@"pfinstallation initialized");
                            } else {
                                // The login failed. Check error to see why.
                            }
                            }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // Dismiss this view if login was successful. On app launch,
    // this redirects to the first tab in the root tab bar controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    [self.twitterButton setHidden:YES];
    [self.inviteFriendsButton setHidden:YES];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [self.inviteFriendsButton setHidden:YES];
    [self.twitterButton setHidden:YES];
    self.nameLabel.text = @"";
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)inviteFriends:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Data"];
    [query getObjectInBackgroundWithId:@"oIi5UPXKCc" block:^(PFObject *data, NSError *error) {
        if (!error) {
            data[@"clickedInvite"] = [NSNumber numberWithInt:[data[@"clickedInvite"] intValue] + 1];
            [data saveInBackground];
        }
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                    message:@"This feature has not been implemented yet"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)twitterSignIn:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Data"];
    [query getObjectInBackgroundWithId:@"oIi5UPXKCc" block:^(PFObject *data, NSError *error) {
        if (!error) {
            data[@"clickedTwitter"] = [NSNumber numberWithInt:[data[@"clickedTwitter"] intValue] + 1];
            [data saveInBackground];
        }
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                    message:@"This feature has not been implemented yet"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
