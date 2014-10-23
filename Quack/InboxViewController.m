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
#import "InboxQuestionTableViewCell.h"

@interface InboxViewController ()

@end

@implementation InboxViewController {
    NSMutableArray *_userInbox;
    NSMutableArray *_expandedCells;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userInbox = [[NSMutableArray alloc] init];
    _expandedCells = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"InboxQuestionTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"InboxQuestionTableViewCell"];
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
    static NSString *simpleTableIdentifier = @"InboxQuestionTableViewCell";
    
    InboxQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = (InboxQuestionTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Question *q = [_userInbox objectAtIndex:indexPath.row];
    
    cell.questionLabel.text = q.question;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //expandedCells is a mutable set declared in your interface section or private class extensiont
    if ([_expandedCells containsObject:indexPath])
    {
        [_expandedCells removeObject:indexPath];
        [self removeAnswersFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
    else
    {
        // Expand the view and show answers
        [_expandedCells addObject:indexPath];
        [self addAnswersToCell:[self.tableView cellForRowAtIndexPath:indexPath] question:[_userInbox objectAtIndex:indexPath.row]];
        
    }
    [self.tableView reloadData];
}

- (void)addAnswersToCell:(UITableViewCell *)cell question:(Question *)question{
    for(int i = 0; i < 4; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 30 + i*55, 40, 40)];
        [button setTitle:@"+" forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(selectAnswer)
         forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30 + i*55, 200, 40)];
        answerLabel.text = question.answers[i];
        [cell addSubview:answerLabel];
        [cell addSubview:button];
    }
}

- (void)selectAnswer {
    NSLog(@"Pressed!");
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
        return 300.0; //It's not necessary a constant, though
    }
    else
    {
        return 180.0; //Again not necessary a constant
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
