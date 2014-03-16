//
//  SHColorMixer.h
//  2048
//
//  Created by Pulkit Goyal on 16/03/14.
//  Copyright (c) 2014 Shyahi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHColorMixer : NSObject

+ (UIColor *)mixColor:(UIColor *)firstColor andColor:(UIColor *)secondColor withRatio:(double)ratio;
@end
