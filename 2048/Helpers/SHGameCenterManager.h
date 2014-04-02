//
// Created on 22/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol SHGameCenterManagerDelegate;
@protocol GameCenterManagerDelegate;

@interface SHGameCenterManager : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener, GameCenterManagerDelegate>
@property(nonatomic, strong) GKTurnBasedMatch *currentMatch;
@property(nonatomic, weak) id <SHGameCenterManagerDelegate> delegate;
@property(nonatomic, strong) UIViewController *gameCenterLoginController;

+ (instancetype)sharedManager;

- (void)findMatchWithMinPlayers:(NSUInteger)minPlayers maxPlayers:(NSUInteger)maxPlayers viewController:(UIViewController *)viewController;

- (void)setup;
@end

@protocol SHGameCenterManagerDelegate
- (void)enterNewGame:(GKTurnBasedMatch *)match;

- (void)layoutMatch:(GKTurnBasedMatch *)match;

- (void)recieveEndGame:(GKTurnBasedMatch *)match;

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;
@end
