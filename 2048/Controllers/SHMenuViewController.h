//
//  SHMenuViewController.h
//  2048
//
//  Created by Pulkit Goyal on 20/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHMenuDelegate;

@interface SHMenuViewController : UIViewController

@property(strong, nonatomic) IBOutlet UIButton *tiltModeButton;
@property(strong, nonatomic) IBOutlet UIButton *theNewGameButton;
@property(strong, nonatomic) IBOutlet UIButton *closeButton;

@property(strong, nonatomic) id <SHMenuDelegate> delegate;
@end

@protocol SHMenuDelegate
- (void)tiltModeClick;
- (void)startNewGameClick;
- (void)closeClick;
@end
