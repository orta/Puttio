//
//  UIFont+Puttio.m
//  Puttio
//
//  Created by orta therox on 27/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "UIFont+Puttio.h"

@implementation UIFont (Puttio)

+ (UIFont *)titleFontWithSize:(CGFloat )size {
    return [UIFont fontWithName:@"Exo-Bold" size:size];
}

+ (UIFont *)bodyFontWithSize:(CGFloat )size {
    return [UIFont fontWithName:@"Exo-Light" size:size];
}

@end
