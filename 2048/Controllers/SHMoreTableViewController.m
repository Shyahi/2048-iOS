//
//  SHMoreTableViewController.m
//  2048
//
//  Created on 25/04/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <GameKit/GameKit.h>
#import <MessageUI/MessageUI.h>
#import "SHMoreTableViewController.h"
#import "MFMailComposeViewController+BlocksKit.h"

@interface SHMoreTableViewController ()
@property(strong, nonatomic) IBOutlet UITableViewCell *leaderboardsCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *sendFriendRequestCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *tellAFriendCell;
@property(strong, nonatomic) IBOutlet UITableViewCell *sendFeedbackCell;

@end

@implementation SHMoreTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath];
    if (theCellClicked == self.leaderboardsCell) {
        [self onLeaderboardsClick];
    } else if (theCellClicked == self.sendFriendRequestCell) {
        [self sendFriendRequest];
    } else if (theCellClicked == self.tellAFriendCell) {
        [self tellAFriend];
    } else if (theCellClicked == self.sendFeedbackCell) {
        [self sendFeedback];
    }
}

- (void)sendFeedback {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        composeViewController.bk_completionBlock = ^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        [composeViewController setToRecipients:@[@"2048@shyahi.com"]];
        [composeViewController setSubject:@"Feedback for 2048 iOS App"];
        [self presentViewController:composeViewController animated:YES completion:nil];
    } else {
        // Open website
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://2048.shyahi.com"]];
    }
}

- (void)tellAFriend {
    NSString *textToShare = [NSString stringWithFormat:@"Check out multiplayer #2048game on iPhone. http://bit.ly/2048iOS"];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)sendFriendRequest {
    GKFriendRequestComposeViewController *friendRequestViewController = [[GKFriendRequestComposeViewController alloc] init];
    [self presentViewController:friendRequestViewController animated:YES completion:nil];
}

- (void)onLeaderboardsClick {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil) {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        [self presentViewController:gameCenterController animated:YES completion:nil];
    }

}

#pragma mark - Game Center Delegate
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
