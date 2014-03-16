//
//  SHGameCell.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHGameCellData;
@class SHGameCellView;

@interface SHGameCell : UICollectionViewCell
@property(strong, nonatomic) SHGameCellView *cellView;

- (void)configure:(SHGameCellData *)data;
@end
