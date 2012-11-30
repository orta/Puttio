//
//  UIColor+PutioColours.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "UIColor+PutioColours.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIColor (PutioColours)

+ (UIColor *)putioYellow {
    return [UIColor colorWithRed:0.965 green:0.911 blue:0.247 alpha:1.000];
}

+ (UIColor *)putioBlue {
    return [UIColor colorWithRed:0.366 green:0.676 blue:0.969 alpha:1.000];
}

+ (UIColor *)putioRed {
   return [UIColor colorWithRed:1.000 green:0.301 blue:0.050 alpha:1.000];
}

+ (UIColor *)putioDarkRed {
   return [UIColor colorWithRed:0.681 green:0.141 blue:0.082 alpha:1.000];
}

+ (UIColor *)putioDarkBlue {
   return [UIColor colorWithRed:0.300 green:0.459 blue:1.000 alpha:1.000];
}

+ (UIColor *)putioLightGray {
    return [UIColor colorWithWhite:0.737 alpha:1.000];
}

// https://gist.github.com/1661029
- (UIColor *)lighterColorByPercentage:(float)amount {
    CGFloat* oldComponents = (CGFloat *) CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];

    newComponents[0] = MIN(oldComponents[0] * amount + oldComponents[0], 1);
    newComponents[1] = MIN(oldComponents[1] * amount + oldComponents[1], 1);
    newComponents[2] = MIN(oldComponents[2] * amount + oldComponents[2], 1);
    newComponents[3] = MIN(oldComponents[3] * amount + oldComponents[3], 1);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);

	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);

    return retColor;
}


@end
