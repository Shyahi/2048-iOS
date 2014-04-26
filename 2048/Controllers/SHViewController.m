//
//  SHViewController.m
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "SHViewController.h"
#import "HexColor.h"
#import "UIImage+ImageWithColor.h"
#import "SHGameViewController.h"
#import "Reachability.h"

@interface SHViewController ()

@property(nonatomic, strong) SHFacebookController *facebookController;
@property(nonatomic, strong) EAIntroView *introView;
@end

@implementation SHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"INTRO_VIEW_SHOWN"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"INTRO_VIEW_SHOWN"];
        [self setupFacebook];
        [self showIntroView];
    }
}

- (void)setupFacebook {
    self.facebookController = [[SHFacebookController alloc] init];
    [self.facebookController setup];
}

- (void)showIntroView {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"One swipe moves all";
    page1.desc = @"Swipe in any direction to move the tiles in that direction";
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2048-1"]];
    [self styleIntroPage:page1];


    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Join tiles to get 2048";
    page2.desc = @"When two tiles with the same number touch, they merge into one!";
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2048-2"]];
    [self styleIntroPage:page2];

    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Also works with tilt";
    page3.desc = @"Enable tilt mode to move the tiles with simple tilt gestures";
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TiltGestureLeft"]];
    [self styleIntroPage:page3];

    EAIntroPage *page4 = [EAIntroPage pageWithCustomViewFromNibNamed:@"SHFacebookIntroView"];
    SHFacebookIntroView *view = (SHFacebookIntroView *) page4.customView;
    view.delegate = self;
    [self styleIntroPage:page4];

    self.introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4]];
    self.introView.delegate = self;
    self.introView.pageControl.currentPageIndicatorTintColor = [[UIColor colorWithHexString:@"#776e65"] colorWithAlphaComponent:0.8];
    self.introView.pageControl.pageIndicatorTintColor = [[UIColor colorWithHexString:@"#776e65"] colorWithAlphaComponent:0.1];
    self.introView.skipButton = nil;
    self.introView.swipeToExit = NO;
    [self.introView showInView:self.view animateDuration:0.0];
}

- (void)styleIntroPage:(EAIntroPage *)page {
    page.titleIconPositionY = ((IS_IPHONE_5) ? 0.124166667f : 0.08f) * self.view.bounds.size.height;
    page.bgImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#faf8ef"]];
    page.titlePositionY = 0.28125f * self.view.bounds.size.height;
    page.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:20];
    page.titleColor = [UIColor colorWithHexString:@"#776e65"];
    page.descColor = [[UIColor colorWithHexString:@"#776e65"] colorWithAlphaComponent:0.9];
    page.descFont = [UIFont fontWithName:@"Avenir-Light" size:17];
    page.descPositionY = 0.239583333f * self.view.bounds.size.height;
}


#pragma mark - Storyboard Outlets
- (IBAction)singlePlayerTap:(id)sender {
    [self startGameWithMultiplayer:NO];
}


- (IBAction)multiplayerTap:(id)sender {
    if ([self isInternetAvailable]) {
        [self startGameWithMultiplayer:YES];
    } else {
        [UIAlertView bk_showAlertViewWithTitle:@"You are offline" message:@"You must be connected to the internet to play a multiplayer game" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
    }
}

#pragma mark - Intro View Delegate
- (void)introDidFinish:(EAIntroView *)introView {
    [introView hideWithFadeOutDuration:1];
}

#pragma mark - Facebook Intro Delegate
- (void)playButtonClick {
//    [self startGameWithMultiplayer:NO];
    [self.introView hideWithFadeOutDuration:1];
}

- (void)didConnectWithFacebook {
    // Do nothing.
}

#pragma mark - Navigation
- (void)startGameWithMultiplayer:(BOOL)multiplayer {
    if (multiplayer) {
        [self performSegueWithIdentifier:kSHMultiplayerGameSegueIdentifier sender:self];
    } else {
        [self performSegueWithIdentifier:kSHGameSegueIdentifier sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:kSHMultiplayerGameSegueIdentifier]) {
        SHGameViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.isMultiplayer = YES;
    }
}


#pragma mark - Utility
- (BOOL)isInternetAvailable {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
