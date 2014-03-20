//
//  SHFacebookIntroView.h
//  2048
//
//  Created by Pulkit Goyal on 20/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginView.h"

@protocol SHFacebookIntroDelegate;
@class FBLoginView;

@interface SHFacebookIntroView : UIView <FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) id<SHFacebookIntroDelegate> delegate;
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@end

@protocol SHFacebookIntroDelegate
-(void) playButtonClick;
- (void)didConnectWithFacebook;
@end