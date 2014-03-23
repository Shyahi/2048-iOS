//
//  SHGameViewController.m
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHGameViewController.h"
#import "SHGameCellData.h"
#import "SHGameCell.h"
#import "SHGameCellView.h"
#import "Flurry.h"
#import "UIView+SHAdditions.h"
#import "SHFacebookController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SHGameTurn.h"
#import <CoreMotion/CoreMotion.h>

@interface SHGameViewController ()

@property(nonatomic, strong) NSMutableArray *board;
@property(nonatomic) int score;
@property(nonatomic) NSInteger bestScore;
@property(nonatomic) BOOL gameTerminated;
@property(nonatomic) BOOL gameWon;
@property(nonatomic, strong) SHFacebookController *facebookController;
@property(nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic) BOOL tiltEnabled;
@property(nonatomic) NSTimeInterval lastTiltActionTimestamp;
@property(nonatomic, strong) SHMenuViewController *menuViewController;
@property(nonatomic, strong) SHMenuTiltModeViewController *menuTiltViewController;
@property(nonatomic) BOOL gamePaused;

@property(nonatomic, strong) UIViewController *gameCenterLoginController;
@property(nonatomic, strong) SHGameCenterManager *gameCenterManager;
@end

@implementation SHGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UI
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setupViews];
    [self setupFacebook];
    [self initGame];
    [self setupGameCenter];
}

- (void)setup {
    self.tiltEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSHUserDefaultsGameOptionTiltEnabled];
}

- (void)setupViews {
    [self setupCollectionView];
    [self setupScoreViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupMenu];
}

- (void)setupMenu {
    if (IS_IPHONE_5) {
        CGRect frame = self.menuButton.frame;
        frame.origin.y = self.topLayoutGuide.length + 8;
        self.menuButton.frame = frame;
    }
}

- (void)setupScoreViews {
    [self.scoreView sh_addCornerRadius:3];
    [self.bestScoreView sh_addCornerRadius:3];
}

- (void)setupCollectionView {
    [self.collectionView sh_addCornerRadius:5];
}

#pragma mark - Motion
// Creates the device motion manager and starts it updating
// Make sure to only call once.
- (void)setupMotionDetection {
    // Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
    if (self.motionManager == nil) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    self.lastTiltActionTimestamp = [[NSDate date] timeIntervalSince1970];
    [self startDeviceMotionUpdates];
}

- (void)stopMotionDetection {
    [self.motionManager stopDeviceMotionUpdates];
}

// Starts the motionManager updating device motions.
- (void)startDeviceMotionUpdates {
    __weak __typeof (self) weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (error) {
            [weakSelf.motionManager stopDeviceMotionUpdates];
            return;
        }

        [weakSelf deviceMotionDidUpdate:motion];
    }];
}

- (void)moveBoardForRoll:(CGFloat)roll pitch:(CGFloat)pitch {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];

    if (timeStamp - self.lastTiltActionTimestamp > 0.5) {
        if (roll < -0.25) {
            // Left
            [self leftSwipePerformed:nil];
            self.lastTiltActionTimestamp = timeStamp;
        } else if (roll > 0.25) {
            // Right
            [self rightSwipePerformed:nil];
            self.lastTiltActionTimestamp = timeStamp;
        } else if (pitch < -0.05) {
            // Up
            [self upSwipePerformed:nil];
            self.lastTiltActionTimestamp = timeStamp;
        } else if (pitch > 0.75) {
            // Down
            [self downSwipePerformed:nil];
            self.lastTiltActionTimestamp = timeStamp;
        }
    }
}

#pragma mark - Game
- (void)initGame {
    [Flurry logEvent:@"Game_Start"];

    self.score = 0;
    self.gameTerminated = NO;
    self.gameWon = NO;
    self.gamePaused = NO;
    self.bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:kSHBestUserScoreKey];
    [self initBoard];
    [self.collectionView reloadData];
    [self addRandomTile];
    [self addRandomTile];
}

- (void)initBoard {
    self.board = [[NSMutableArray alloc] initWithCapacity:kSHGameBoardSize];
    for (int i = 0; i < kSHGameBoardSize; ++i) {
        NSMutableArray *boardRow = [[NSMutableArray alloc] initWithCapacity:kSHGameBoardSize];
        for (int j = 0; j < kSHGameBoardSize; ++j) {
            [boardRow addObject:[SHGameCellData new]];
        }
        [self.board addObject:boardRow];
    }
}

- (SHGameTurnNewCell *)addRandomTile {
    // Find a random empty cell index.
    NSArray *emptyCellIndices = [self findEmptyCells];
    NSUInteger itemIndex = arc4random_uniform(emptyCellIndices.count);
    NSNumber *cellIndex = emptyCellIndices[itemIndex];
    // Create a new random number.
    NSUInteger row = (NSUInteger) (cellIndex.integerValue / kSHGameBoardSize);
    NSUInteger column = (NSUInteger) (cellIndex.integerValue % kSHGameBoardSize);
    NSNumber *number = (drand48() > 0.9) ? @4 : @2;
    // Add the new tile
    SHGameTurnNewCell *newTile = [SHGameTurnNewCell cellWithPosition:CGPointMake(column, row) number:number];
    [self addTile:newTile];

    return newTile;
}

- (void)addTile:(SHGameTurnNewCell *)cell {
    NSUInteger cellIndex = (NSUInteger) (cell.position.y * kSHGameBoardSize + cell.position.x);
    ((SHGameCellData *) self.board[(NSUInteger) cell.position.y][(NSUInteger) cell.position.x]).number = cell.number;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:cellIndex inSection:0]]];
}

- (NSArray *)findEmptyCells {
    NSMutableArray *emptyCellIndices = [NSMutableArray arrayWithCapacity:(NSUInteger) (kSHGameBoardSize * kSHGameBoardSize)];
    for (int i = 0; i < self.board.count; ++i) {
        NSArray *boardRow = self.board[(NSUInteger) i];
        for (int j = 0; j < boardRow.count; ++j) {
            SHGameCellData *cellData = boardRow[j];
            if (cellData.number == nil) {
                [emptyCellIndices addObject:@(i * kSHGameBoardSize + j)];
            }
        }
    }
    return emptyCellIndices;
}

- (void)moveBoard:(SHMoveDirection)direction {
    if (self.gameTerminated || self.gameWon || self.gamePaused) {
        return;
    }

    if ([GKLocalPlayer localPlayer].authenticated && self.gameCenterManager.currentMatch && ![self.gameCenterManager.currentMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        DDLogVerbose(@"Local player id: %@, Player with turn: %@", [GKLocalPlayer localPlayer].playerID, self.gameCenterManager.currentMatch.currentParticipant.playerID);
        return;
    }

    [self prepareCells];

    NSArray *currentBoard = [self copyBoard];
    BOOL moved = [self animateBoardMoveInDirection:direction];

    if (moved) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (kSHCellAnimationsDuration * 1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didMoveBoard:currentBoard inDirection:direction];
        });
    }
}

- (BOOL)animateBoardMoveInDirection:(SHMoveDirection)direction {
    CGPoint vector = [self getVectorInDirection:direction];
    NSDictionary *traversals = [self buildTraversalsForVector:vector];
    BOOL moved = NO;

    for (NSNumber *x in traversals[@"x"]) {
        for (NSNumber *y in traversals[@"y"]) {
            CGPoint cell = CGPointMake(x.integerValue, y.integerValue);
            SHGameCellData *cellData = [self dataForCellAtPosition:cell];
            // Move cells only if it is not empty.
            if (cellData.number) {
                // Find positions of farthest available and next cells.
                NSDictionary *positions = [self findFarthestPositionOfCell:cell inDirection:vector];
                CGPoint nextCellPosition = [((NSValue *) positions[@"next"]) CGPointValue];
                CGPoint farthestAvailablePosition = [((NSValue *) positions[@"farthest"]) CGPointValue];
                SHGameCellData *nextCellData = [self dataForCellAtPosition:nextCellPosition];

                // Can cells be merged?
                if (!cellData.merged && !nextCellData.merged && nextCellData.number && [nextCellData.number isEqualToNumber:cellData.number]) {
                    // Merge cell and update score.
                    nextCellData = [self mergeCell:cell forPositions:positions];
                    self.score += nextCellData.number.integerValue;
                    // Board was moved;
                    moved = YES;

                    // The mighty 2048 tile
                    if (nextCellData.number.integerValue == kSHGameMaxScore) {
                        self.gameWon = YES;
                    }
                } else if (!(farthestAvailablePosition.x == cell.x && farthestAvailablePosition.y == cell.y)) {
                    [self moveCell:cell toFarthestPosition:positions];
                    // Board was moved;
                    moved = YES;
                }
            }
        }
    }
    return moved;
}

- (void)moveCell:(CGPoint)cell toFarthestPosition:(NSDictionary *)positions {
    // Find positions of farthest available and next cells.
    CGPoint farthestAvailablePosition = [((NSValue *) positions[@"farthest"]) CGPointValue];
    SHGameCellData *cellData = [self dataForCellAtPosition:cell];

    // Find index paths and frame of items.
    NSIndexPath *cellIndexPath = [self indexPathForPosition:cell];
    NSIndexPath *farthestCellIndexPath = [self indexPathForPosition:farthestAvailablePosition];
    CGRect cellRect = [self.collectionView layoutAttributesForItemAtIndexPath:cellIndexPath].frame;
    CGRect farthestCellRect = [self checkBoundsForCell:farthestAvailablePosition] ? [self.collectionView layoutAttributesForItemAtIndexPath:farthestCellIndexPath].frame : CGRectZero;

    // Move current cell to farthest available position.
    SHGameCellData *farthestCellData = [self dataForCellAtPosition:farthestAvailablePosition];
    farthestCellData.number = cellData.number;
    cellData.number = nil;
    [self reloadCollectionViewItemsAtIndexPaths:@[cellIndexPath] completion:^(BOOL b) {
    }];

    // Create view and animate.
    SHGameCellView *cellView = [[SHGameCellView alloc] initWithFrame:cellRect];
    cellView.number = farthestCellData.number;
    [self.gameContainerView addSubview:cellView];

    [UIView animateWithDuration:kSHCellAnimationsDuration animations:^{
        cellView.frame = farthestCellRect;
    }                completion:^(BOOL finished) {
        [self reloadCollectionViewItemsAtIndexPaths:@[farthestCellIndexPath] completion:^(BOOL b) {
            [cellView removeFromSuperview];
        }];
    }];

}

- (SHGameCellData *)mergeCell:(CGPoint)cell forPositions:(NSDictionary *)positions {
    CGPoint nextCellPosition = [((NSValue *) positions[@"next"]) CGPointValue];
    SHGameCellData *nextCellData = [self dataForCellAtPosition:nextCellPosition];
    SHGameCellData *cellData = [self dataForCellAtPosition:cell];

    // Find index paths and frame of items.
    NSIndexPath *cellIndexPath = [self indexPathForPosition:cell];
    NSIndexPath *nextCellIndexPath = [self indexPathForPosition:nextCellPosition];
    CGRect cellRect = [self.collectionView layoutAttributesForItemAtIndexPath:cellIndexPath].frame;
    CGRect nextCellRect = [self checkBoundsForCell:nextCellPosition] ? [self.collectionView layoutAttributesForItemAtIndexPath:nextCellIndexPath].frame : CGRectZero;

    // Create a new view and animate it.
    SHGameCellView *cellView = [[SHGameCellView alloc] initWithFrame:cellRect];
    cellView.number = cellData.number;
    [self.gameContainerView addSubview:cellView];
    [UIView animateWithDuration:kSHCellAnimationsDuration animations:^{
        cellView.frame = nextCellRect;
    }                completion:^(BOOL finished) {
        [self reloadCollectionViewItemsAtIndexPaths:@[nextCellIndexPath] completion:^(BOOL finished) {
            [cellView removeFromSuperview];
        }];
    }];

    // Merge cells.
    nextCellData.number = @(nextCellData.number.integerValue + cellData.number.integerValue);
    nextCellData.merged = YES;
    cellData.number = nil;
    [self reloadCollectionViewItemsAtIndexPaths:@[cellIndexPath] completion:^(BOOL b) {
    }];
    return nextCellData;
}

- (NSArray *)copyBoard {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.board]];
}

- (void)didMoveBoard:(NSArray *)board inDirection:(SHMoveDirection)direction {
    SHGameTurnNewCell *newCell = [self addRandomTile];
    if (![self movesAvailable]) {
        self.gameTerminated = YES;
    }

    // Take turn for multiplayer game.
    [self sendTurn:[SHGameTurn turnWithBoard:board direction:direction newCell:newCell]];
}

- (void)reloadCollectionViewItemsAtIndexPaths:(NSArray *)indexPaths completion:(void (^)(BOOL))completion {
    // Perform collection view updates without animation.
    // http://stackoverflow.com/a/15068865/643109
    [UIView animateWithDuration:0 animations:^{
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }                completion:completion];
}

- (NSIndexPath *)indexPathForPosition:(CGPoint)position {
    return [NSIndexPath indexPathForItem:(NSInteger) (position.y * kSHGameBoardSize + position.x) inSection:0];
}

- (void)prepareCells {
    for (int i = 0; i < self.board.count; ++i) {
        NSArray *boardRow = self.board[(NSUInteger) i];
        for (int j = 0; j < boardRow.count; ++j) {
            SHGameCellData *cellData = boardRow[j];
            cellData.merged = NO;
        }
    }
}

- (SHGameCellData *)dataForCellAtPosition:(CGPoint)position {
    if ([self checkBoundsForCell:position]) {
        return self.board[(NSUInteger) position.y][(NSUInteger) position.x];
    }
    return nil;
}

- (NSDictionary *)findFarthestPositionOfCell:(CGPoint)cell inDirection:(CGPoint)vector {
    CGPoint previous;

    // Progress towards the vector direction until an obstacle is found
    do {
        previous = cell;
        cell = CGPointMake(previous.x + vector.x, previous.y + vector.y);
    } while ([self checkBoundsForCell:cell] && [self checkAvailabilityForCell:cell]);

    return @{
            @"farthest" : [NSValue value:&previous withObjCType:@encode(CGPoint)],
            @"next" : [NSValue value:&cell withObjCType:@encode(CGPoint)] // Used to check if a merge is required
    };

}

- (BOOL)checkBoundsForCell:(CGPoint)point {
    return point.x >= 0 && point.x < kSHGameBoardSize && point.y >= 0 && point.y < kSHGameBoardSize;
}

- (BOOL)checkAvailabilityForCell:(CGPoint)point {
    SHGameCellData *cellData = [self dataForCellAtPosition:point];
    return cellData.number == nil;
}

- (NSDictionary *)buildTraversalsForVector:(CGPoint)vector {
    NSMutableDictionary *traversals = [@{@"x" : [NSMutableArray arrayWithCapacity:kSHGameBoardSize], @"y" : [NSMutableArray arrayWithCapacity:kSHGameBoardSize]} mutableCopy];

    for (int pos = 0; pos < kSHGameBoardSize; ++pos) {
        [traversals[@"x"] addObject:@(pos)];
        [traversals[@"y"] addObject:@(pos)];
    }

    // Always traverse from the farthest cell in the chosen direction
    if (vector.x == 1) traversals[@"x"] = [[((NSMutableArray *) traversals[@"x"]) reverseObjectEnumerator] allObjects];
    if (vector.y == 1) traversals[@"y"] = [[((NSMutableArray *) traversals[@"y"]) reverseObjectEnumerator] allObjects];
    return traversals;

}

- (CGPoint)getVectorInDirection:(SHMoveDirection)direction {
    switch (direction) {
        case kSHMoveDirectionDown:
            return CGPointMake(0, 1);
        case kSHMoveDirectionUp:
            return CGPointMake(0, -1);
        case kSHMoveDirectionLeft:
            return CGPointMake(-1, 0);
        case kSHMoveDirectionRight:
            return CGPointMake(1, 0);
    }
    return CGPointZero;
}

- (BOOL)movesAvailable {
    return [self cellsAvailable] || [self tileMatchesAvailable];
}

- (BOOL)tileMatchesAvailable {
    for (int x = 0; x < kSHGameBoardSize; x++) {
        for (int y = 0; y < kSHGameBoardSize; y++) {
            SHGameCellData *cellData = [self dataForCellAtPosition:CGPointMake(x, y)];
            if (cellData && cellData.number) {
                for (int direction = 0; direction < 4; direction++) {
                    CGPoint vector = [self getVectorInDirection:(SHMoveDirection) direction];
                    CGPoint cell = CGPointMake(x + vector.x, y + vector.y);
                    SHGameCellData *otherData = [self dataForCellAtPosition:cell];
                    if (otherData && otherData.number && [otherData.number isEqualToNumber:cellData.number]) {
                        DDLogVerbose(@"Matching tiles available.");
                        return YES; // These two tiles can be merged
                    }
                }
            }
        }
    }
    DDLogVerbose(@"No matching tile available.");
    return NO;
}

- (BOOL)cellsAvailable {
    for (int x = 0; x < kSHGameBoardSize; x++) {
        for (int y = 0; y < kSHGameBoardSize; y++) {
            SHGameCellData *cellData = [self dataForCellAtPosition:CGPointMake(x, y)];
            if (cellData && cellData.number == nil) {
                DDLogVerbose(@"Cells available.");
                return YES; // This cell is available.
            }
        }
    }
    DDLogVerbose(@"No Cells available.");
    return NO;
}

#pragma mark Collection View Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 16;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHGameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SH_GAME_CELL" forIndexPath:indexPath];
    NSUInteger row = (NSUInteger) (indexPath.item / kSHGameBoardSize);
    NSUInteger column = (NSUInteger) (indexPath.item % kSHGameBoardSize);
    [cell configure:self.board[row][column]];
    return cell;
}

#pragma mark - Storyboard Outlets
- (IBAction)rightSwipePerformed:(id)sender {
    [self moveBoard:kSHMoveDirectionRight];
}

- (IBAction)leftSwipePerformed:(id)sender {
    [self moveBoard:kSHMoveDirectionLeft];
}

- (IBAction)upSwipePerformed:(id)sender {
    [self moveBoard:kSHMoveDirectionUp];
}

- (IBAction)downSwipePerformed:(id)sender {
    [self moveBoard:kSHMoveDirectionDown];
}

- (IBAction)tryAgainClick:(id)sender {
    [Flurry logEvent:@"Game_Try_Again"];
    [self initGame];
}

- (IBAction)shareClick:(id)sender {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *textToShare = [NSString stringWithFormat:@"I scored %d points at 2048! #2048game http://itunes.com/apps/%@ via @2048iOS ", self.score, appName];
    UIImage *imageToShare = [self.collectionView sh_takeSnapshot];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare, imageToShare] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)menuButtonClick:(id)sender {
    if (self.menuViewController == nil) {
        self.menuViewController = [[SHMenuViewController alloc] initWithNibName:@"SHMenuView" bundle:nil];;
        self.menuViewController.delegate = self;
    }
    self.gamePaused = YES;
    [self presentPopupViewController:self.menuViewController animationType:MJPopupViewAnimationSlideTopBottom dismissed:^{
        self.gamePaused = NO;
    }];
}

- (IBAction)multiplayerGameClick:(id)sender {
    [self.gameCenterManager findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

#pragma mark - Setters
- (void)setScore:(int)score {
    _score = score;
    self.scoreLabel.text = [[self scoreFormatter] stringFromNumber:@(score)];
}

- (void)setBestScore:(NSInteger)bestScore {
    _bestScore = bestScore;
    if (bestScore != 0) {
        self.bestScoreLabel.text = [[self scoreFormatter] stringFromNumber:@(bestScore)];
    } else {
        self.bestScoreLabel.text = @"-";
    }
}

- (void)setGameTerminated:(BOOL)gameTerminated {
    _gameTerminated = gameTerminated;

    if (!gameTerminated) {
        self.gameTerminatedView.hidden = YES;
        self.gameTerminatedView.alpha = 1;
    } else {
        // Show the game terminated view.
        self.gameTerminatedView.alpha = 0;
        self.gameTerminatedView.hidden = NO;
        [UIView animateWithDuration:1 animations:^{
            self.gameTerminatedView.alpha = 1;
        }                completion:^(BOOL finished) {

        }];

        // Save score
        [self saveScore];
    }
}

- (void)saveScore {
    // Save best score.
    NSInteger currentBest = [[NSUserDefaults standardUserDefaults] integerForKey:kSHBestUserScoreKey];
    if (currentBest < self.score) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:kSHBestUserScoreKey];
    }

    [self.facebookController updateScoreOnFacebook:self.score];
}

- (void)setGameWon:(BOOL)gameWon {
    _gameWon = gameWon;

    if (!gameWon) {
        self.gameWonView.hidden = YES;
        self.gameWonView.alpha = 1;
    } else {
        [Flurry logEvent:@"Game_Won"];
        // Show the game terminated view.
        self.gameWonView.alpha = 0;
        self.gameWonView.hidden = NO;
        [UIView animateWithDuration:1 animations:^{
            self.gameWonView.alpha = 1;
        }                completion:^(BOOL finished) {

        }];

        [self saveScore];
    }
}

- (void)setTiltEnabled:(BOOL)tiltEnabled {
    _tiltEnabled = tiltEnabled;
    if (tiltEnabled) {
        [self setupMotionDetection];
    } else {
        [self stopMotionDetection];
    }
    [[NSUserDefaults standardUserDefaults] setBool:tiltEnabled forKey:kSHUserDefaultsGameOptionTiltEnabled];
}

#pragma mark - Facebook
- (void)setupFacebook {
    self.facebookController = [[SHFacebookController alloc] init];
    [self.facebookController setup];
}

#pragma mark - Constants
- (NSNumberFormatter *)scoreFormatter {
    static NSNumberFormatter *formatter;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return formatter;
}

#pragma mark - Core Motion Methods

- (void)deviceMotionDidUpdate:(CMDeviceMotion *)deviceMotion {
    // Called when the deviceMotion property of our CMMotionManger updates.
    // Recalculates the gradient locations.

    // We need to account for the interface's orientation when calculating the relative roll.
    CGFloat roll = 0.0f;
    CGFloat pitch = 0.0f;
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
            roll = deviceMotion.attitude.roll;
            pitch = deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            roll = -deviceMotion.attitude.roll;
            pitch = -deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            roll = -deviceMotion.attitude.pitch;
            pitch = -deviceMotion.attitude.roll;
            break;
        case UIInterfaceOrientationLandscapeRight:
            roll = deviceMotion.attitude.pitch;
            pitch = deviceMotion.attitude.roll;
            break;
    }
    // Update the image with the calculated values.
    [self moveBoardForRoll:roll pitch:pitch];
}

#pragma mark - Menu Delegate
- (void)tiltModeClick {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
    if (self.menuTiltViewController == nil) {
        self.menuTiltViewController = [[SHMenuTiltModeViewController alloc] initWithNibName:@"SHMenuTiltModeViewController" bundle:nil];;
        self.menuTiltViewController.delegate = self;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.gamePaused = YES;
        [self presentPopupViewController:self.menuTiltViewController animationType:MJPopupViewAnimationSlideTopBottom dismissed:^{
            self.gamePaused = NO;
        }];
    });

}

- (void)startNewGameClick {
    [self saveScore];
    [self initGame];
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

- (void)closeClick {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

- (void)gameCenterLoginClick {
    if (![GKLocalPlayer localPlayer].authenticated && self.gameCenterLoginController != nil) {
        [self presentViewController:self.gameCenterLoginController animated:YES completion:nil];
    }
}

#pragma mark - Menu Tilt Mode Delegate
- (void)enableTiltClick {
    self.tiltEnabled = YES;
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

- (void)disableTiltClick {
    self.tiltEnabled = NO;
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Multiplayer
- (void)sendTurn:(SHGameTurn *)turn {
    GKTurnBasedMatch *currentMatch = self.gameCenterManager.currentMatch;
    if ([currentMatch.currentParticipant.playerID isEqual:[GKLocalPlayer localPlayer].playerID]) {
        // Create the game data to send.
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:turn];
        // Find the next participant
        NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
        GKTurnBasedParticipant *nextParticipant;
        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count])];
        // End current turn with next participant.
        [currentMatch endTurnWithNextParticipants:@[nextParticipant, currentMatch.currentParticipant] turnTimeout:60 * 60 * 2 matchData:data completionHandler:^(NSError *error) {
            if (error) {
                DDLogWarn(@"Error in ending current turn %@", error);
            } else {
                [self updateStatusLabelForMatch:currentMatch participant:nextParticipant];

            }
        }];
        DDLogVerbose(@"Send Turn %@", nextParticipant);
    } else {
        DDLogWarn(@"Trying to send turn when not the current participant.");
    }
}

- (void)updateStatusLabelForMatch:(GKTurnBasedMatch *)match participant:(GKTurnBasedParticipant *)participant {
    if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        self.statusLabel.text = @"Your turn";
    } else {
        int playerNum = [match.participants indexOfObject:match.currentParticipant] + 1;
        self.statusLabel.text = [NSString stringWithFormat:@"Player %d's Turn", playerNum];
    }
}

- (void)setupGameCenter {
    [[GameCenterManager sharedManager] setDelegate:self];
    self.gameCenterManager = [SHGameCenterManager new];
    self.gameCenterManager.delegate = self;
    [[GKLocalPlayer localPlayer] registerListener:self.gameCenterManager];
}
#pragma mark Game Center Manager Delegate
- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    self.gameCenterLoginController = gameCenterLoginController;
}

#pragma mark SH Game Center Manager Delegate
- (void)enterNewGame:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Entering new multiplayer game...");
    [self initGame];
}

- (void)layoutMatch:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Update match layout.");

    if (match.status == GKTurnBasedMatchStatusEnded) {
        self.statusLabel.text = @"Match Ended";
    } else {
        [self updateStatusLabelForMatch:match participant:match.currentParticipant];
    }

    // Update board layout.
    if ([match.matchData bytes]) {
        SHGameTurn *turn = [NSKeyedUnarchiver unarchiveObjectWithData:match.matchData];
        self.board = [turn.board mutableCopy];
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        [self animateBoardMoveInDirection:turn.boardMoveDirection];
        [self addTile:turn.theNewCell];
    }
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match {

}

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
