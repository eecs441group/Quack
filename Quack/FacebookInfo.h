//
//  Facebook.h
//  Quack
//
//  Created by Connie Qi on 10/9/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookInfo : NSObject

- (id)initWithAccountID:(NSString *) userId;
- (void)getFriends:(void (^)(NSArray* fbFriends))handler;

@end
