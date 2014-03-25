//
//  SHMultiplayerHeaderView.h
//  2048
//
//  Created by Pulkit Goyal on 24/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHTriangleView;
@class SHGameTurn;

@interface SHMultiplayerHeaderView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *player1ImageView;
@property (strong, nonatomic) IBOutlet UIImageView *player2ImageView;
@property (strong, nonatomic) IBOutlet UILabel *player1ScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *player2ScoreLabel;
@property (strong, nonatomic) IBOutlet SHTriangleView *player1TurnIndicatorView;
@property (strong, nonatomic) IBOutlet SHTriangleView *player2TurnIndicatorView;

- (void)setMatch:(GKTurnBasedMatch *)match turn:(SHGameTurn *)turn;
@end
