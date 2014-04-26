//
//  SHHowToPlayViewController.h
//  2048
//
//  Created by Pulkit Goyal on 26/04/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHMenuHowToPlayDelegate;

@interface SHHowToPlayViewController : UIViewController

@property(nonatomic) BOOL isMultiplayer;
@property(strong, nonatomic) id <SHMenuHowToPlayDelegate> delegate;
@end

@protocol SHMenuHowToPlayDelegate
- (void)closeClick;
@end