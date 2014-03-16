//
//  SHGameViewController.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

static const int kSHGameBoardSize = 4;

static const float kSHCellAnimationsDuration = 0.15;
static NSString *const kSHBestUserScoreKey = @"SH_BEST_USER_SCORE";
static const int kSHGameMaxScore = 2048;
typedef NS_ENUM(NSUInteger, SHMoveDirection) {
    kSHMoveDirectionLeft,
    kSHMoveDirectionRight,
    kSHMoveDirectionUp,
    kSHMoveDirectionDown
};

@interface SHGameViewController : UIViewController <UICollectionViewDataSource>
@property(strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *gameContainerView;

@property (strong, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UIView *gameTerminatedView;
@property (strong, nonatomic) IBOutlet UIView *gameWonView;
@end
