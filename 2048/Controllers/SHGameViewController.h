//
//  SHGameViewController.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameCenterManager/GameCenterManager.h>
#import "SHMenuViewController.h"
#import "SHMenuTiltModeViewController.h"

@class SHFacebookController;

static const int kSHGameBoardSize = 4;

static const float kSHCellAnimationsDuration = 0.15;
static NSString *const kSHBestUserScoreKey = @"SH_BEST_USER_SCORE";
static const int kSHGameMaxScore = 2048;
static NSString *const kSHUserDefaultsGameOptionTiltEnabled = @"SH_GAME_OPTION_TILT_ENABLED";
static NSString *const kSHGameCenterManagerUnknownPlayer = @"unknownPlayer";
typedef NS_ENUM(NSUInteger, SHMoveDirection) {
    kSHMoveDirectionLeft,
    kSHMoveDirectionRight,
    kSHMoveDirectionUp,
    kSHMoveDirectionDown
};

@interface SHGameViewController : UIViewController <UICollectionViewDataSource, SHMenuDelegate, SHMenuTiltDelegate, GameCenterManagerDelegate>
@property(strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *gameContainerView;

@property (strong, nonatomic) IBOutlet UIView *scoreView;
@property (strong, nonatomic) IBOutlet UIView *bestScoreView;
@property (strong, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UIView *gameTerminatedView;
@property (strong, nonatomic) IBOutlet UIView *gameWonView;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@end
