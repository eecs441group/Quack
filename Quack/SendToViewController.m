//
//  SendToViewController.m
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SendToViewController.h"
#import "FacebookInfo.h"
#import "Question.h"
#import "QuackColors.h"

@implementation SendToViewController

// Setter for QuestionViewController to pass in the question and answers
- (void)setQuestion:(NSString *)question
            answers:(NSArray *)answers {
    self.question = question;
    self.answers = answers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendPressed)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    self.tableSectionTitles = [[NSMutableArray alloc] init];
    [self.tableSectionTitles addObject:@"Friends"];
    [self.tableSectionTitles addObject:@"Groups"];
    
    self.selectedIndices = [[NSMutableArray alloc] init];
}

- (void) viewDidAppear:(BOOL)animated {
    self.friends = [[NSMutableArray alloc] init];
    
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 FacebookInfo * fbInfo = [[FacebookInfo alloc] initWithAccountID:userId];
                 [fbInfo getFriends:^(NSArray *friends){
                     [self.friends addObjectsFromArray:friends];
                     [self.tableView reloadData];
                 }];
             }
         }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.tableSectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = friend[@"name"];
    
    if ([self.selectedUsers containsObject:friend]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        NSLog(@"with checkmark");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [self.selectedIndices addObject:indexPath];

    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [cell setAccessoryType:UITableViewCellAccessoryNone];
//    
//    NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
//    [self.selectedUsers removeObject:friend];
////    [tableView reloadData];
//}

- (IBAction)sendPressed {
    [self saveQuestion];
    
    [self.navigationController popViewControllerAnimated:NO];
}

// Save question to parse
- (void)saveQuestion {
    PFObject *question = [PFObject objectWithClassName:@"Question"];
    question[@"question"] = self.question;
    question[@"answers"] = self.answers;
    
    question[@"counts"] = [[NSMutableArray alloc] init];
    for (NSString *answer in self.answers) {
        [question[@"counts"] addObject:[NSNumber numberWithInt:0]];
    }
    
    PFUser *user = [PFUser currentUser];
    question[@"authorId"] = user[@"FBUserID"];
    question[@"askerName"] = user[@"username"];
    
    // Get fb id and save the question
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      [self sendToUsers:question.objectId
                                  Users:self.selectedIndices];
                      [hud hide:YES];
                      
                  }];
             }
         }];
    }
}

- (void)sendToUsers:(NSString *)questionId
              Users:(NSArray *)selectedIndices {
    NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in selectedIndices) {
        NSDictionary *friend = [self.friends objectAtIndex:indexPath.row];
        [selectedUsers addObject:[[NSDictionary alloc] initWithDictionary:friend]];
        NSLog(@"sending to %@", friend[@"name"]);
    }
    
    // Call Parse Cloud Code function to add question to selectedUsers' inbox relations
    [PFCloud callFunctionInBackground:@"sendQuestion"
                       withParameters:@{@"question": questionId, @"users": selectedUsers}
                                block:^(id object, NSError *error) {
                                    NSLog(@"success: %@", object);
                                }];
}

@end
