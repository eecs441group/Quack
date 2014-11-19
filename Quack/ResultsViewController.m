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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // Get all questions that this user authored and show them in the view
    if (FBSession.activeSession.isOpen) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 PFUser *user = [PFUser currentUser];
                 
                 PFQuery *query = [PFQuery queryWithClassName:@"Question"];
                 [query whereKey:@"authorId" equalTo:user[@"FBUserID"]];
                 [query orderByDescending:@"createdAt"];
                 
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (!error) {
                         for (PFObject *object in objects) {
                             Question *q = [[Question alloc] initWithDictionary:(NSDictionary *)object];
                             [self.questions addObject:q];
                             [self.titles addObject:[[Title alloc] initWithTitle:q.question]];
                         }
                         [self.tableView reloadData];
                     } else {
                         // Log details of the failure
                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                     }
                     [hud hide:YES];
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
        CGFloat width = 250 * proportion;
        UIView *v = [self getRectWithColor:(width ? [UIColor quackGreenColor] : [UIColor quackSandColor]) width:width ycoord:(50 + i*55)];
        UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10 + i*55, 200, 40)];
        answerLabel.text = [NSString stringWithFormat:@"%@ (%d)", question.answers[i], [question.counts[i] intValue]];
        [answerLabel setTag:i + 1];
        [v setTag:i + 1];
        [cell addSubview:answerLabel];
        [cell addSubview:v];
        
    }
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 55 + i * 55, 200, 40)];
    [shareButton setTitle:@"Share Results" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cell addSubview:shareButton];
}

- (void) gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    NSInteger section = gestureRecognizer.view.tag;
    Title *t = [self.titles objectAtIndex:gestureRecognizer.view.tag];
    [t toggleExpansion];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(int i = 0; i < 1; i++) {
        NSIndexPath *curPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:curPath];
    }
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![self.titles[indexPath.section] isExpanded]) {
        return 0;
    } else {
        Question *q = self.questions[indexPath.section];
        return 60.0 * q.answers.count + 5;
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
    CGRect rectangle = CGRectMake(50, ycoord, width + 5, 10);
    UIView *bar = [[UIView alloc] initWithFrame:rectangle];
    bar.backgroundColor = color;
    return bar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
