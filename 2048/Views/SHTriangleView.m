//
//  SHTriangleView.m
//  2048
//
//  Created by Pulkit Goyal on 24/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import "SHTriangleView.h"

@interface SHTriangleView ()
@property(nonatomic, strong) UIBezierPath *bezierPath;
@end

@implementation SHTriangleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self viewDidLoad];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self viewDidLoad];
    }
    return self;
}

- (void)viewDidLoad {
    // Initialize defaults
    self.borderRadius = 10.f;

    // Create a bezier path
    CGFloat a = self.borderRadius / 2.f;
    self.bezierPath = [UIBezierPath bezierPath];
    [self.bezierPath moveToPoint:(CGPoint) {self.frame.size.width / 2.f, a}];
    [self.bezierPath addLineToPoint:(CGPoint) {self.frame.size.width - a, self.frame.size.height - a}];
    [self.bezierPath addLineToPoint:(CGPoint) {a, self.frame.size.height - a}];
    [self.bezierPath closePath];
}


- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext(), context = c;
    CGColorRef col = self.tintColor.CGColor;
    CGColorRef bcol = self.tintColor.CGColor;
    CGContextSetFillColorWithColor(c, col);
    CGContextSetStrokeColorWithColor(c, bcol);
    CGContextSetLineWidth(c, self.borderRadius);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetLineCap(c, kCGLineCapRound);
    CGContextAddPath(c, self.bezierPath.CGPath);
    CGContextStrokePath(c);
    CGContextAddPath(c, self.bezierPath.CGPath);
    CGContextFillPath(c);

}

@end
