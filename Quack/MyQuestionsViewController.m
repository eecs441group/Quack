//
//  MyQuestionsViewController.m
//  
//
//  Created by Chelsea Pugh on 10/4/14.
//
//

#import "MyQuestionsViewController.h"

@interface MyQuestionsViewController ()

@end

@implementation MyQuestionsViewController {
    NSMutableArray *_myQuestions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"wtf");
    _myQuestions = [[NSMutableArray alloc] init];
        
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
    
    cell.textLabel.text = [_myQuestions objectAtIndex:indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
