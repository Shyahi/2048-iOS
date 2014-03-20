//
// Created on 20/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//


#import "SHFacebookController.h"
#import "FBErrorUtility.h"
#import "FBOpenGraphObject.h"
#import "FBRequestConnection.h"
#import "UIAlertView+BlocksKit.h"
#import "FBLoginView.h"


@interface SHFacebookController ()
@property(nonatomic) FBSessionState facebookSessionState;
@end

@implementation SHFacebookController {

}
- (void)setup {
    // Load the FB Login view.
    [FBLoginView class];
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self facebookSession:session didChangeState:FBSessionStateOpen error:error];
                                      }];
    }
}

- (void)connectWithFacebook {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];

        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self facebookSession:session didChangeState:FBSessionStateOpen error:error];
        }];
    }
}

- (void)updateScoreOnFacebook:(int)score {
    FBSession *activeSession = [FBSession activeSession];
    if (activeSession && (activeSession.state == FBSessionStateOpen || activeSession.state == FBSessionStateOpenTokenExtended)) {
        if ([activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound) {
            // We have share permissions.
            // Create Open graph object
            NSMutableDictionary <FBOpenGraphObject> *scoreObject = [FBGraphObject openGraphObjectForPost];
            scoreObject.provisionedForPost = YES;
            scoreObject[@"score"] = @(score);
            [FBRequestConnection startForPostWithGraphPath:@"me/scores" graphObject:scoreObject completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                DDLogVerbose(@"Posted score. result: %@, error: %@", result, error);
            }];
        }
    }
}

- (BOOL)isFbConnected {
    return FBSession.activeSession.isOpen;
}

- (void)facebookSession:(FBSession *)session didChangeState:(FBSessionState)state error:(NSError *)error {
    self.facebookSessionState = state;
    if (FBSession.activeSession.isOpen && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // Request publish_actions
        [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                DDLogVerbose(@"Publish action request complete. %@, %@", session, error);
                                            }];
        return;
    }
    if (error) {
        DDLogInfo(@"Error connecting to facebook. %@", error);
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error]) {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {

            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                DDLogVerbose(@"User cancelled login");

                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {
        if (self.delegate) {
            [self.delegate facebookController:self didFinishConnectingWithFacebook:session];
        }
    }
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
    [UIAlertView bk_showAlertViewWithTitle:title message:text cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
    }];
}
@end