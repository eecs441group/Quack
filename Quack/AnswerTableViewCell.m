//
//  InboxQuestionTableViewCell.m
//  Quack
//
//  Created by Chelsea Pugh on 10/23/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "AnswerTableViewCell.h"
#import "QuackColors.h"

@implementation AnswerTableViewCell

- (void)awakeFromNib {
    self.answerLabel.textColor = [UIColor quackCharcoalColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
