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
- (void)zoomViewDidFinishZooming:(ModalZoomView *)zoomView;
- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView;
@end


@interface ModalZoomView : NSObject
+ (void)showWithViewControllerIdentifier:(NSString *)viewControllerID;
+ (void)showFromRect:(CGRect)initialFrame withViewControllerIdentifier:(NSString *)viewControllerID andItem:(id)item;
+ (void)fadeOutViewAnimated:(BOOL)animated;
+ (BOOL)isShowing;
@property  UIViewController <ModalZoomViewControllerDelegate> *viewController;
@end
