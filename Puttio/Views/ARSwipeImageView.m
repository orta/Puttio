//
//  ARSwipeImageView.m
//  Puttio
//
//  Created by orta therox on 06/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ARSwipeImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ARSwipeImageView

static CGFloat MovementDistance = 200;

- (void)awakeFromNib {
    self.userInteractionEnabled = NO;
    self.layer.opacity = 0.0;
}

- (void)startAnimation {
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.fromValue = [NSNumber numberWithFloat:(0.1 * M_PI)];
	rotationAnimation.toValue = [NSNumber numberWithFloat:(-0.1 * M_PI)];
	rotationAnimation.duration = 1.9f;
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = [NSNumber numberWithFloat:1.3];
	scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
	scaleAnimation.duration = 0.2f;
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	alphaAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	alphaAnimation.toValue = [NSNumber numberWithFloat:0];
	alphaAnimation.duration = 2.0f;
	alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CAKeyframeAnimation *movementAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
	movementAnimation.duration = 3.0f;
    movementAnimation.timeOffset = 1;

	CGMutablePathRef thePath = CGPathCreateMutable();
	CGPathMoveToPoint(thePath, NULL, self.layer.position.x, self.layer.position.y);
	CGPathAddLineToPoint(thePath, NULL, self.layer.position.x + MovementDistance, self.layer.position.y);
	movementAnimation.path = thePath;
	CGPathRelease(thePath);

	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.duration = 2.0f;
	animationGroup.repeatCount = 3;
	[animationGroup setAnimations:@[movementAnimation, rotationAnimation, scaleAnimation, alphaAnimation]];
    [animationGroup setDelegate:self];
	[self.layer addAnimation:animationGroup forKey:@"animationGroup"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (flag) {
        [self removeFromSuperview];
    }
}

@end
