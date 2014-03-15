//
//  SHGameCell.m
//  2048
//
//  Created by Pulkit Goyal on 15/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHGameCell.h"
#import "SHGameCellData.h"

@implementation SHGameCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configure:(SHGameCellData *)data {
    self.numberLabel.text = [[self numberFormatter] stringFromNumber:data.number];
}

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *formatter;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return formatter;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
