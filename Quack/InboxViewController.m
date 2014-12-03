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
#import "AnswerTableViewCell.h"
#import "QuackColors.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Title.h"
#import "ClickableHeaderWithAsker.h"

static NSString *kClickableHeaderAskerIdentifier = @"ClickableHeaderWithAsker";
static NSString *kAnswerCellIdentifier = @"AnswerTableViewCell";
static NSString *kUpArrowImage = @"up4-50.png";
static NSString *kDownArrowImage = @"down4-50.png";

@interface InboxViewController ()

@end

@implementation InboxViewController {
    PFObject *_user;
    UILabel *_noQuestionssLabel;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nibA = [UINib nibWithNibName:@"ClickableHeaderWithAsker" bundle:nil];
    [self.tableView registerNib:nibA forCellReuseIdentifier:@"ClickableHeaderWithAsker"];
    
    [self getNewData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor quackPurpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:nil
                            action:@selector(getNewData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    _noQuestionssLabel = [self getLabelWithText:@"No questions in your feed :-("];
    [self.view addSubview:self.refreshLabel];
    [self.view addSubview:_noQuestionssLabel];
    
    //style navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor quackSeaColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //set selected tab bar item image
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
    UIImage* selectedImage = [UIImage imageNamed:@"inbox_active"];
    tabBarItem.selectedImage = selectedImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)getNewData {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 PFUser *user = [PFUser currentUser];
                 NSSet *friendSet = [[NSSet alloc] initWithArray:user[@"friends"]];
                 PFRelation *relation = [user relationForKey:@"inbox"];
                 // Find user's inbox questions, add them to the _userInbox array and reload the tableView
                 PFQuery *questionQuery = [relation query];
                 [questionQuery orderByDescending:@"createdAt"];
                 questionQuery.limit = 100;
                 
                 NSMutableArray *curQuestions = [[NSMutableArray alloc] init];
                 [questionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (error) {
                         NSLog(@"error");
                     } else {
                         for (PFObject *question in objects) {
                             if(question && ![question isKindOfClass:[NSNull class]] && [friendSet containsObject:question[@"authorId"]]) {
                                 Question *q = [[Question alloc] initWithDictionary:(NSDictionary *)question];
                                 [curQuestions addObject:q];
                                 Title *t = [[Title alloc] initWithTitle:q.question];
                                 BOOL found = NO;
                                 for(Question *existing in self.questions) {
                                     if([existing.questionId isEqualToString:q.questionId]) {
                                         found = YES;
                                     }
                                 }
                                 if(!found) {
                                     [self.questions insertObject:q atIndex:0];
                                     [self.titles insertObject:t atIndex:0];
                                 }
                             }
                             
                             
                         }
                         
                         NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:self.questions];
                         NSMutableArray *removedTitles = [[NSMutableArray alloc] initWithArray:self.titles];
                         for(Question *old in self.questions) {
                             for(Question *cur in curQuestions) {
                                 if([old.questionId isEqualToString:cur.questionId]) {
                                     Title *t = [self.titles objectAtIndex:[self.questions indexOfObject:old]];
                                     [removed removeObject:old];
                                     [removedTitles removeObject:t];
                                 }
                             }
                         }
                         
                         for(Question *removedQ in removed) {
                             [self.questions removeObject:removedQ];
                         }
                         
                         for(Title *removedT in removedTitles) {
                             [self.titles removeObject:removedT];
                         }
                         
                         if([self.questions count]) {
                             _noQuestionssLabel.hidden = YES;
                             self.refreshLabel.hidden = YES;
                         } else {
                             _noQuestionssLabel.hidden = NO;
                             self.refreshLabel.hidden = NO;
                         }
                         
                         [self.tableView reloadData];
                         [self updateBadge];
                         
                         if (self.refreshControl) {
                             [self.refreshControl endRefreshing];
                         }
                         
                     }
                 }];
             }
         }];
    } else {
        NSLog(@"fb session not active");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Question *q = (Question *)[self.questions objectAtIndex:indexPath.section];
    if(!q.answerSet) {
        // Select an answer
        q.answerSet = true;
        q.curSelected = indexPath.row + 1;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submit?"
                                                       message:@"Click OK to confirm your answer!"
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        alert.delegate = self;
        alert.tag = indexPath.section + 1;
        [alert show];
        
        // If they end up not submitting, need to re-alert them
        q.answerSet = false;
    } else if(q.answerSet) {
        // Different answer selected
        q.curSelected = indexPath.row + 1;

    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAnswerCellIdentifier];
    Question *q = [self.questions objectAtIndex:indexPath.section];
    cell.answerLabel.text = q.answers[indexPath.row];
    [cell setClipsToBounds:YES];
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor quackFoamColor];
    return cell;
}

- (void)submitAnswerForQuestionAtIndex:(NSInteger)index {
    Question *q = [self.questions objectAtIndex:index];
    Title *t = [self.titles objectAtIndex:index];
    [self.questions removeObject:q];
    [self.titles removeObject:t];
    [self.tableView reloadData];
    [self updateBadge];
    
    if([self.questions count]) {
        _noQuestionssLabel.hidden = YES;
        self.refreshLabel.hidden = YES;
    } else {
        _noQuestionssLabel.hidden = NO;
        self.refreshLabel.hidden = NO;
    }
    
    // get question from Parse
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    [query getObjectInBackgroundWithId:q.questionId block:^(PFObject *question, NSError *error) {
        if (!error) {
            // Remove question from user's inbox
            PFUser *user = [PFUser currentUser];
            PFRelation *relation = [user relationForKey:@"inbox"];
            [relation removeObject:question];
            [user saveInBackground];
            
            // Update question's counts
            NSMutableArray *counts = question[@"counts"];
            counts[q.curSelected - 1] = [NSNumber numberWithInt:[counts[q.curSelected - 1] intValue] + 1];
            [question saveInBackground];
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex) {
        [self submitAnswerForQuestionAtIndex:alertView.tag - 1];
    } else {
        Question *q = [self.questions objectAtIndex:(alertView.tag - 1)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(q.curSelected - 1) inSection:(alertView.tag - 1)];
        AnswerTableViewCell *cell = (AnswerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ClickableHeaderWithAsker *header = (ClickableHeaderWithAsker *)[tableView dequeueReusableCellWithIdentifier:kClickableHeaderAskerIdentifier];

    Title *t = self.titles[section];
    Question *q = self.questions[section];
    if(t.isExpanded) {
        [header.arrowImageView setImage:[UIImage imageNamed:kUpArrowImage]];
    } else {
        [header.arrowImageView setImage:[UIImage imageNamed:kDownArrowImage]];
    }
    
    header.tag = section;
    header.sectionLabel.text = t.title;
    header.askerLabel.text = [NSString stringWithFormat:@"%@ wants to know: ", q.askerName ];
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
    Title *t = [self.titles objectAtIndex:gestureRecognizer.view.tag];
    [t toggleExpansion];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    Question *cur = [self.questions objectAtIndex:section];
    for(int i = 0; i < [cur.answers count]; i++) {
        NSIndexPath *curPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:curPath];
    }
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    Title *t = self.titles[section];
    int _charsPerLine = ceil(self.view.window.frame.size.width / 15);
    if(!_charsPerLine) {
        _charsPerLine = 30;
    }
    return 95.0f + [t.title length] / _charsPerLine * 10.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// update tab bar item badge to be the number of questions a user has in their inbox
- (void)updateBadge {
    if ([self.questions count]) {
        NSString *questionCount = [@([self.questions count]) stringValue];
        [[[[[self tabBarController] tabBar] items]
          objectAtIndex:0] setBadgeValue:questionCount];
    } else {
        [[[[[self tabBarController] tabBar] items]
          objectAtIndex:0] setBadgeValue:nil];
    }
    
}


@end
