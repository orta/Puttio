//
//  ThreeColumnViewManager.m
//  Puttio
//
//  Created by orta therox on 06/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ThreeColumnViewManager.h"

CGFloat const SidebarWidth = 280;
CGFloat const SidebarPokeOutWidth = 24;
CGFloat const SidebarAnimationDuration = 0.15;

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
    CGRect fullFrame = [[UIScreen mainScreen] applicationFrame];
    fullFrame.origin.y = 0;
    BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape){
        CGFloat tempWidth = fullFrame.size.width;
        fullFrame.size.width = fullFrame.size.height;
        fullFrame.size.height = tempWidth;
    }
    
    BOOL leftHidden = ![[NSUserDefaults standardUserDefaults] boolForKey:ORShowLeftSidebarDefault];
    BOOL rightHidden = ![[NSUserDefaults standardUserDefaults] boolForKey:ORShowRightSidebarDefault] && !isLandscape;
    
    CGRect leftSidebarSpace = fullFrame;
    leftSidebarSpace.origin.x = leftHidden? -SidebarWidth + SidebarPokeOutWidth : 0;
    leftSidebarSpace.size.width = SidebarWidth;
    leftSidebar.frame = leftSidebarSpace;

    CGRect rightSidebarSpace = fullFrame;
    rightSidebarSpace.origin.x = rightHidden? rightSidebarSpace.size.width - SidebarPokeOutWidth : rightSidebarSpace.size.width - SidebarWidth;
    rightSidebarSpace.size.width = SidebarWidth;
    rightSidebar.frame = rightSidebarSpace;
    
    CGRect centerViewSpace = fullFrame;
    centerView.frame = centerViewSpace;
    [self updateCenterViewSize];
}

- (void)updateCenterViewSize {
    CGRect centerViewSpace = centerView.frame;
    centerViewSpace.origin.x = leftSidebar.frame.origin.x + SidebarWidth;
    centerViewSpace.size.width = rightSidebar.frame.origin.x - centerViewSpace.origin.x;
    centerView.frame = centerViewSpace;
}

- (void)setupGestures {
    UIPanGestureRecognizer *leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSidebarPanGesture:)];
    [self.leftSidebar addGestureRecognizer:leftPanGesture];
    
    UIPanGestureRecognizer *rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSidebarPanGesture:)];
    [self.rightSidebar addGestureRecognizer:rightPanGesture];
}

- (void)handleLeftSidebarPanGesture:(UIPanGestureRecognizer *) gesture {
    CGPoint location = [gesture locationInView:self.view];  
    CGPoint velocity = [gesture velocityInView:self.view];
    
    switch (gesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            xTouchOffset = self.leftSidebar.frame.origin.x - location.x;
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGRect newFrame = self.leftSidebar.frame;
            newFrame.origin.x = location.x + xTouchOffset;
            newFrame.origin.x = MIN(0, newFrame.origin.x);
            self.leftSidebar.frame = newFrame;
            [self updateCenterViewSize];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            BOOL isShowingSidebar = YES;
            CGRect space = [self.leftSidebar.superview bounds];
            
            if (velocity.x > 0) {
                space.origin.x = 0;
            }else{
                space.origin.x = -SidebarWidth + SidebarPokeOutWidth;
                isShowingSidebar = NO;
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:isShowingSidebar forKey:ORShowLeftSidebarDefault];
            [[NSUserDefaults standardUserDefaults] synchronize];
            space.size.width = SidebarWidth;
            [UIView animateWithDuration:SidebarAnimationDuration animations:^{                
                self.leftSidebar.frame = space;
                [self updateCenterViewSize];
            }];
            break;
        }
    }
}

- (void)handleRightSidebarPanGesture:(UIPanGestureRecognizer *) gesture {
    CGPoint location = [gesture locationInView:self.view];  
    CGPoint velocity = [gesture velocityInView:self.view];
    
    switch (gesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            xTouchOffset = self.rightSidebar.frame.origin.x - location.x;
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGRect newFrame = self.rightSidebar.frame;
            newFrame.origin.x = location.x + xTouchOffset;
            newFrame.origin.x = MAX(self.view.frame.size.width, newFrame.origin.x);
            self.rightSidebar.frame = newFrame;
            [self updateCenterViewSize];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            BOOL isShowingSidebar = YES;
            CGRect space = [self.rightSidebar.superview bounds];
            
            if (velocity.x > 0) {
                space.origin.x = self.view.bounds.size.width - SidebarPokeOutWidth;
                isShowingSidebar = NO;
            }else{
                space.origin.x = self.view.bounds.size.width - SidebarWidth;
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:isShowingSidebar forKey:ORShowRightSidebarDefault];
            [[NSUserDefaults standardUserDefaults] synchronize];
            space.size.width = SidebarWidth;
            [UIView animateWithDuration:SidebarAnimationDuration animations:^{                
                self.rightSidebar.frame = space;
                [self updateCenterViewSize];
            }];
            break;
        }
    }
}



@end
