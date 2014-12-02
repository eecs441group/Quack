//
//  MyQuestionsViewController.m
//  
//
//  Created by Chelsea Pugh on 10/4/14.
//
//

#import "ResultsViewController.h"
#import "Question.h"
#import "QuackColors.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHud.h"
#import "Title.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController {
    UILabel *_noQuestionssLabel;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getNewData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor quackPurpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:nil
                            action:@selector(getNewData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    _noQuestionssLabel = [self getLabelWithText:@"You haven't Quack'd any questions :-("];
    [self.view addSubview:_noQuestionssLabel];
    
    //style navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor quackSeaColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //set selected tab bar item image
    UITabBarItem *tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:2];
    UIImage* selectedImage = [UIImage imageNamed:@"bar_chart_active"];
    tabBarItem.selectedImage = selectedImage;
}

- (void)getNewData {
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 PFUser *user = [PFUser currentUser];
                 
                 PFQuery *query = [PFQuery queryWithClassName:@"Question"];
                 [query whereKey:@"authorId" equalTo:user[@"FBUserID"]];
                 [query orderByAscending:@"createdAt"];
                 
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (!error) {
                         for (PFObject *object in objects) {
                             Question *q = [[Question alloc] initWithDictionary:(NSDictionary *)object];
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
                         if([self.questions count]) {
                             _noQuestionssLabel.hidden = YES;
                         } else {
                             _noQuestionssLabel.hidden = NO;
                         }
                         
                         [self.tableView reloadData];
                         
                         if (self.refreshControl) {
                             [self.refreshControl endRefreshing];
                         }
                     } else {
                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                     }
                 }];
             }
         }];
    } else {
        NSLog(@"fb session not active");
    }

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [self removeDataFromCell:cell];
    [self addDataToCell:cell question:(Question *)self.questions[indexPath.section]];
    [cell setClipsToBounds:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)addDataToCell:(UITableViewCell *)cell question:(Question *)question{
    
    float total = 0;
    int i = 0;
    for(; i < [question.counts count]; i++) {
        total += [question.counts[i] intValue];
    }
    for(i = 0; i < [question.answers count]; i++) {
        float proportion = total > 0 ? [question.counts[i] intValue] / total : 0.0;
        CGFloat width = (self.view.frame.size.width - 25) * proportion;
        UIView *v = [self getRectWithColor:(width ? [UIColor quackGreenColor] : [UIColor quackRedColor]) width:width ycoord:(50 + i*55)];
        UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + i*55, self.view.frame.size.width - 20, 40)];
        answerLabel.textColor = [UIColor quackCharcoalColor];
        answerLabel.text = [NSString stringWithFormat:@"%@ (%d)", question.answers[i], [question.counts[i] intValue]];
        answerLabel.font = [UIFont fontWithName:@"Thonburi" size:14.0f];
        [answerLabel setTag:i + 1];
        [v setTag:i + 1];
        [cell addSubview:answerLabel];
        [cell addSubview:v];
        
    }
}

- (void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    NSInteger section = gestureRecognizer.view.tag;
    Title *t = [self.titles objectAtIndex:gestureRecognizer.view.tag];
    [t toggleExpansion];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(int i = 0; i < 1; i++) {
        NSIndexPath *curPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:curPath];
//        if(t.isExpanded) {
//            [self removeDataFromCell:[self.tableView cellForRowAtIndexPath:curPath]];
//            [self addDataToCell:[self.tableView cellForRowAtIndexPath:curPath] question:(Question *)self.questions[section]];
//        }
    }
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![self.titles[indexPath.section] isExpanded]) {
        return 0;
    } else {
        Question *q = self.questions[indexPath.section];
        return 55.0 * q.answers.count + 35;
    }
}

- (IBAction)shareButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                    message:@"This feature has not been implemented yet."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)removeDataFromCell:(UITableViewCell *)cell {
    for (UIView *view in cell.subviews) {
        if ((view.tag >= 1 && view.tag <= 4) || [view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}

- (UIView *)getRectWithColor:(UIColor *)color width:(int)width ycoord:(int)ycoord {
    CGRect rectangle = CGRectMake(10, ycoord, width + 5, 15);
    UIView *bar = [[UIView alloc] initWithFrame:rectangle];
    bar.backgroundColor = color;
    return bar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
