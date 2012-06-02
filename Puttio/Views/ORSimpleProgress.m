//
//  ORSimpleProgress.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSimpleProgress.h"

@implementation ORSimpleProgress
@synthesize label, fillColour, isLandscape;
@dynamic progress;

- (void)awakeFromNib {
    self.alpha = .3;
    self.label = [[UILabel alloc] initWithFrame:self.frame];
    _progress = .3;
    self.backgroundColor = [UIColor putioBlue];
    self.fillColour = [UIColor putioYellow];
}

- (void)drawRect:(CGRect)rect {    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColor(c, CGColorGetComponents(self.backgroundColor.CGColor));
    CGContextFillRect(c, self.bounds);

    CGRect filledRect = self.bounds;
    if (self.isLandscape) {
        filledRect.size.width = filledRect.size.width / _progress;
    }else{
        filledRect.size.height = filledRect.size.height / _progress;
    }
    CGContextSetFillColor(c, CGColorGetComponents(self.fillColour.CGColor));
    CGContextFillRect(c, filledRect);
}

- (void)setProgress:(CGFloat)progress {
    self.alpha = 1;
    _progress = progress;
    [self setNeedsDisplay];
}

@end
