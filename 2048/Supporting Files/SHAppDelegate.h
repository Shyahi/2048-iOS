//
//  SHAppDelegate.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHGameCenterManager;
@class GKTurnBasedMatch;

@interface SHAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

- (void)layoutMatch:(GKTurnBasedMatch *)match;
@end
