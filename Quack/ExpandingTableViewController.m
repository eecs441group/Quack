//
//  ExpandingTableViewController.m
//  Quack
//
//  Created by Chelsea Pugh on 10/29/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "ExpandingTableViewController.h"

#import "Question.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AnswerTableViewCell.h"
#import "MBProgressHud.h"

static NSString *kAnswerCellIdentifier = @"AnswerTableViewCell";

@implementation ExpandingTableViewController {
    
}

- (void)awakeFromNib {
    self.expandedCells = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:@"AnswerTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"AnswerTableViewCell"];
    
}

- (void) viewDidAppear:(BOOL)animated {
    self.questions = [[NSMutableArray alloc] init];
}

#pragma TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.questions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAnswerCellIdentifier];
    
    Question *q = [self.questions objectAtIndex:indexPath.row];
    
    cell.questionLabel.text = q.question;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //expandedCells is a mutable set declared in your interface section or private class extensiont
    if ([self.expandedCells containsObject:indexPath])
    {
        [self.expandedCells removeObject:indexPath];
        [self removeDataFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
    else
    {
        [self.expandedCells addObject:indexPath];
        [self addDataToCell:[self.tableView cellForRowAtIndexPath:indexPath] question:[self.questions objectAtIndex:indexPath.row]];
    }
    [self.tableView reloadData];
}

- (void)addDataToCell:(UITableViewCell *)cell question:(Question *)question{

}

- (void)removeDataFromCell:(UITableViewCell *)cell {

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.expandedCells containsObject:indexPath]) {
        return 340.0;
    } else {
        return 80.0;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
