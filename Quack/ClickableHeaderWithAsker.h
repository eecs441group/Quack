//
//  ClickableHeaderWithAsker.h
//  Quack
//
//  Created by Chelsea Pugh on 12/1/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClickableHeaderWithAsker : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *askerLabel;
@property (strong, nonatomic) IBOutlet UILabel *sectionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@end
