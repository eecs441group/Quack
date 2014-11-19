//
//  ViewController.m
//  CPExpandableTableView
//
//  Created by Chelsea Pugh on 11/16/14.
//  Copyright (c) 2014 chelsea. All rights reserved.
//

#import "ExpandableViewController.h"
#import "ClickableHeader.h"
#import "Title.h"
#import "QuestionTableViewCell.h"
#import "Question.h"

@interface ExpandableViewController ()

@end

@implementation ExpandableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:@"ClickableHeader" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ClickableHeader"];
    
    UINib *nibQ = [UINib nibWithNibName:@"QuestionTableViewCell" bundle:nil];
    [self.tableView registerNib:nibQ forCellReuseIdentifier:@"QuestionTableViewCell"];
}

- (void) viewDidAppear:(BOOL)animated {
    self.questions = [[NSMutableArray alloc] init];
    self.titles = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.questions count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"QuestionTableViewCell";
    
    QuestionTableViewCell *cell = (QuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Question *q = [self.questions objectAtIndex:indexPath.section];
    cell.questionLabel.text = q.answers[indexPath.row];
    [cell setClipsToBounds:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![_titles[indexPath.section] isExpanded]) {
        return 0;
    } else {
        return 80.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *simpleTableIdentifier = @"ClickableHeader";
    ClickableHeader *header = (ClickableHeader *)[self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(header == nil) {
        header = [[ClickableHeader alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    Title *t = self.titles[section];
    
    if(t.isExpanded) {
        [header.arrowImageView setImage:[UIImage imageNamed:@"up4-50.png"]];
    } else {
        [header.arrowImageView setImage:[UIImage imageNamed:@"down4-50.png"]];
    }
    
    header.tag = section;
    header.sectionLabel.text = t.title;
    
    UITapGestureRecognizer *singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    [singleTapRecogniser setDelegate:self];
    singleTapRecogniser.numberOfTouchesRequired = 1;
    singleTapRecogniser.numberOfTapsRequired = 1;
    [header addGestureRecognizer:singleTapRecogniser];
    
    return header;
}

- (void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    NSInteger section = gestureRecognizer.view.tag;
    Title *t = [_titles objectAtIndex:gestureRecognizer.view.tag];
    [t toggleExpansion];
    ClickableHeader *header = (ClickableHeader *)gestureRecognizer.view;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    Question *cur = [_questions objectAtIndex:section];
    for(int i = 0; i < [cur.answers count]; i++) {
        NSIndexPath *curPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:curPath];
    }
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

}
                                                   
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.questions objectAtIndex:section] answers] count];
}

@end
