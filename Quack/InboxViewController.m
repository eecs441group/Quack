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
#import "Question.h"
#import "QuestionTableViewCell.h"

@interface InboxViewController ()

@end

@implementation InboxViewController {
    NSMutableArray *_userInbox;
    NSMutableArray *_expandedCells;
    PFObject *_user;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidLoad];
    _userInbox = [[NSMutableArray alloc] init];
    _expandedCells = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"QuestionTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"QuestionTableViewCell"];
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
                     _user = users[0];
                     for (PFObject *question in _user[@"userInbox"]) {
                         [_userInbox addObject:[[Question alloc] initWithDictionary:(NSDictionary *)question]];
                         // This does not require a network access.
                         NSLog(@"retrieved question: %@", question);
                     }
                     [self.tableView reloadData];
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

#pragma TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_userInbox count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"QuestionTableViewCell";
    
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = (QuestionTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Question *q = [_userInbox objectAtIndex:indexPath.row];
    
    cell.questionLabel.text = q.question;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //expandedCells is a mutable set declared in your interface section or private class extensiont
    if ([_expandedCells containsObject:indexPath]) {
        [_expandedCells removeObject:indexPath];
        [self removeAnswersFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
    else {
        // Expand the view and show answers
        [_expandedCells addObject:indexPath];
        [self addAnswersToCell:[self.tableView cellForRowAtIndexPath:indexPath] question:[_userInbox objectAtIndex:indexPath.row]];
        
    }
    [self.tableView reloadData];
}

- (void)addAnswersToCell:(UITableViewCell *)cell question:(Question *)question{
    for(int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 55 + i*55, 40, 40)];
        button.tag = i;
        [button setTitle:@"+" forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(selectAnswer:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 55 + i*55, 200, 40)];
        answerLabel.text = question.answers[i];
        [cell addSubview:answerLabel];
        [cell addSubview:button];
    }
}

- (void)selectAnswer:(id)sender {
    UIButton *button = (UIButton *)sender;
    QuestionTableViewCell *cell = (QuestionTableViewCell *)button.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Question *q = (Question *)[_userInbox objectAtIndex:indexPath.row];
    
    if(!q.answerSet && [button.titleLabel.text isEqual:@"+"]) {
        [button setTitle:@">" forState:UIControlStateNormal];
        q.answerSet = true;
        q.curSelected = button.tag;
    } else if ([button.titleLabel.text isEqualToString:@">"]) {
        // get question from Parse
        PFQuery *query = [PFQuery queryWithClassName:@"Question"];
        [query getObjectInBackgroundWithId:q.questionId block:^(PFObject *question, NSError *error) {
            // update count
            [_user[@"userInbox"] removeObject:question];
            for(PFObject *question in _user[@"userInbox"]) {
                NSLog(@"question: %@", question);
                if([[question objectId] isEqualToString:q.questionId]) {
                    [_user[@"userInbox"] removeObject:question];
                    [_user saveInBackground];
                    break;
                }
            }
            
            [_expandedCells removeObject:indexPath];
            [self removeAnswersFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
            
            NSMutableArray *counts = question[@"counts"];
            counts[button.tag] = [NSNumber numberWithInt:[counts[button.tag] intValue] + 1];
    
            // save changes
            [question saveInBackground];
            [_user saveInBackground];
            
            // remove cell & question
            [_userInbox removeObject:q];
            [self.tableView reloadData];
        }];
        
        
    } else if([button.titleLabel.text isEqualToString:@"+"] && q.answerSet) {
        // swap selected
        UIButton *oldSelection = (UIButton *)[cell viewWithTag:q.curSelected];
        [oldSelection setTitle:@"+" forState:UIControlStateNormal];
        [button setTitle:@">" forState:UIControlStateNormal];
        q.curSelected = button.tag;

    }
}

- (void)removeAnswersFromCell:(UITableViewCell *)cell {
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_expandedCells containsObject:indexPath])
    {
        return 300.0;
    }
    else
    {
        return 80.0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
