//
//  MyQuestionsViewController.h
//  
//
//  Created by Chelsea Pugh on 10/4/14.
//
//

#import <UIKit/UIKit.h>

@interface MyQuestionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
