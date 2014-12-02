//
//  ClickableHeaderWithAsker.m
//  Quack
//
//  Created by Chelsea Pugh on 12/1/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "ClickableHeaderWithAsker.h"
#import "QuackColors.h"

@implementation ClickableHeaderWithAsker

- (void)awakeFromNib {
    self.sectionLabel.textColor = [UIColor quackCharcoalColor];
    self.askerLabel.textColor = [UIColor quackCharcoalColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
