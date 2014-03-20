//
// Created on 20/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FBSession.h"


@class FBSession;
@protocol SHFacebookControllerDelegate;

@interface SHFacebookController : NSObject

@property (weak, nonatomic) id<SHFacebookControllerDelegate> delegate;

- (void)setup;
- (void)connectWithFacebook;
- (void)updateScoreOnFacebook:(int)score;
- (BOOL)isFbConnected;
@end

@protocol SHFacebookControllerDelegate
-(void)facebookController:(SHFacebookController *)controller didFinishConnectingWithFacebook:(FBSession *)activeSession;
@end