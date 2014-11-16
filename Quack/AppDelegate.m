//
//  AppDelegate.m
//  Quack
//
//  Created by Chelsea Pugh on 10/4/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "Secrets.h"
#import "QuackColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UITabBar appearance] setTintColor:[UIColor quackSeaColor]];

    
    Secrets *secrets = [[Secrets alloc] init];
    [Parse setApplicationId:secrets.parseId
                  clientKey:secrets.parseKey];
    [FBLoginView class];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    //Make a FBLoginView so we can check if the session is active
    FBLoginView *firstLoginView =
        [[FBLoginView alloc] initWithReadPermissions:
         @[@"public_profile", @"email", @"user_friends"]];
    
    // Show login view on app launch. Will be dismissed on successful login.
    if (!FBSession.activeSession.isOpen) {
        [self showLoginViewController:NO];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse
    NSLog(@"didRegisterforRemoteNotifications called with deviceToken: %@", deviceToken);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifcations with error: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Facebook login handler
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    BOOL loginHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    return loginHandled;
}

- (void)showLoginViewController:(BOOL)animated {
    // Get login screen from storyboard and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // "loginScreen" is the Storyboard Id for the Login ViewController
    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"loginScreen"];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController
                                                 animated:animated
                                               completion:nil];
}

@end
