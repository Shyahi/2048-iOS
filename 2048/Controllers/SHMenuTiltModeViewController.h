//
//  SHMenuTiltModeViewController.h
//  2048
//
//  Created by Pulkit Goyal on 20/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHMenuTiltDelegate;

@interface SHMenuTiltModeViewController : UIViewController

@property(strong, nonatomic) IBOutlet UIButton *enableTiltButton;
@property(strong, nonatomic) IBOutlet UIButton *disableTiltButton;

@property(strong, nonatomic) id <SHMenuTiltDelegate> delegate;
@end

@protocol SHMenuTiltDelegate
- (void)enableTiltClick;

- (void)disableTiltClick;
@end