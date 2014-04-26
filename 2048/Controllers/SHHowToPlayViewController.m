//
//  SHHowToPlayViewController.m
//  2048
//
//  Created by Pulkit Goyal on 26/04/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHHowToPlayViewController.h"
#import "UIView+SHAdditions.h"

@interface SHHowToPlayViewController ()

@property(strong, nonatomic) IBOutlet UILabel *label;
@property(strong, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation SHHowToPlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleButton:self.closeButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isMultiplayer) {
        self.label.text = @"Compete against another player on the same board. You get points only for the tiles that you merge. The player with higher score wins the game.";
    } else {
        self.label.text = @"Move the board in any direction by swiping. All the tiles move in that direction. When two tiles with the same value move close, they join. The aim is to reach the 2048 tile.";
    }
}

- (void)styleButton:(UIButton *)button {
    [button sh_addCornerRadius:20];
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    button.layer.borderWidth = 2;
}

#pragma mark - Storyboard outlets
- (IBAction)closeClick:(id)sender {
    [self.delegate closeClick];
}

@end
