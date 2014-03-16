//
//  SHGameViewController.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

static const int kSHGameBoardSize = 4;

static const float kSHCellAnimationsDuration = 0.5;
typedef NS_ENUM(NSUInteger, SHMoveDirection) {
    kSHMoveDirectionLeft,
    kSHMoveDirectionRight,
    kSHMoveDirectionUp,
    kSHMoveDirectionDown
};

@interface SHGameViewController : UIViewController <UICollectionViewDataSource>
@property(strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
