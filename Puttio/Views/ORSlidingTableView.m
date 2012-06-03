//
//  ORSlidingTableView.m
//  Puttio
//
//  Created by orta therox on 03/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSlidingTableView.h"

static CGFloat SIZE_OF_

@implementation ORSlidingTableView

@synthesize slidingDelegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.slidingDelegate slidingTableDidBeginTouch:self];
    [self touchesMoved:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    NSLog(@"%@", NSStringFromCGPoint(touchPoint));
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.slidingDelegate slidingTableDidEndTouch:self];
}


@end
