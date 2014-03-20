//
//  SHMenuTiltModeViewController.m
//  2048
//
//  Created by Pulkit Goyal on 20/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHMenuTiltModeViewController.h"
#import "UIView+SHAdditions.h"

@interface SHMenuTiltModeViewController ()

@end

@implementation SHMenuTiltModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self stupViews];
}

- (void)stupViews {
    [self styleButton:self.enableTiltButton];
    [self styleButton:self.disableTiltButton];
}

- (void)styleButton:(UIButton *)button {
    [button sh_addCornerRadius:20];
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    button.layer.borderWidth = 2;
}

- (IBAction)enableTiltClick:(id)sender {
    [self.delegate enableTiltClick];
}

- (IBAction)disableTiltClick:(id)sender {
    [self.delegate disableTiltClick];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
