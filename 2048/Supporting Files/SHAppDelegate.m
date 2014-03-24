//
//  SHAppDelegate.m
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHAppDelegate.h"
#import "Flurry.h"
#import "FBAppCall.h"
#import "GameCenterManager.h"

@implementation SHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupLogging];
    [self setupAnalytics];
    [self setupGameCenter];
    return YES;
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

    // Handle the user leaving the app while the Facebook login dialog is being shown
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FBSession activeSession] close];
}

#pragma mark - Setup
- (void)setupAnalytics {
//    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"R2MWC8V6XV5JZ3GDT9JN"];
}

- (void)setupLogging {
    // Configure CocoaLumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

    // Configure colors
#if TARGET_OS_IPHONE
    UIColor *pink = [UIColor colorWithRed:0.44 green:0.24 blue:0.67 alpha:1.0];
    UIColor *green = [UIColor colorWithRed:0.40 green:0.52 blue:0 alpha:1.0];
#else
    NSColor *pink = [NSColor colorWithCalibratedRed:0.44 green:0.24 blue:0.67 alpha:1.0];
    UIColor *green = [UIColor colorWithCalibratedRed:0.40 green:0.52 blue:0 alpha:1.0];
#endif

    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:green backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
}

#pragma mark - Facebook
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // After Facebook authentication, app will be called back with the session information.
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - Game Center
- (void)setupGameCenter {
    [[GameCenterManager sharedManager] setupManager];
}

@end
