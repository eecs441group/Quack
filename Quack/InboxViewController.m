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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

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
                         if(![question isKindOfClass:[NSNull class]]) {
                             [_userInbox addObject:[[Question alloc] initWithDictionary:(NSDictionary *)question]];
                             // This does not require a network access.
                         }
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
        button.tag = i + 1;
        [button setBackgroundImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateNormal];
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
    
    if(!q.answerSet) {
        [button setBackgroundImage:[UIImage imageNamed:@"checkmark_green.png"] forState:UIControlStateNormal];
        q.answerSet = true;
        q.curSelected = button.tag;
    } else if (q.curSelected == button.tag) {
        for(PFObject *question in _user[@"userInbox"]) {
            if(![question isKindOfClass:[NSNull class]] && [[question objectId] isEqualToString:q.questionId]) {
                [_user[@"userInbox"] removeObject:question];
                [_user saveInBackground];
                break;
            }
        }
        
        // get question from Parse

        PFQuery *query = [PFQuery queryWithClassName:@"Question"];
        [query getObjectInBackgroundWithId:q.questionId block:^(PFObject *question, NSError *error) {
            // update count
            [_expandedCells removeObject:indexPath];
            [self removeAnswersFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
            
            NSMutableArray *counts = question[@"counts"];
            counts[button.tag - 1] = [NSNumber numberWithInt:[counts[button.tag - 1] intValue] + 1];
    
            // save changes
            [question saveInBackground];
            
            // remove cell & question
            for(int i = 0; i < [_userInbox count]; ++i) {
                Question *curQ = _userInbox[i];
                if([curQ.questionId isEqualToString:q.questionId]) {
                    NSLog(@"Removing obj with id: %@", curQ.questionId);
                    [_userInbox removeObjectAtIndex:i];
                }
            }
            [self.tableView reloadData];
        }];
        
        
    } else if(q.answerSet) {
        // swap selected
        UIButton *oldSelection = (UIButton *)[cell viewWithTag:q.curSelected];
        [oldSelection setBackgroundImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"checkmark_green.png"] forState:UIControlStateNormal];
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
