//
//  MyQuestionsViewController.m
//  
//
//  Created by Chelsea Pugh on 10/4/14.
//
//

#import "MyQuestionsViewController.h"
#import "Question.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MyQuestionsViewController ()

@end

@implementation MyQuestionsViewController {
    NSMutableArray *_myQuestions;
    NSMutableArray *_expandedCells;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"wtf");
    _myQuestions = [[NSMutableArray alloc] init];
    _expandedCells = [[NSMutableArray alloc] init];
}

- (void) viewDidAppear:(BOOL)animated {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 PFQuery *query = [PFQuery queryWithClassName:@"Question"];
                 [query whereKey:@"authorId" equalTo:userId];
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (!error) {
                         for (PFObject *object in objects) {
                             Question *q = [[Question alloc] initWithDictionary:(NSDictionary *)object];
                             [_myQuestions addObject:q];
                         }
                         [self.tableView reloadData];
                     } else {
                         // Log details of the failure
                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                     }
                 }];
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
    return [_myQuestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Question *q = [_myQuestions objectAtIndex:indexPath.row];
    
    cell.textLabel.text = q.question;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //expandedCells is a mutable set declared in your interface section or private class extensiont
    if ([_expandedCells containsObject:indexPath])
    {
        [_expandedCells removeObject:indexPath];
    }
    else
    {
        [_expandedCells addObject:indexPath];
    }
    [self.tableView reloadData];
//    [self.tableView beginEditing];
//    [self.tableView endEditing]; //Yeah, that old trick to animate cell expand/collapse
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
