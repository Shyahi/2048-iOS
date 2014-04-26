//
//  SHGameCellData.h
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHGameCellData : NSObject<NSCoding>
@property(nonatomic, strong) NSNumber *number;
@property(nonatomic) BOOL merged;

- (instancetype)initWithNumber:(NSNumber *)number;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

+ (instancetype)dataWithNumber:(NSNumber *)number;

@end
