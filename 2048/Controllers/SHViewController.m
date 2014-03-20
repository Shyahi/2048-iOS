//
//  SHViewController.m
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHViewController.h"
#import "HexColor.h"
#import "UIImage+ImageWithColor.h"

@interface SHViewController ()

@property(nonatomic, strong) SHFacebookController *facebookController;
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
    } else {
        [self startGame];
    }
}

- (void)setupFacebook {
    self.facebookController = [[SHFacebookController alloc] init];
    [self.facebookController setup];
}

- (void)startGame {
    [self performSegueWithIdentifier:@"SH_GAME_SEGUE" sender:self];
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

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4]];
    intro.delegate = self;
    intro.pageControl.currentPageIndicatorTintColor = [[UIColor colorWithHexString:@"#776e65"] colorWithAlphaComponent:0.8];
    intro.pageControl.pageIndicatorTintColor = [[UIColor colorWithHexString:@"#776e65"] colorWithAlphaComponent:0.1];
    intro.skipButton = nil;
    intro.swipeToExit = NO;
    [intro showInView:self.view animateDuration:0.0];
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

#pragma mark - Intro View Delegate
- (void)introDidFinish:(EAIntroView *)introView {
    [self startGame];
}

#pragma mark - Facebook Intro Delegate
- (void)playButtonClick {
    [self startGame];
}

- (void)didConnectWithFacebook {
    // Do nothing.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
