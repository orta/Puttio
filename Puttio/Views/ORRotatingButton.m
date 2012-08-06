//
//  ORRotatingButton.m
//  Puttio
//
//  Created by orta therox on 14/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORRotatingButton.h"
#import <QuartzCore/QuartzCore.h>

@interface ORRotatingButton () {
    CABasicAnimation *rotationAnimation;
}
@end



@implementation ORRotatingButton

CGFloat RotationDuration = 0.9;

- (void)fadeIn {
    if (self.alpha) return;
    [self startAnimating];

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)fadeOut {
    if (!self.alpha) return;
    [self stopAnimating];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
}

- (void)startAnimating {
    if (rotationAnimation) return;
    [self animate:HUGE_VAL];
}

- (void)animate:(int)times{
    CATransform3D rotationTransform = CATransform3DMakeRotation(1.01f * M_PI, 0, 0, 1.0);
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    rotationAnimation.duration = RotationDuration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = times;
	[self.layer addAnimation:rotationAnimation forKey:@"transform"];

}

- (void)stopAnimating {
    [self.layer removeAllAnimations];
    [self animate:1];
}

@end
