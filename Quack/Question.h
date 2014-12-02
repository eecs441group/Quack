//
//  Question.h
//  Quack
//
//  Created by Chelsea Pugh on 10/9/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (strong, nonatomic) NSString *question;
@property (strong, nonatomic) NSArray *answers;
@property (strong, nonatomic) NSString *questionId;
@property (assign, nonatomic) bool answerSet;
@property (assign, nonatomic) long curSelected;
@property (strong, nonatomic) NSMutableArray *counts;
@property (strong, nonatomic) NSString *askerName;
@property (strong, nonatomic) NSString *authorId;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
