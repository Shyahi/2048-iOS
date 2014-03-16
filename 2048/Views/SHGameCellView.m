//
//  SHGameCellView.m
//  2048
//
//  Created by Pulkit Goyal on 16/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHGameCellView.h"

@interface SHGameCellView ()
@property(nonatomic, strong) UILabel *numberLabel;
@end

@implementation SHGameCellView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];

    self.numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.numberLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:32];
    [self.numberLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.numberLabel];
}

- (void)setNumber:(NSNumber *)number {
    _number = number;

    self.numberLabel.text = [[self numberFormatter] stringFromNumber:number];
}

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *formatter;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return formatter;
}

@end
