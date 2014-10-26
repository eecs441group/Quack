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
#import "QuestionTableViewCell.h"

@interface MyQuestionsViewController ()

@end

@implementation MyQuestionsViewController {
    NSMutableArray *_myQuestions;
    NSMutableArray *_expandedCells;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _myQuestions = [[NSMutableArray alloc] init];
    _expandedCells = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"QuestionTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"QuestionTableViewCell"];

}

- (void) viewDidAppear:(BOOL)animated {
    // Get all questions that this user authored and show them in the view
    if (FBSession.activeSession.isOpen) {
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *userId = [result objectForKey:@"id"];
                 
                 PFQuery *query = [PFQuery queryWithClassName:@"Question"];
                 [query whereKey:@"authorId" equalTo:userId];
                 [query orderByDescending:@"createdAt"];
                 
                 [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     if (!error) {
                         // Remove all old objects and append them to the MyQuestions array
                         // There's probably a more efficient way to do this other than removing all objects every time?
                         // Putting this here for now so we don't see duplicates
                         [_myQuestions removeAllObjects];
                         
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
    static NSString *simpleTableIdentifier = @"QuestionTableViewCell";
    
    QuestionTableViewCell *cell = (QuestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Question *q = [_myQuestions objectAtIndex:indexPath.row];
    
    cell.questionLabel.text = q.question;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //expandedCells is a mutable set declared in your interface section or private class extensiont
    if ([_expandedCells containsObject:indexPath])
    {
        [_expandedCells removeObject:indexPath];
        [self removeDataFromCell:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
    else
    {
        [_expandedCells addObject:indexPath];
        [self addDataToCell:[self.tableView cellForRowAtIndexPath:indexPath] question:[_myQuestions objectAtIndex:indexPath.row]];
    }
    [self.tableView reloadData];
}

- (void)addDataToCell:(UITableViewCell *)cell question:(Question *)question{
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    
    [query getObjectInBackgroundWithId:question.questionId block:^(PFObject *question, NSError *error) {
        float total = 0;
        for(int i = 0; i < 4; i++) {
            total += [question[@"counts"][i] intValue];
        }
        for(int i = 0; i < 4; i++) {
            float proportion = total > 0 ? [question[@"counts"][i] intValue] / total : 0.0;
            UIView *v = [self getRectWithColor:[UIColor greenColor] width:(250 * proportion) ycoord:(95 + i*55)];
            UILabel *answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 55 + i*55, 200, 40)];
            answerLabel.text = [NSString stringWithFormat:@"%@ (%d)", question[@"answers"][i], [question[@"counts"][i] intValue]];
            [answerLabel setTag:i + 1];
            [v setTag:i + 1];
            [cell addSubview:answerLabel];
            [cell addSubview:v];
        }
    }];
}

- (void)removeDataFromCell:(UITableViewCell *)cell {
    for (UIView *view in cell.subviews) {
        if (view.tag >= 1 && view.tag <= 4) {
            [view removeFromSuperview];
        }
    }
}

- (UIView *)getRectWithColor:(UIColor *)color width:(int)width ycoord:(int)ycoord {
    CGRect rectangle = CGRectMake(50, ycoord, width, 10);
    UIView *bar = [[UIView alloc] initWithFrame:rectangle];
    bar.backgroundColor = color;
    return bar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_expandedCells containsObject:indexPath])
    {
        return 300.0; //It's not necessary a constant, though
    }
    else
    {
        return 80.0; //Again not necessary a constant
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
