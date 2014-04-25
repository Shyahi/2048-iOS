//
// Created on 22/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol SHGameCenterManagerDelegate;
@protocol GameCenterManagerDelegate;
@class SHAppDelegate;

@interface SHGameCenterManager : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener>
@property(nonatomic, strong) GKTurnBasedMatch *currentMatch;
@property(nonatomic, weak) id <SHGameCenterManagerDelegate> delegate;
@property(nonatomic, strong) UIViewController *gameCenterLoginController;
@property(nonatomic, strong) NSError *gameCenterLoginError;

+ (instancetype)sharedManager;

- (void)findMatchWithMinPlayers:(NSUInteger)minPlayers maxPlayers:(NSUInteger)maxPlayers viewController:(UIViewController *)viewController;

- (void)setupWithAppDelegate:(SHAppDelegate *)delegate;
@end

@protocol SHGameCenterManagerDelegate <NSObject>
- (void)enterNewGame:(GKTurnBasedMatch *)match;

- (void)layoutMatch:(GKTurnBasedMatch *)match;

- (void)recieveEndGame:(GKTurnBasedMatch *)match;

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;

@optional
- (void)gameCenterManager:(SHGameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController;

- (void)gameCenterManagerdidFailToAuthenticatePlayer:(SHGameCenterManager *)manager;

- (void)gameCenterManager:(SHGameCenterManager *)manager didAuthenticatePlayer:(GKLocalPlayer *)player;
@end
