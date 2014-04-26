//
//  SHMoreViewController.m
//  2048
//
//  Created on 25/04/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <Analytics/Analytics.h>
#import "SHMoreViewController.h"

@interface SHMoreViewController ()

@end

@implementation SHMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[Analytics sharedAnalytics] screen:@"More Screen" properties:nil];
}

#pragma mark - Storyboard outlets
- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
