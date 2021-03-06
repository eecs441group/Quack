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
    
    self.refreshLabel = [self getRefreshLabel];
    
    self.questions = [NSMutableArray new];
    self.titles = [NSMutableArray new];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:@"ClickableHeader" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ClickableHeader"];
    
    UINib *nibQ = [UINib nibWithNibName:@"AnswerTableViewCell" bundle:nil];
    [self.tableView registerNib:nibQ forCellReuseIdentifier:@"AnswerTableViewCell"];
    
    UINib *nibA = [UINib nibWithNibName:@"ClickableHeaderWithAsker" bundle:nil];
    [self.tableView registerNib:nibA forCellReuseIdentifier:@"ClickableHeaderWithAsker"];
}

- (UILabel *)getLabelWithText:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    lbl.text = text;
    lbl.font = [UIFont fontWithName:@"Thonburi" size:17.0f];
    lbl.textColor = [UIColor quackCharcoalColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    return lbl;
}

- (UILabel *)getRefreshLabel {
    UILabel *lbl0 = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + 45, self.view.frame.size.width, self.view.frame.size.height)];
    lbl0.text = @"Pull down to refresh!";
    lbl0.font = [UIFont fontWithName:@"Thonburi" size:17.0f];
    lbl0.textColor = [UIColor quackCharcoalColor];
    lbl0.textAlignment = NSTextAlignmentCenter;
    return lbl0;
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
        Question *q = self.questions[indexPath.section];
        int _charsPerLine = ceil(self.view.window.frame.size.width / 15);
        if(!_charsPerLine) {
            _charsPerLine = 30;
        }
        return 60.0f + [q.answers[indexPath.row] length] / _charsPerLine * 5.0f;
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
    header.contentView.backgroundColor = [UIColor quackShellColor];
    
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
    int _charsPerLine = ceil(self.view.window.frame.size.width / 15);
    if(!_charsPerLine) {
        _charsPerLine = 30;
    }
    return 60.0f + [t.title length] / _charsPerLine * 10.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.questions objectAtIndex:section] answers] count];
}

@end
