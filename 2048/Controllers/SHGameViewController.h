//
//  SHGameViewController.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMenuViewController.h"
#import "SHMenuTiltModeViewController.h"
#import "SHGameCenterManager.h"

@class SHFacebookController;
@class SHGameCenterManager;
@class SHMultiplayerHeaderView;
@class FBKVOController;

static const int kSHGameBoardSize = 4;

static const float kSHCellAnimationsDuration = 0.15;
static NSString *const kSHBestUserScoreKey = @"SH_BEST_USER_SCORE";
static const int kSHGameMaxScore = 2048;
static NSString *const kSHUserDefaultsGameOptionTiltEnabled = @"SH_GAME_OPTION_TILT_ENABLED";

@interface SHGameViewController : UIViewController <UICollectionViewDataSource, SHMenuDelegate, SHMenuTiltDelegate, SHGameCenterManagerDelegate>
@property(nonatomic) BOOL isMultiplayer;
@end

@interface SHBoardMoveResult : NSObject
@property(nonatomic) int score;
@property(nonatomic) BOOL moved;

- (instancetype)initWithScore:(int)score moved:(BOOL)moved;

+ (instancetype)resultWithScore:(int)score moved:(BOOL)moved;

@end