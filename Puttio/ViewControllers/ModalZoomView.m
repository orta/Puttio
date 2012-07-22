//
//  ModalZoomViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ModalZoomView.h"

static ModalZoomView *sharedInstance;

@interface ModalZoomView ()
@property  UIView *backgroundView;
@property  UIViewController <ModalZoomViewControllerDelegate> *viewController;
@property (assign) CGRect originalFrame;
- (BOOL)validated;
@end

@implementation ModalZoomView
@synthesize backgroundView, viewController, originalFrame;

+ (id)sharedInstance; {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void)showWithViewControllerIdentifier:(NSString *)viewControllerID {
    [self showFromRect:CGRectNull withViewControllerIdentifier:viewControllerID andItem:nil];
}

+ (void)showFromRect:(CGRect)initialFrame withViewControllerIdentifier:(NSString *)viewControllerID andItem:(id)item {
    ModalZoomView *this = [self sharedInstance];
    if (this) {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        this.viewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:viewControllerID];
        
        if ([this validated]) {
            this.originalFrame = initialFrame;

            // setup background
            this.backgroundView = [self createBackgroundView];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:this action:@selector(backgroundViewTapped:)];
            [this.backgroundView addGestureRecognizer:tapGesture];
            [rootView addSubview:this.backgroundView];

            // get frames for the modal
            UIView *theView = this.viewController.view;
            theView.alpha = 0;
            CGRect finalFrame = theView.bounds;

            
            if ([UIDevice isPhone]) {
                finalFrame.size.width = MIN(finalFrame.size.width, 320);
            }

            BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
            if (isLandscape) {
                finalFrame.origin.x = rootView.frame.size.height / 2 - finalFrame.size.height / 2;
                finalFrame.origin.y = rootView.frame.size.width / 2 - finalFrame.size.width / 2;
            }else{
                finalFrame.origin.x = rootView.frame.size.width / 2 - finalFrame.size.width / 2;
                finalFrame.origin.y = rootView.frame.size.height / 2 - finalFrame.size.height / 2;
            }


            // if its got an initial frame use it, else don't
            BOOL animatesFromFrame = !CGRectEqualToRect(initialFrame, CGRectNull);
            if (animatesFromFrame) {
                this.viewController.view.frame = initialFrame;
            }else{
                this.viewController.view.frame = finalFrame;
            }
            
            if (item && [this.viewController respondsToSelector:@selector(setItem:)]) {
                this.viewController.item = item;
            }

            [rootView addSubview:this.viewController.view];

            CGFloat duration = animatesFromFrame? 0.5 : 0.3;
            [UIView animateWithDuration:duration animations:^{
                this.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
                theView.frame = finalFrame;
                theView.alpha = 1;
            }completion:^(BOOL finished) {
                if ([this.viewController respondsToSelector:@selector(zoomViewDidFinishZooming:)]) {
                    [this.viewController zoomViewDidFinishZooming:this];
                }
            } ];
        }
    }
}

+ (void)fadeOutViewAnimated:(BOOL)animated {
    CGFloat duration = animated? 0.3 : 0;
    ModalZoomView *this = [self sharedInstance];
    
    if([this.viewController respondsToSelector:@selector(zoomViewWillDissapear:)]){
        [this.viewController zoomViewWillDissapear:this];
    }
    
    [UIView animateWithDuration:duration animations:^{
        this.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        this.backgroundView.alpha = 0;
        this.viewController.view.frame = this.originalFrame;
        
    } completion:^(BOOL finished) {
        [this.backgroundView removeFromSuperview];
        [this.viewController viewWillDisappear:NO];
        [this.viewController viewWillUnload];
        [this.viewController.view removeFromSuperview];
        [this.viewController viewDidDisappear:NO];
        [this.viewController viewDidUnload];
        this.viewController = nil;
    }];
}

- (void)backgroundViewTapped:(UITapGestureRecognizer *)gesture {
    [self.class fadeOutViewAnimated:YES];
}

+ (UIView *)createBackgroundView {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    UIView *background = [[UIView alloc] initWithFrame:rootView.bounds];
    background.contentMode = UIViewContentModeScaleToFill;
    background.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleWidth |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleHeight |
                                            UIViewAutoresizingFlexibleBottomMargin);
    background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    return background;
}

- (BOOL)validated {
    if (!self.viewController) {
        [NSException raise:@"No View Controller Found in Storyboard" format:@"No View Controller Found in Storyboard"];
    }
    if (![self.viewController conformsToProtocol:@protocol(ModalZoomViewControllerDelegate)]) {
        [NSException raise:@"View Controller doesn't conform to ModalZoomViewControllerProtocol" format:@"View Controller doesn't conform to ModalZoomViewControllerProtocol"];            
    }
    return YES;
}

@end
