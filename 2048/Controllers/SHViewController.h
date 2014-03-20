//
//  SHViewController.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EAIntroView/EAIntroView.h>
#import "SHFacebookIntroView.h"
#import "SHFacebookController.h"

@class SHFacebookController;

@interface SHViewController : UIViewController <EAIntroDelegate, SHFacebookIntroDelegate>

@end
