//
// Created on 23/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import "SHGameTurn.h"


@implementation SHGameTurn {

}
#pragma mark - Initialization
- (instancetype)initWithBoard:(NSArray *)board direction:(enum SHMoveDirection)boardMoveDirection newCell:(SHGameTurnNewCell *)newCell {
    self = [super init];
    if (self) {
        self.board = board;
        self.boardMoveDirection = boardMoveDirection;
        self.theNewCell = newCell;
        self.scores = [[NSMutableDictionary alloc] initWithCapacity:2];
    }

    return self;
}

+ (instancetype)turnWithBoard:(NSArray *)board direction:(enum SHMoveDirection)boardMoveDirection newCell:(SHGameTurnNewCell *)newCell {
    return [[self alloc] initWithBoard:board direction:boardMoveDirection newCell:newCell];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.board = [coder decodeObjectForKey:@"self.board"];
        self.boardMoveDirection = (SHMoveDirection) [coder decodeIntForKey:@"self.boardMoveDirection"];
        self.theNewCell = [coder decodeObjectForKey:@"self.theNewCell"];
        self.scores = [coder decodeObjectForKey:@"self.scores"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.board forKey:@"self.board"];
    [coder encodeInt:self.boardMoveDirection forKey:@"self.boardMoveDirection"];
    [coder encodeObject:self.theNewCell forKey:@"self.theNewCell"];
    [coder encodeObject:self.scores forKey:@"self.scores"];
}

@end

@implementation SHGameTurnNewCell {

}
#pragma mark - Initialization
- (instancetype)initWithPosition:(CGPoint)position number:(NSNumber *)number {
    self = [super init];
    if (self) {
        self.position = position;
        self.number = number;
    }

    return self;
}

+ (instancetype)cellWithPosition:(CGPoint)position number:(NSNumber *)number {
    return [[self alloc] initWithPosition:position number:number];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.position = [coder decodeCGPointForKey:@"self.position"];
        self.number = [coder decodeObjectForKey:@"self.number"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeCGPoint:self.position forKey:@"self.position"];
    [coder encodeObject:self.number forKey:@"self.number"];
}


@end