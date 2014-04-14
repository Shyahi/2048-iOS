//
//  SHMultiplayerHeaderView.m
//  2048
//
//  Created by Pulkit Goyal on 24/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <GameKit/GameKit.h>
#import <HexColors/HexColor.h>
#import "SHMultiplayerHeaderView.h"
#import "SHGameTurn.h"
#import "SHHelpers.h"
#import "SHTriangleView.h"

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
    [self setupPlayerImageView:self.player1ImageView borderColor:[UIColor colorWithHexString:@"#232323"]];
    [self setupPlayerImageView:self.player2ImageView borderColor:[UIColor colorWithHexString:@"#FB0209"]];
}

- (void)setupPlayerImageView:(UIImageView *)imageView borderColor:(UIColor *)color {
    imageView.layer.cornerRadius = 25;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 5;
    imageView.layer.borderColor = color.CGColor;
}

- (void)setMatch:(GKTurnBasedMatch *)match turn:(SHGameTurn *)turn currentParticipant:(GKTurnBasedParticipant *)currentParticipant{

    // Update player images
    if ([self.match.matchID isEqual:match.matchID] && [self.match.participants isEqualToArray:match.participants]) {
        // We already have info for all players in this match.
    } else {
        // Update player images.
        NSMutableArray *playerIds = [[NSMutableArray alloc] initWithCapacity:match.participants.count];
        for (GKTurnBasedParticipant *participant in match.participants) {
            if (participant && participant.playerID && participant.playerID != (id) [NSNull null]) {
                [playerIds addObject:participant.playerID];
            }
        }

        // Set placeholder images.
        [self.player1ImageView setImage:[UIImage imageNamed:[[SHMultiplayerHeaderView placeholderImageNames] objectAtIndex:0]]];
        [self.player2ImageView setImage:[UIImage imageNamed:[[SHMultiplayerHeaderView placeholderImageNames] objectAtIndex:1]]];

        // Load actual player images.
        [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray *players, NSError *error) {
            if (error) {
                DDLogWarn(@"Unable to load player info from id. %@", error);
                return;
            }
            [self updatePhotoForPlayers:players index:0 inView:self.player1ImageView];
            [self updatePhotoForPlayers:players index:1 inView:self.player2ImageView];
        }];
    }
    // Update scores
    if (match.participants.count >= 1) {
        [self updateScoreForParticipant:match.participants[0] turn:turn label:self.player1ScoreLabel];
        if (match.participants.count >= 2) {
            [self updateScoreForParticipant:match.participants[1] turn:turn label:self.player2ScoreLabel];
        }
    }

    // Update turn indicators
    [self updateTurnIndicatorsForMatch:match participant:currentParticipant];

    self.match = match;
}

- (void)updateTurnIndicatorsForMatch:(GKTurnBasedMatch *)match participant:(GKTurnBasedParticipant *)participant{
    if (match.participants.count >= 1) {
        self.player1TurnIndicatorView.hidden = ![participant isEqual:match.participants[0]];
        if (match.participants.count >= 2) {
            self.player2TurnIndicatorView.hidden = ![participant isEqual:match.participants[1]];
        }
    }
}

- (void)updateScoreForParticipant:(GKTurnBasedParticipant *)participant turn:(SHGameTurn *)turn label:(UILabel *)label {
    NSNumber *score = turn.scores[participant.playerID];
    if (score) {
        label.text = [[SHHelpers scoreFormatter] stringFromNumber:score];
    } else {
        label.text = [[SHHelpers scoreFormatter] stringFromNumber:@0];
    }
}

- (void)updatePhotoForPlayers:(NSArray *)players index:(NSUInteger)index inView:(UIImageView *)imageView {
    // Load photo
    if (players.count > index) {
        GKPlayer *player = players[index];
        [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
            if (photo != nil) {
                [imageView setImage:photo];
            }
            if (error) {
                DDLogWarn(@"Unable to load player photo. %@", error);
            }
        }];
    }

}

+ (NSArray *)placeholderImageNames {
    static dispatch_once_t once;
    static NSArray *placeholderImageNames;
    dispatch_once(&once, ^{
        placeholderImageNames = @[@"batman", @"ironman"];
    });
    return placeholderImageNames;
}
@end
