//
//  SHMultiplayerHeaderView.m
//  2048
//
//  Created by Pulkit Goyal on 24/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "SHMultiplayerHeaderView.h"
#import "SHGameTurn.h"
#import "SHHelpers.h"

@interface SHMultiplayerHeaderView ()
@property(nonatomic, strong) GKTurnBasedMatch *match;
@end

@implementation SHMultiplayerHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"SHMultiplayerHeaderView" owner:self options:nil] objectAtIndex:0]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}

- (void)setupViews {
    [self setupPlayerImageView:self.player1ImageView borderColor:[UIColor blueColor]];
    [self setupPlayerImageView:self.player2ImageView borderColor:[UIColor redColor]];
}

- (void)setupPlayerImageView:(UIImageView *)imageView borderColor:(UIColor *)color {
    imageView.layer.cornerRadius = imageView.frame.size.height / 2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 5;
    imageView.layer.borderColor = color.CGColor;

    // TODO Set placeholder images for players
}

- (void)setMatch:(GKTurnBasedMatch *)match turn:(SHGameTurn *)turn {

    // Update player images
    if ([self.match.matchID isEqual:match.matchID] && [self.match.participants isEqualToArray:match.participants]) {
        // We already have info for all players in this match.
    } else {
        // TODO Set placeholder images for players

        // Update player images.
        NSMutableArray *playerIds = [[NSMutableArray alloc] initWithCapacity:match.participants.count];
        for (GKTurnBasedParticipant *participant in match.participants) {
            if (participant && participant.playerID && participant.playerID != (id) [NSNull null]) {
                [playerIds addObject:participant.playerID];
            }
        }
        [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray *players, NSError *error) {
            if (error) {
                DDLogWarn(@"Unable to load player info from id. %@", error);
                return;
            }
            if (players.count >= 1) {
                [self updatePhotoForPlayer:players[0] inView:self.player1ImageView];
                if (players.count >= 2) {
                    [self updatePhotoForPlayer:players[1] inView:self.player2ImageView];
                }
            }
        }];
    }
    // Update scores
    if (match.participants.count >= 1) {
        [self updateScoreForParticipant:match.participants[0] turn:turn label:self.player1ScoreLabel];
        if (match.participants.count >= 2) {
            [self updateScoreForParticipant:match.participants[1] turn:turn label:self.player2ScoreLabel];
        }
    }

    self.match = match;
}

- (void)updateScoreForParticipant:(GKTurnBasedParticipant *)participant turn:(SHGameTurn *)turn label:(UILabel *)label {
    NSNumber *score = turn.scores[participant.playerID];
    if (score) {
        label.text = [[SHHelpers scoreFormatter] stringFromNumber:score];
    } else {
        label.text = [[SHHelpers scoreFormatter] stringFromNumber:@0];
    }
}

- (void)updatePhotoForPlayer:(GKPlayer *)player inView:(UIImageView *)imageView {
    [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (photo != nil) {
            [imageView setImage:photo];
        }
        if (error) {
            DDLogWarn(@"Unable to load player photo. %@", error);
        }
    }];
}
@end
