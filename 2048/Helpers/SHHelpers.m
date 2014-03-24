//
// Created on 24/03/14.
// Copyright (c) 2014 Shyahi. All rights reserved.
//
//


#import "SHHelpers.h"


@implementation SHHelpers {

}
+ (NSNumberFormatter *)scoreFormatter {
    static NSNumberFormatter *formatter;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    return formatter;
}

@end