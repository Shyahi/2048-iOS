//
// Created on 22/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol SHGameCenterManagerDelegate;

@interface SHGameCenterManager : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener>
@property(nonatomic, strong) GKTurnBasedMatch *currentMatch;
@property(nonatomic, weak) id <SHGameCenterManagerDelegate> delegate;

- (void)findMatchWithMinPlayers:(NSUInteger)minPlayers maxPlayers:(NSUInteger)maxPlayers viewController:(UIViewController *)viewController;
@end

@protocol SHGameCenterManagerDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match;

- (void)layoutMatch:(GKTurnBasedMatch *)match;

- (void)recieveEndGame:(GKTurnBasedMatch *)match;

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;
@end
