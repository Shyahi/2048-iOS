//
//  SHMenuViewController.m
//  2048
//
//  Created by Pulkit Goyal on 20/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "UIViewController+MJPopupViewController.h"
#import "SHMenuViewController.h"
#import "UIView+SHAdditions.h"

@interface SHMenuViewController ()

@end

@implementation SHMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}

- (void)setupViews {
    [self styleButton:self.tiltModeButton];
    [self styleButton:self.theNewGameButton];
    [self styleButton:self.closeButton];
    self.closeButton.layer.borderWidth = 1;
}

- (void)styleButton:(UIButton *)button {
    [button sh_addCornerRadius:20];
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    button.layer.borderWidth = 2;
}
- (IBAction)tiltModeClick:(id)sender {
    [self.delegate tiltModeClick];
}
- (IBAction)startNewGameClick:(id)sender {
    [self.delegate startNewGameClick];
}
- (IBAction)closeClick:(id)sender {
    [self.delegate closeClick];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
