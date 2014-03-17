//
// Created on 17/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import "UIView+SHAdditions.h"


@implementation UIView (SHAdditions)

/**
* Adapted from http://stackoverflow.com/a/18925301
*/
- (UIImage *)sh_takeSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end