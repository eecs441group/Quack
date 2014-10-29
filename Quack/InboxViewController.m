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
#import <MBProgressHUD/MBProgressHUD.h>

@interface InboxViewController ()

@end

@implementation InboxViewController {
    UILabel *_noQuestions;
    NSMutableArray *_userInbox;
    NSMutableArray *_expandedCells;
    PFObject *_user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _noQuestions = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 30)];
    
    _userInbox = [[NSMutableArray alloc] init];
    _expandedCells = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"QuestionTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"QuestionTableViewCell"];
    // Do any additional setup after loading the view.
    
    //TODO: now that we're using pfuser and don't need to grab the fbUserId from facebook,
    //can we unwrap this code from the facebook session checking?
    if (FBSession.activeSession.isOpen) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 PFUser *user = [PFUser currentUser];
                 PFRelation *relation = [user relationForKey:@"inbox"];
                 
                 // Find user's inbox questions, add them to the _userInbox array and reload the tableView
                 PFQuery *questionQuery = [relation query];
                 [questionQuery orderByDescending:@"createdAt"];
                 questionQuery.limit = 100;
                 
                 [questionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (error) {
                         // There was an error
                     } else {
                         for (PFObject *question in objects) {
                             if(question && ![question isKindOfClass:[NSNull class]]) {
                                 [_userInbox addObject:[[Question alloc] initWithDictionary:(NSDictionary *)question]];
                             }
                         }
                         [self.tableView reloadData];
                     }
                 }];
             }
             [hud hide:YES];
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
        [button setBackgroundImage:[UIImage imageNamed:@"sent_green.png"] forState:UIControlStateNormal];
        q.answerSet = true;
        q.curSelected = button.tag;
    } else if (q.curSelected == button.tag) {
        [_userInbox removeObject:q];
        [_expandedCells removeObject:indexPath];
        [self removeAnswersFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
        [self.tableView reloadData];
        
        NSUInteger idx = [_user[@"userInbox"] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return obj != [NSNull null] && [[obj objectId] isEqualToString:q.questionId];
        }];
        [_user[@"userInbox"] removeObjectAtIndex:idx];
        [_user saveInBackground];
        
        // get question from Parse

        PFQuery *query = [PFQuery queryWithClassName:@"Question"];
        [query getObjectInBackgroundWithId:q.questionId block:^(PFObject *question, NSError *error) {
            NSMutableArray *counts = question[@"counts"];
            counts[button.tag - 1] = [NSNumber numberWithInt:[counts[button.tag - 1] intValue] + 1];
            [question saveInBackground];
            
        }];
        
    } else if(q.answerSet) {
        // swap selected
        UIButton *oldSelection = (UIButton *)[cell viewWithTag:q.curSelected];
        [oldSelection setBackgroundImage:[UIImage imageNamed:@"checkmark.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"sent_green.png"] forState:UIControlStateNormal];
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
