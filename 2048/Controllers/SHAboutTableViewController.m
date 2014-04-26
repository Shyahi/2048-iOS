//
//  SHAboutTableViewController.m
//  2048
//
//  Created by Pulkit Goyal on 26/04/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHAboutTableViewController.h"
#import "iRate.h"

@interface SHAboutTableViewController ()
@property(strong, nonatomic) IBOutlet UITableViewCell *websiteCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *twitterCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *facebookCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *blogCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *appStoreCell;

@end

@implementation SHAboutTableViewController

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.websiteCell) {
        [self openUrl:@"http://2048.shyahi.com"];
    } else if (theCellClicked == self.twitterCell) {
        [self openUrl:@"https://twitter.com/2048iOS"];
    } else if (theCellClicked == self.facebookCell) {
        [self openUrl:@"https://www.facebook.com/2048iOS"];
    } else if (theCellClicked == self.blogCell) {
        [self openUrl:@"http://blog.shyahi.com"];
    } else if (theCellClicked == self.appStoreCell) {
        [[iRate sharedInstance] openRatingsPageInAppStore];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)openUrl:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
