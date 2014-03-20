//
//  SHFacebookIntroView.m
//  2048
//
//  Created by Pulkit Goyal on 20/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHFacebookIntroView.h"
#import "UIView+SHAdditions.h"
#import "SHFacebookController.h"
#import "FBLoginView.h"

@interface SHFacebookIntroView ()
@property(nonatomic, strong) SHFacebookController *facebookController;
@end

@implementation SHFacebookIntroView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.playButton sh_addCornerRadius:4];
    self.fbLoginView.delegate = self;
}

- (IBAction)playButtonClick:(id)sender {
    [self.delegate playButtonClick];
}

#pragma mark - FB Login View Delegate
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if (FBSession.activeSession.isOpen && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // Request publish_actions
        [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                [self.delegate didConnectWithFacebook];
                                            }];
        return;
    } else {
        [self.delegate didConnectWithFacebook];
    }
}

@end
