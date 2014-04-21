//
// Created on 22/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import "SHGameCenterManager.h"
#import "UIAlertView+BlocksKit.h"
#import "Reachability.h"
#import "SHAppDelegate.h"

@interface SHGameCenterManager ()
@property(nonatomic, strong) UIViewController *presentingViewController;
@property(nonatomic, weak) SHAppDelegate *appDelegate;
@end

@implementation SHGameCenterManager {

}

#pragma mark Public methods
- (void)setupWithAppDelegate:(SHAppDelegate *)delegate {
    self.appDelegate = delegate;
    [self authenticateLocalPlayer];
}

+ (instancetype)sharedManager {
    static SHGameCenterManager *singleton;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });

    return singleton;
}

- (void)findMatchWithMinPlayers:(NSUInteger)minPlayers maxPlayers:(NSUInteger)maxPlayers viewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;

    // Create a match request
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;

    // Create and present the standard iOS matchmaking view controller
    GKTurnBasedMatchmakerViewController *turnBasedMatchmakerViewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    turnBasedMatchmakerViewController.turnBasedMatchmakerDelegate = self;
    turnBasedMatchmakerViewController.showExistingMatches = YES;
    [self.presentingViewController presentViewController:turnBasedMatchmakerViewController animated:YES completion:nil];
}

#pragma mark - Turn Based Matchmaker View Controller Delegate
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    DDLogVerbose(@"Turn based match cancelled");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    DDLogVerbose(@"Turn based error %@", error);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Turn based found match");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    self.currentMatch = match;

    // Check if this is a new match or an existing one.
    GKTurnBasedParticipant *firstParticipant = [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == NULL) {
        // It's a new game!
        [self.delegate enterNewGame:match];
    } else {
        [self.delegate layoutMatch:match];
    }
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Turn based player quit for match");
    // Find the next player
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *next = [match.participants objectAtIndex:(currentIndex + 1) % [match.participants count]];
    // Pass the turn to next player with a winning outcome.
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:@[next] turnTimeout:MAXFLOAT matchData:match.matchData completionHandler:nil];
    [next setMatchOutcome:GKTurnBasedMatchOutcomeWon];

    // End match
    [match endMatchInTurnWithMatchData:match.matchData completionHandler:nil];
}

#pragma mark Turn Based Event Handler Delegate
- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {

    DDLogVerbose(@"Player received turn.");
    if (didBecomeActive) {
        // Application was started by clicking on this notification. Switch to this match.
        self.currentMatch = match;

        if (self.delegate == nil) {
            [self.appDelegate layoutMatch:match];
        } else {
            [self.delegate layoutMatch:match];
        }
    } else {
        if ([self.currentMatch isEqual:match]) {
            // This is the current match. Update UI for this turn.
            self.currentMatch = match;
            [self.delegate layoutMatch:match];
        } else if ([match.currentParticipant.playerID isEqual:player.playerID]) {
            // Its our player's turn in another match. Notify him.
            [UIAlertView bk_showAlertViewWithTitle:@"Its your turn" message:@"Its your turn in another match. Switch now?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Take turn"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                switch (buttonIndex) {
                    case 1:
                        // Switch match
                        self.currentMatch = match;
                        [self.appDelegate layoutMatch:match];
                        break;
                    default:
                        break;
                }
            }];
        }
    }
}

- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Match %@ ended", match);
    if ([self.currentMatch isEqual:match]) {
        // Inform the user that match is over.
        self.currentMatch = match;
        [self.delegate layoutMatch:match];
    }
}

#pragma mark - Utility methods
- (void)authenticateLocalPlayer {
    if ([self isInternetAvailable]) {
        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error) {
            if (viewController != nil) {
                self.gameCenterLoginController = viewController;
                if ([self.delegate respondsToSelector:@selector(gameCenterManager:authenticateUser:)]) {
                    [self.delegate gameCenterManager:self authenticateUser:viewController];
                }
            } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
                // Register listener
                [[GKLocalPlayer localPlayer] registerListener:self];

                // Call didAuthenticatePlayer on delegate
                if ([self.delegate respondsToSelector:@selector(gameCenterManager:didAuthenticatePlayer:)]) {
                    [self.delegate gameCenterManager:self didAuthenticatePlayer:[GKLocalPlayer localPlayer]];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(gameCenterManagerdidFailToAuthenticatePlayer:)]) {
                    [self.delegate gameCenterManagerdidFailToAuthenticatePlayer:self];
                }
            }
        };
    }
}

- (BOOL)isInternetAvailable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];

    if (internetStatus == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

@end