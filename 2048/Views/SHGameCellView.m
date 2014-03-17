//
//  SHGameCellView.m
//  2048
//
//  Created by Pulkit Goyal on 16/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHGameCellView.h"
#import "SHColorMixer.h"
#import "HexColor.h"
#import "UIColor+Additions.h"

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

    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
}

- (void)setNumber:(NSNumber *)number {
    _number = number;
    [self updateView];

}

- (void)updateView {
    [self updateBackground];
    [self updateLabel];
}

- (void)updateBackground {
    static const double maxExponent = 11;
    double exponent = self.number ? log2(self.number.integerValue) : 1;
    double goldPercent = (exponent - 1) / (maxExponent - 1);
    UIColor *mixedBackgroundColor = [SHColorMixer mixColor:[self tileGoldColor] andColor:[self tileColor] withRatio:goldPercent];
    UIColor *specialBackgroundColor = [self specialColors][(NSUInteger) exponent];
    if (specialBackgroundColor && specialBackgroundColor != (id) [NSNull null]) {
        mixedBackgroundColor = [SHColorMixer mixColor:specialBackgroundColor andColor:mixedBackgroundColor withRatio:0.55];
    }
    self.backgroundColor = mixedBackgroundColor;
}

- (void)updateLabel {
    self.numberLabel.text = [[self numberFormatter] stringFromNumber:self.number];
    if ([self.backgroundColor isLightColor]) {
        self.numberLabel.textColor = [self darkTextColor];
    } else {
        self.numberLabel.textColor = [self brightTextColor];
    }
}


- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *formatter;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return formatter;
}

#pragma mark - Cosntants
- (UIColor *)tileColor {
    static UIColor *tileColor;
    if (!tileColor) {
        tileColor = [UIColor colorWithRed:0.933 green:0.894 blue:0.855 alpha:1.0];
    }
    return tileColor;
}

- (UIColor *)tileGoldColor {
    static UIColor *tileGoldColor;
    if (!tileGoldColor) {
        tileGoldColor = [UIColor colorWithRed:0.929 green:0.761 blue:0.18 alpha:1.0];
    }
    return tileGoldColor;
}

- (UIColor *)brightTextColor {
    static UIColor *brightTextColor;
    if (!brightTextColor) {
        brightTextColor = [UIColor colorWithHexString:@"#f9f6f2"];
    }
    return brightTextColor;
}

- (UIColor *)darkTextColor {
    static UIColor *darkTextColor;
    if (!darkTextColor) {
        darkTextColor = [UIColor colorWithHexString:@"#776e65"];
    }
    return darkTextColor;
}

- (NSArray *)specialColors {
    static NSArray *specialColors;
    if (!specialColors) {
        specialColors = @[[NSNull null],
                [NSNull null],
                [NSNull null],
                [UIColor colorWithHexString:@"#f78e48" alpha:1],
                [UIColor colorWithHexString:@"#fc5e2e" alpha:1],
                [UIColor colorWithHexString:@"#ff3333" alpha:1],
                [UIColor colorWithHexString:@"#ff0000" alpha:1],
                [NSNull null],
                [NSNull null],
                [NSNull null],
                [NSNull null],
                [NSNull null],
        ];
    }
    return specialColors;
}
@end
