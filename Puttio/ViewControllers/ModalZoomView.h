//
//  ModalZoomViewController.h
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModalZoomView;
@protocol ModalZoomViewControllerDelegate <NSObject>

@optional
- (void)setItem:(id)item;
- (CGSize)sizeForZoomView:(ModalZoomView *)zoomView;
- (void)zoomViewDidFinishZooming:(ModalZoomView *)zoomView;
- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView;
@end


@interface ModalZoomView : NSObject
+ (UIViewController *)showWithViewControllerIdentifier:(NSString *)viewControllerID;
+ (UIViewController *)showFromRect:(CGRect)initialFrame withViewControllerIdentifier:(NSString *)viewControllerID andItem:(id)item;

+ (void)fadeOutViewAnimated:(BOOL)animated;
+ (BOOL)isShowing;

@property  UIViewController <ModalZoomViewControllerDelegate> *viewController;

@end
