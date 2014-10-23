//
//  Question.m
//  Quack
//
//  Created by Chelsea Pugh on 10/9/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "Question.h"

@implementation Question

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if(self == [super init]) {
        self.question = [dictionary objectForKey:@"question"];
        self.answers = [dictionary objectForKey:@"answers"];
    }
    return self;
}

@end