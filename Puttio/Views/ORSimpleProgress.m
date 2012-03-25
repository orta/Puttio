//
//  ORSimpleProgress.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSimpleProgress.h"

@implementation ORSimpleProgress
@synthesize label, fillColour;
@dynamic value;

- (void)awakeFromNib {
    self.alpha = .3;
    self.label = [[UILabel alloc] initWithFrame:self.frame];
    value = .3;
    self.backgroundColor = [UIColor putioBlue];
    self.fillColour = [UIColor putioYellow];
}

- (void)drawRect:(CGRect)rect {    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColor(c, CGColorGetComponents(self.backgroundColor.CGColor));
    CGContextFillRect(c, self.bounds);

    CGRect filledRect = self.bounds;
    filledRect.size.height = filledRect.size.height / value;
    CGContextSetFillColor(c, CGColorGetComponents(self.fillColour.CGColor));
    CGContextFillRect(c, filledRect);
}

- (void)setValue:(CGFloat)aValue {
    self.alpha = 1;
    value = aValue;
    [self setNeedsDisplay];
}

@end
