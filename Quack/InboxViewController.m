//
//  InboxViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "InboxViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface InboxViewController ()

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 PFQuery *query = [PFQuery queryWithClassName:@"User"];
                 [query whereKey:@"userId" equalTo:userId];
                 
                 // Get the Question objects that the Question pointers in userInbox point to
                 [query includeKey:@"userInbox"];
                 
                 // Retrieve the most recent ones
                 [query orderByDescending:@"createdAt"];
                 
                 // Only retrieve the 100 most recent questions
                 query.limit = 100;
                 
                 [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                     PFObject *user = users[0];
                     for (PFObject *question in user[@"userInbox"]) {
                         // This does not require a network access.
                         NSLog(@"retrieved question: %@", question);
                     }
                 }];
                 // The InBackground methods are asynchronous, so any code after this will run
                 // immediately.  Any code that depends on the query result should be moved
                 // inside the completion block above.
             }
         }];
    } else {
        NSLog(@"fb session not active");
    }
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

@end
