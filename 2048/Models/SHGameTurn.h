//
// Created on 23/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import <Foundation/Foundation.h>
#import "SHGameViewController.h"

@class SHGameTurnNewCell;

typedef NS_ENUM(NSUInteger, SHMoveDirection) {
    kSHMoveDirectionLeft,
    kSHMoveDirectionRight,
    kSHMoveDirectionUp,
    kSHMoveDirectionDown
};

@interface SHGameTurn : NSObject <NSCoding>
@property(nonatomic, strong) NSArray *board;
@property(nonatomic) SHMoveDirection boardMoveDirection;
@property(nonatomic, strong) SHGameTurnNewCell *theNewCell;
@property (nonatomic, strong) NSMutableDictionary *scores;
- (instancetype)initWithBoard:(NSArray *)board direction:(enum SHMoveDirection)boardMoveDirection newCell:(SHGameTurnNewCell *)newCell;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;
+ (instancetype)turnWithBoard:(NSArray *)board direction:(enum SHMoveDirection)boardMoveDirection newCell:(SHGameTurnNewCell *)newCell;

@end

@interface SHGameTurnNewCell : NSObject <NSCoding>
@property(nonatomic) CGPoint position;
@property(nonatomic, strong) NSNumber *number;

- (instancetype)initWithPosition:(CGPoint)position number:(NSNumber *)number;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

+ (instancetype)cellWithPosition:(CGPoint)position number:(NSNumber *)number;

@end