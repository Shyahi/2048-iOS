//
//  SHGameCellData.m
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHGameCellData.h"

@implementation SHGameCellData
- (instancetype)initWithNumber:(NSNumber *)number {
    self = [super init];
    if (self) {
        self.number = number;
    }

    return self;
}

+ (instancetype)dataWithNumber:(NSNumber *)number {
    return [[self alloc] initWithNumber:number];
}

@end
