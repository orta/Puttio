//
//  ORRotatingButton.m
//  Puttio
//
//  Created by orta therox on 14/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORRotatingButton.h"

@interface ORRotatingButton () {
    CAKeyframeAnimation *rotationAnimation;
}
@end



@implementation ORRotatingButton

CGFloat RotationDuration = 0.9;

- (void)startAnimating {
    if (rotationAnimation) return;

	rotationAnimation = [CAKeyframeAnimation animation];
	rotationAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.13, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(6.26, 0,0,1)],
						   nil];
	rotationAnimation.cumulative = YES;
	rotationAnimation.duration = RotationDuration;
	rotationAnimation.repeatCount = HUGE_VALF;
	rotationAnimation.removedOnCompletion = YES;
	[self.layer addAnimation:rotationAnimation forKey:@"transform"];

}

- (void)stopAnimating {
    [self.layer removeAllAnimations];
}

@end
