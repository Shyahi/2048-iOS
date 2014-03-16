//
//  SHColorMixer.m
//  2048
//
//  Created by Pulkit Goyal on 16/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHColorMixer.h"

@implementation SHColorMixer

+ (UIColor *)mixColor:(UIColor *)firstColor andColor:(UIColor *)secondColor withRatio:(double)ratio {
    if (ratio <= 0)
        return secondColor;
    if (ratio >= 1)
        return firstColor;

    /* There is a nicer way to do this in iOS > 5, but for backwards compatibility we do it this way */
    CGColorRef colorref = [firstColor CGColor];
    const CGFloat *components1 = CGColorGetComponents(colorref);
    CGFloat r1 = components1[0];
    CGFloat g1 = components1[1];
    CGFloat b1 = components1[2];
    CGFloat a1 = components1[3];

    colorref = [secondColor CGColor];
    const CGFloat *components2 = CGColorGetComponents(colorref);
    CGFloat r2 = components2[0];
    CGFloat g2 = components2[1];
    CGFloat b2 = components2[2];
    CGFloat a2 = components2[3];

    CGFloat r3 = (CGFloat) (r1 * ratio + (1 - ratio) * r2);
    CGFloat g3 = (CGFloat) (g1 * ratio + (1 - ratio) * g2);
    CGFloat b3 = (CGFloat) (b1 * ratio + (1 - ratio) * b2);
    CGFloat a3 = (CGFloat) (a1 * ratio + (1 - ratio) * a2);

    return [UIColor colorWithRed:r3 green:g3 blue:b3 alpha:a3];
}

@end
