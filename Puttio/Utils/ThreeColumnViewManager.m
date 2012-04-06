//
//  ThreeColumnViewManager.m
//  Puttio
//
//  Created by orta therox on 06/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ThreeColumnViewManager.h"

@interface ThreeColumnViewManager () {
    CGFloat xTouchOffset;
}
@end

@implementation ThreeColumnViewManager
@synthesize view;
@synthesize leftSidebar, rightSidebar, centerView;

- (void)setup {

    [self setupGestures];
}

- (void)setupLayout {
    CGRect leftSidebarSpace = [self.view bounds];
    leftSidebarSpace.origin.y = 0;
    leftSidebarSpace.size.width = SidebarWidth;
    leftSidebar.frame = leftSidebarSpace;
    
    CGRect centerViewSpace = [self.view bounds];
    centerViewSpace.origin.x = SidebarWidth;
    centerViewSpace.origin.y = 0;
    centerViewSpace.size.width = centerViewSpace.size.width - (SidebarWidth * 2);
    centerView.frame = centerViewSpace;

    CGRect rightSidebarSpace = [self.view bounds];
    rightSidebarSpace.origin.y = 0;
    rightSidebarSpace.origin.x = rightSidebarSpace.size.width - SidebarWidth;
    rightSidebarSpace.size.width = SidebarWidth;
    rightSidebar.frame = rightSidebarSpace;
}

- (void)setupGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSidebarPanGesture:)];
    [self.leftSidebar addGestureRecognizer:panGesture];

    
}

- (void)handleLeftSidebarPanGesture:(UIPanGestureRecognizer *) gesture {
    CGPoint location = [gesture locationInView:self.leftSidebar];  
    CGPoint velocity = [gesture velocityInView:self.leftSidebar];
    
    switch (gesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            xTouchOffset = self.leftSidebar.frame.origin.x - location.x;
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGRect newFrame = self.leftSidebar.frame;
            newFrame.origin.x = location.x - xTouchOffset;
            self.leftSidebar.frame = newFrame;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            CGRect space = [self.leftSidebar.superview bounds];
            if (velocity.x > 0) {
                space.origin.x = 0;
            }else{
                space.origin.x = -SidebarWidth + 20;
            }
            space.size.width = SidebarWidth;
            self.leftSidebar.frame = space;
            break;
        }
    }
}


@end
