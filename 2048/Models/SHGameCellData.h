//
//  SHGameCellData.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHGameCellData : NSObject
@property(nonatomic, strong) NSNumber *number;
@property(nonatomic) BOOL merged;

- (instancetype)initWithNumber:(NSNumber *)number;

+ (instancetype)dataWithNumber:(NSNumber *)number;

@end
