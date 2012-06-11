//
//  ORSlidingTableView.m
//  ;;
//
//  Created by orta therox on 03/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSlidingTableView.h"

static CGFloat SIZE_OF_CELLS = 24;

@implementation ORSlidingTableView

@synthesize slidingDelegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.slidingDelegate slidingTableDidBeginTouch:self];
    [self touchesMoved:touches withEvent:event];        
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    int index = floorf(touchPoint.y / SIZE_OF_CELLS);
    [self.slidingDelegate slidingTable:self didMoveToCellAtIndex:index];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.slidingDelegate slidingTableDidEndTouch:self];
}


@end
