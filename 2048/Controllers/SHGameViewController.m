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
#import "UIView+SHAdditions.h"
#import "SHFacebookController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SHGameTurn.h"
#import <CoreMotion/CoreMotion.h>
#import <KVOController/FBKVOController.h>
#import <Analytics/Analytics.h>
#import "UIAlertView+BlocksKit.h"
#import "SHMultiplayerHeaderView.h"
#import "UIView+AutoLayout.h"
#import "SHHelpers.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

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

@property(nonatomic, strong) SHGameCenterManager *gameCenterManager;
@property(nonatomic, strong) NSMutableDictionary *turnsForMatch;
@property(nonatomic, strong) FBKVOController *kvoController;

// Storyboard outlets
@property(strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong, nonatomic) IBOutlet UIView *gameContainerView;
@property(strong, nonatomic) IBOutlet UIView *scoreView;
@property(strong, nonatomic) IBOutlet UIView *bestScoreView;
@property(strong, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property(strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property(strong, nonatomic) IBOutlet UIView *gameTerminatedView;
@property(strong, nonatomic) IBOutlet UIView *gameWonView;
@property(strong, nonatomic) IBOutlet UILabel *gameWonLabel;
@property(strong, nonatomic) IBOutlet UIButton *menuButton;
@property(strong, nonatomic) IBOutlet SHMultiplayerHeaderView *multiplayerHeaderView;
@property(strong, nonatomic) IBOutlet UIView *singleplayerHeaderView;
@property(strong, nonatomic) IBOutlet UIView *gameContentView;
@property(strong, nonatomic) IBOutlet UIView *multiplayerConnectView;
@property(strong, nonatomic) IBOutlet UIView *multiplayerLoginCompleteView;
@property(strong, nonatomic) IBOutlet UIView *multiplayerLoginActivityView;
@property(strong, nonatomic) IBOutlet UIButton *gameCenterButton;
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
}

- (void)setup {
    self.tiltEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSHUserDefaultsGameOptionTiltEnabled];

    [self setupViews];
    [self setupFacebook];
    [self initGameCreateBoard:!self.isMultiplayer];
    [self setupGameCenter];
}

- (void)setupViews {
    [self setupCollectionView];
    [self setupScoreViews];
    [self setupMultiplayerViews];
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

- (void)setupMultiplayerViews {
    self.gameCenterButton.hidden = !self.isMultiplayer;
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
- (void)initGameCreateBoard:(BOOL)createBoard {
    [[Analytics sharedAnalytics] track:@"Game_Start" properties:nil];
    // Initialize defaults
    self.score = 0;
    self.gameTerminated = NO;
    self.gameWon = NO;
    self.gamePaused = NO;
    self.bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:kSHBestUserScoreKey];
    // Create board
    if (createBoard) {
        [self createGameBoard];
    }
}

- (void)createGameBoard {
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
            SHGameCellData *cellData = boardRow[(NSUInteger) j];
            if (cellData.number == nil) {
                [emptyCellIndices addObject:@(i * kSHGameBoardSize + j)];
            }
        }
    }
    return emptyCellIndices;
}

- (void)moveBoard:(SHMoveDirection)direction {
    if (self.gameTerminated || self.gameWon || self.gamePaused || ![self multiplayerModeValid]) {
        return;
    }

    if (self.isMultiplayer && ![self isCurrentPlayersTurn]) {
        [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, self.view.bounds.size.height / 2 - 24)];
        [[SVProgressHUD appearance] setHudFont:[UIFont fontWithName:@"AvenirNext" size:16]];
        [SVProgressHUD showImage:nil status:@"Be patient! Not your turn"];
        return;
    }

    [self prepareCells];

    NSArray *currentBoard = [self copyBoard];

    // Move the board and update score.
    SHBoardMoveResult *boardMoveResult = [self animateBoardMoveInDirection:direction];
    self.score += boardMoveResult.score;

    if (boardMoveResult.moved) {
        // Board was moved.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (kSHCellAnimationsDuration * 1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self didMoveBoard:currentBoard inDirection:direction];
        });
    }
}

- (SHBoardMoveResult *)animateBoardMoveInDirection:(SHMoveDirection)direction {
    CGPoint vector = [self getVectorInDirection:direction];
    NSDictionary *traversals = [self buildTraversalsForVector:vector];
    BOOL moved = NO;
    int score = 0;
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
                    score += nextCellData.number.integerValue;
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
    return [SHBoardMoveResult resultWithScore:score moved:moved];
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
        [self reloadCollectionViewItemsAtIndexPaths:@[nextCellIndexPath] completion:^(BOOL reloadFinished) {
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
            SHGameCellData *cellData = boardRow[(NSUInteger) j];
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
    [[Analytics sharedAnalytics] track:@"Game_Try_Again" properties:nil];
    if (self.isMultiplayer) {
        // Open multiplayer game selection
        [self startMultiplayerMatch];
    } else {
        // Start new single player game
        [self initGameCreateBoard:YES];
    }
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

- (IBAction)multiplayerLoginClick:(id)sender {
    [self loginToGameCenter];
}

- (IBAction)multiplayerPlayClick:(id)sender {
    [self startMultiplayerMatch];
}

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gameCenterButtonClick:(id)sender {
    [self startMultiplayerMatch];
}

#pragma mark - Setters
- (void)setScore:(int)score {
    _score = score;
    self.scoreLabel.text = [[SHHelpers scoreFormatter] stringFromNumber:@(score)];

    // Update best score if current score is better
    if (_score > self.bestScore) {
        self.bestScore = _score;
    }
}

- (void)setBestScore:(NSInteger)bestScore {
    _bestScore = bestScore;
    if (bestScore != 0) {
        self.bestScoreLabel.text = [[SHHelpers scoreFormatter] stringFromNumber:@(self.bestScore)];
    } else {
        self.bestScoreLabel.text = @"-";
    }

    // Save score
    [self saveScore];
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
        [self saveScoreAndPublish];
    }
}

- (void)saveScore {
    // Save best score.
    NSInteger currentBest = [[NSUserDefaults standardUserDefaults] integerForKey:kSHBestUserScoreKey];
    if (currentBest < self.score) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:kSHBestUserScoreKey];
    }
}

- (void)publishScore {
    // Send score to facebook
    [self.facebookController updateScoreOnFacebook:self.score];

    if (!self.isMultiplayer) {
        // Send score to Game Center singleplayer leaderboards
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.shyahi.2048.singleplayer"];
        score.value = self.score;
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error) {
                DDLogWarn(@"Error when reporting score to game center. %@", error);
            }
        }];
    }
}

- (void)saveScoreAndPublish {
    [self saveScore];
    [self publishScore];

}


- (void)setGameWon:(BOOL)gameWon {
    _gameWon = gameWon;

    if (!gameWon) {
        self.gameWonView.hidden = YES;
        self.gameWonView.alpha = 1;
    } else {
        [[Analytics sharedAnalytics] track:@"Game_Won" properties:nil];

        // Show the game terminated view.
        self.gameWonView.alpha = 0;
        self.gameWonView.hidden = NO;
        if (!self.isMultiplayer) {
            self.gameWonLabel.text = @"You win!";
        }
        [UIView animateWithDuration:1 animations:^{
            self.gameWonView.alpha = 1;
        }                completion:^(BOOL finished) {

        }];

        [self saveScoreAndPublish];
    }
}

- (void)setTiltEnabled:(BOOL)tiltEnabled {
    _tiltEnabled = tiltEnabled;
    if (tiltEnabled) {
        [self setupMotionDetection];
    } else {
        [self stopMotionDetection];
    }
    [[NSUserDefaults standardUserDefaults] setBool:self.tiltEnabled forKey:kSHUserDefaultsGameOptionTiltEnabled];
}

#pragma mark - Facebook
- (void)setupFacebook {
    self.facebookController = [[SHFacebookController alloc] init];
    [self.facebookController setup];
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
            roll = (CGFloat) deviceMotion.attitude.roll;
            pitch = (CGFloat) deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            roll = (CGFloat) -deviceMotion.attitude.roll;
            pitch = (CGFloat) -deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            roll = (CGFloat) -deviceMotion.attitude.pitch;
            pitch = (CGFloat) -deviceMotion.attitude.roll;
            break;
        case UIInterfaceOrientationLandscapeRight:
            roll = (CGFloat) deviceMotion.attitude.pitch;
            pitch = (CGFloat) deviceMotion.attitude.roll;
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
    if (self.isMultiplayer) {
        // Start new multiplyer game
        [self startMultiplayerMatch];
    } else {
        // Start a new single player game.
        [self saveScoreAndPublish];
        [self initGameCreateBoard:YES ];
    }
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

- (void)closeClick {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideTopBottom];
}

- (void)loginToGameCenter {
    if (![GKLocalPlayer localPlayer].authenticated) {
        if (self.gameCenterManager.gameCenterLoginController != nil) {
            [self presentViewController:self.gameCenterManager.gameCenterLoginController animated:YES completion:nil];
        } else if (self.gameCenterManager.gameCenterLoginError != nil) {
            if (self.gameCenterManager.gameCenterLoginError.code == 2) {
                // User has cancelled login several times and needs to logout and login to Game Center app to re enable.
                // https://sprint.ly/product/19603/#!/item/13
                [UIAlertView bk_showAlertViewWithTitle:@"Cannot login to Game Center" message:@"There was a problem logging into Game Center. Please log out and log in again from the GameCenter app to enable multiplayer mode" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
            } else {
                [UIAlertView bk_showAlertViewWithTitle:@"Cannot login to Game Center" message:@"There was a problem logging into Game Center. Please contact us (2048@shyahi.com) if this problem persists." cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
            }
        } else {
            [self.gameCenterManager authenticateLocalPlayer];
            self.multiplayerLoginActivityView.hidden = NO;
        }
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
        // Update scores
        [self updateScoresForMatch:currentMatch turn:turn];

        // Create the game data to send.
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:turn];

        if (self.gameTerminated || self.gameWon) {
            // End the match.
            [self endMultiplayerMatch:currentMatch withTurn:turn data:data];
        } else {
            // Play turn
            [self continueMultiplayerMatch:currentMatch withTurn:turn data:data];
        }
    } else {
        DDLogWarn(@"Trying to send turn when not the current participant.");
    }
}

- (void)updateScoresForMatch:(GKTurnBasedMatch *)currentMatch turn:(SHGameTurn *)turn {
    // Update the scores in turn.
    if ([self.turnsForMatch objectForKey:currentMatch.matchID]) {
        SHGameTurn *lastTurn = [self.turnsForMatch objectForKey:currentMatch.matchID];
        turn.scores = lastTurn.scores;
    }
    [turn.scores setObject:@(self.score) forKey:[GKLocalPlayer localPlayer].playerID];
}

- (void)continueMultiplayerMatch:(GKTurnBasedMatch *)currentMatch withTurn:(SHGameTurn *)turn data:(NSData *)data {
    // Find the next participant
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count])];
    // End current turn with next participant.
    [currentMatch endTurnWithNextParticipants:@[nextParticipant, currentMatch.currentParticipant] turnTimeout:GKTurnTimeoutDefault matchData:data completionHandler:^(NSError *error) {
        if (error) {
            DDLogWarn(@"Error in ending current turn %@", error);
            [UIAlertView bk_showAlertViewWithTitle:@"Error" message:@"There was an error playing your turn" cancelButtonTitle:@"End Game" otherButtonTitles:@[@"Try Again"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    // Resign.
                    [self endMultiplayerMatch:currentMatch withTurn:turn data:data];
                } else if (buttonIndex == 1) {
                    // Try again.
                    [self continueMultiplayerMatch:currentMatch withTurn:turn data:data];
                }
            }];
        } else {
            [self didEndTurn:turn withMatch:currentMatch nextParticipant:nextParticipant];

        }
    }];
    DDLogVerbose(@"Send Turn %@", nextParticipant);
}

- (void)didEndTurn:(SHGameTurn *)turn withMatch:(GKTurnBasedMatch *)match nextParticipant:(GKTurnBasedParticipant *)participant {
    [self updateStatusForMatch:match participant:participant];
    [self.multiplayerHeaderView setMatch:match turn:turn currentParticipant:participant];
}

- (void)endMultiplayerMatch:(GKTurnBasedMatch *)currentMatch withTurn:(SHGameTurn *)turn data:(NSData *)data {
    // Set the status and outcome for each active participant.
    for (GKTurnBasedParticipant *participant in currentMatch.participants) {
        if (participant.status == GKTurnBasedParticipantStatusActive) {
            participant.matchOutcome = [self outcomeForParticipant:participant scores:turn.scores];
            DDLogVerbose(@"Match outcome for participant %@: %d", participant, participant.matchOutcome);
        }
    }

    // Determine the scores and achievements earned for all players
    NSArray *scores = [self multiplayerScoresForTurn:turn];
    // End the match and report scores and achievements
    [currentMatch endMatchInTurnWithMatchData:data scores:scores achievements:nil completionHandler:^(NSError *error) {
        if (error) {
            DDLogWarn(@"Cannot end multiplayer match. %@", error);
            [UIAlertView bk_showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Try Again"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    // Cancel.
                } else if (buttonIndex == 1) {
                    // Try again.
                    [self endMultiplayerMatch:currentMatch withTurn:turn data:data];
                }
            }];
        } else {
            DDLogVerbose(@"Ended multiplayer match %@", currentMatch.matchID);
        }
    }];
    [self didEndTurn:turn withMatch:currentMatch nextParticipant:nil];
}

- (GKTurnBasedMatchOutcome)outcomeForParticipant:(GKTurnBasedParticipant *)participant scores:(NSMutableDictionary *)scores {
    // Find the max score
    int maxScore = -1;
    for (NSString *playerId in scores.allKeys) {
        int score = [((NSNumber *) scores[playerId]) integerValue];
        DDLogVerbose(@"Player %@, score %d", playerId, score);
        if (maxScore < score) {
            maxScore = score;
        } else if (maxScore == score) {
            return GKTurnBasedMatchOutcomeTied;
        }
    }

    // Find if the participant won or lost.
    if ([((NSNumber *) scores[participant.playerID]) integerValue] == maxScore) {
        return GKTurnBasedMatchOutcomeWon;
    }
    return GKTurnBasedMatchOutcomeLost;
}

- (NSArray *)multiplayerScoresForTurn:(SHGameTurn *)turn {
    NSMutableArray *scores = [[NSMutableArray alloc] initWithCapacity:turn.scores.count];
    for (NSString *playerID in turn.scores) {
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.shyahi.2048.multiplayer" forPlayer:playerID];
        score.value = ((NSNumber *) turn.scores[playerID]).integerValue;
    }
    return scores;
}

- (void)updateStatusForMatch:(GKTurnBasedMatch *)match participant:(GKTurnBasedParticipant *)participant {
    if (match.status == GKTurnBasedMatchStatusEnded) {
        // Match won
        self.gameWon = YES;

        // Find the winner.
        for (GKTurnBasedParticipant *matchParticipant in match.participants) {
            if ([matchParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                switch (matchParticipant.matchOutcome) {
                    case GKTurnBasedMatchOutcomeWon:
                        self.gameWonLabel.text = @"You win!";
                        break;
                    case GKTurnBasedMatchOutcomeLost:
                        self.gameWonLabel.text = @"You lose!";
                        break;
                    case GKTurnBasedMatchOutcomeTied:
                        self.gameWonLabel.text = @"Match tied!";
                        break;
                    default:
                        self.gameWonLabel.text = @"Match over!";
                        break;
                }
                break;
            }
        }
    }
}

- (void)setupGameCenter {
    self.turnsForMatch = [[NSMutableDictionary alloc] init];

    // Initialize the game center manager
    self.gameCenterManager = [SHGameCenterManager sharedManager];
    self.gameCenterManager.delegate = self;

    // Check if we need to authenticate player.
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        [self gameCenterManager:self.gameCenterManager didAuthenticatePlayer:[GKLocalPlayer localPlayer]];
    } else if (self.gameCenterManager.gameCenterLoginController) {
        [self gameCenterManager:self.gameCenterManager authenticateUser:self.gameCenterManager.gameCenterLoginController];
    }

    // Set up observers for current match.
    self.kvoController = [FBKVOController controllerWithObserver:self];
    [self.kvoController observe:self.gameCenterManager keyPath:@"currentMatch" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(SHGameViewController *controller, SHGameCenterManager *gameCenterManager, NSDictionary *change) {
        [self gameCenterManager:gameCenterManager currentMatchDidChange:gameCenterManager.currentMatch controller:controller];
    }];

    // Set up observer for player's authentication state
    [self.kvoController observe:[GKLocalPlayer localPlayer] keyPath:@"isAuthenticated" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(SHGameViewController *controller, GKLocalPlayer *localPlayer, NSDictionary *change) {
        [self localPlayer:localPlayer authenticationDidChange:controller];
    }];

    [self setupReachability];
}

- (void)setupReachability {
    // Allocate a reachability object
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    reach.unreachableBlock = ^(Reachability *reach) {
        // Unreachable
        if (self.isMultiplayer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView bk_showAlertViewWithTitle:@"You are offline" message:@"You must be connected to the internet to play a multiplayer game" cancelButtonTitle:@"Go Back" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            });
        }
    };

    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];

}

- (void)localPlayer:(GKLocalPlayer *)localPlayer authenticationDidChange:(SHGameViewController *)controller {
    if (localPlayer.isAuthenticated) {
        // Hide activity view and show login complete view
        self.multiplayerLoginActivityView.hidden = YES;
        controller.multiplayerLoginCompleteView.hidden = NO;
    } else {
        // Don't show the activity view if we have the login controller or there is some error
        if (self.gameCenterManager.gameCenterLoginController || self.gameCenterManager.gameCenterLoginError) {
            self.multiplayerLoginActivityView.hidden = YES;
        } else {
            self.multiplayerLoginActivityView.hidden = NO;
        }

        // Hide the login complete view
        controller.multiplayerLoginCompleteView.hidden = YES;
    }
}

- (void)gameCenterManager:(SHGameCenterManager *)manager currentMatchDidChange:(GKTurnBasedMatch *)currentMatch controller:(SHGameViewController *)controller {
    if (!self.isMultiplayer || currentMatch == nil) {
        // Show the multiplayer game selection if it is in multiplayer mode.
        if (self.isMultiplayer) {
            self.multiplayerConnectView.hidden = NO;
        }

        // Single player match.
        if (controller.singleplayerHeaderView.superview == nil) {
            [controller.gameContentView addSubview:controller.singleplayerHeaderView];
            [controller.singleplayerHeaderView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
            [controller.singleplayerHeaderView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:controller.gameContainerView];

            [controller.multiplayerHeaderView removeFromSuperview];
        }
    } else {
        self.multiplayerConnectView.hidden = YES;

        // Multi player match.
        if (controller.multiplayerHeaderView.superview == nil) {
            controller.multiplayerHeaderView.frame = controller.singleplayerHeaderView.frame;
            [controller.gameContentView addSubview:controller.multiplayerHeaderView];
            [controller.multiplayerHeaderView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
            [controller.multiplayerHeaderView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:controller.gameContainerView];
            [controller.multiplayerHeaderView setMatch:manager.currentMatch turn:[NSKeyedUnarchiver unarchiveObjectWithData:manager.currentMatch.matchData] currentParticipant:manager.currentMatch.currentParticipant];

            [controller.singleplayerHeaderView removeFromSuperview];
        }

        // Update board for this match.
        [self layoutMatch:currentMatch];
    }
}

- (BOOL)isCurrentPlayersTurn {
    if ([GKLocalPlayer localPlayer].authenticated && self.gameCenterManager.currentMatch && ![self.gameCenterManager.currentMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        DDLogVerbose(@"Not current player's turn. Local player id: %@, Player with turn: %@", [GKLocalPlayer localPlayer].playerID, self.gameCenterManager.currentMatch.currentParticipant.playerID);
        return NO;
    }
    return YES;
}

- (void)switchToMultiplayerModeWithMatch:(GKTurnBasedMatch *)match {
    self.isMultiplayer = YES;
    [self setup];
}

- (void)startMultiplayerMatch {
    [self.gameCenterManager findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}
#pragma mark SH Game Center Manager Delegate
- (void)enterNewGame:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Entering new multiplayer game...");
    // Initialize game
    [self initGameCreateBoard:YES ];
    // Update the multiplayer header
    [self.multiplayerHeaderView setMatch:match turn:nil currentParticipant:match.currentParticipant];
}

- (void)layoutMatch:(GKTurnBasedMatch *)match {
    DDLogVerbose(@"Update match layout.");
    [self updateGameStatus:match];
    [self updateBoardForMatch:match];
}

- (void)updateBoardForMatch:(GKTurnBasedMatch *)match {
    // Update board layout.
    if ([match.matchData bytes]) {
        SHGameTurn *turn = [NSKeyedUnarchiver unarchiveObjectWithData:match.matchData];
        [self.turnsForMatch setObject:turn forKey:match.matchID];
        // Update the current score for this player.
        if ([turn.scores objectForKey:[GKLocalPlayer localPlayer].playerID]) {
            self.score = ((NSNumber *) [turn.scores objectForKey:[GKLocalPlayer localPlayer].playerID]).integerValue;
        } else {
            self.score = 0;
        }
        // Update the current state of board.
        self.board = [turn.board mutableCopy];
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        // Move the board.
        [self animateBoardMoveInDirection:turn.boardMoveDirection];
        // Add the new tile.
        [self addTile:turn.theNewCell];
        // Update the multiplayer view
        [self.multiplayerHeaderView setMatch:match turn:turn currentParticipant:match.currentParticipant];
    }
}

- (void)updateGameStatus:(GKTurnBasedMatch *)match {
    if (match.status != GKTurnBasedMatchStatusEnded) {
        self.gameTerminated = NO;
        self.gameWon = NO;
    }
    [self updateStatusForMatch:match participant:match.currentParticipant];
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match {

}

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {

}

- (void)gameCenterManager:(SHGameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    if (self.isMultiplayer && gameCenterLoginController) {
        [self presentViewController:gameCenterLoginController animated:NO completion:nil];
    }
}

- (void)gameCenterManagerdidFailToAuthenticatePlayer:(SHGameCenterManager *)manager {
    // Authentication failed. Try again?
    if (self.isMultiplayer) {
        [UIAlertView bk_showAlertViewWithTitle:@"Cannot login to Game Center" message:@"You need to be logged in to Game Center to play with other players" cancelButtonTitle:@"Go Back" otherButtonTitles:@[@"Retry"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch (buttonIndex) {
                case 0:
                    // Cancel. Go Back
                    [self.navigationController popViewControllerAnimated:NO];
                    break;
                case 1:
                    // Retry
                    [self loginToGameCenter];
                    break;
                default:
                    // Go Back
                    [self.navigationController popViewControllerAnimated:NO];
                    break;
            }
        }];
    }
}

- (void)gameCenterManager:(SHGameCenterManager *)manager didAuthenticatePlayer:(GKLocalPlayer *)player {
    [self localPlayer:player authenticationDidChange:self];

    if (self.isMultiplayer && self.gameCenterManager.currentMatch == nil) {
        // Find a multiplayer game
        [self.gameCenterManager findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
    }
}

#pragma mark - Computed Properties
- (BOOL)multiplayerModeValid {
    // Returns true if multiplayer mode is active, player is logged in and a match is in progress. False otherwise
    if (self.isMultiplayer) {
        if ([GKLocalPlayer localPlayer].isAuthenticated) {
            if (self.gameCenterManager.currentMatch != nil) {
                return YES;
            }
        }
        return NO;
    }
    return YES;
}

@end

@implementation SHBoardMoveResult
- (instancetype)initWithScore:(int)score moved:(BOOL)moved {
    self = [super init];
    if (self) {
        self.score = score;
        self.moved = moved;
    }

    return self;
}

+ (instancetype)resultWithScore:(int)score moved:(BOOL)moved {
    return [[self alloc] initWithScore:score moved:moved];
}
@end