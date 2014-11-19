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
#import "AnswerTableViewCell.h"
#import "Question.h"
#import "QuackColors.h"

static NSString *kUpArrowImage = @"up4-50.png";
static NSString *kDownArrowImage = @"down4-50.png";
static NSString *kClickableHeaderIdentifier = @"ClickableHeader";
static NSString *kCellIdentifier = @"Cell";

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
    
    UINib *nibQ = [UINib nibWithNibName:@"AnswerTableViewCell" bundle:nil];
    [self.tableView registerNib:nibQ forCellReuseIdentifier:@"AnswerTableViewCell"];
}

- (void) viewDidAppear:(BOOL)animated {
    self.questions = [[NSMutableArray alloc] init];
    self.titles = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.questions count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![_titles[indexPath.section] isExpanded]) {
        return 0;
    } else {
        return 60.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ClickableHeader *header = (ClickableHeader *)[self.tableView dequeueReusableCellWithIdentifier:kClickableHeaderIdentifier];
    Title *t = self.titles[section];
    if(t.isExpanded) {
        [header.arrowImageView setImage:[UIImage imageNamed:kUpArrowImage]];
    } else {
        [header.arrowImageView setImage:[UIImage imageNamed:kDownArrowImage]];
    }
    
    header.tag = section;
    header.sectionLabel.text = t.title;
    header.contentView.backgroundColor = [UIColor quackFoamColor];
    
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
    Title *t = _titles[section];
    NSLog(@"heeeey: %lu", (unsigned long)[t.title length]);
    return 60.0f + [t.title length] / 35 * 10.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.questions objectAtIndex:section] answers] count];
}

@end
