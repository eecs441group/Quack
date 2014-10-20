//
//  Facebook.m
//  Quack
//
//  Created by Connie Qi on 10/9/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "FacebookInfo.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookInfo ()

@property (strong, nonatomic) NSString *userId;

@end

@implementation FacebookInfo

- (id)initWithAccountID:(NSString *) userId {
    if ( self = [super init] ) {
        self.userId = userId;
    }

    return self;
}

- (void)getFriends:(void (^)(NSArray* friends))handler {
    /* get user's friends who use quack */
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */

//                              NSLog(@"Total friends %@", result[@"summary"][@"total_count"]);
//                              NSLog(@"Quacking friends %lu", (unsigned long)[result[@"data"] count]);
//                              NSLog(@"result %@", result);
                              // Result is an array of dictionaries. Each dict has id and name fields.

                              handler(result[@"data"]);
                          }];
}

@end
