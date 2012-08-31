//
//  AudioViewController.h
//  Puttio
//
//  Created by orta therox on 31/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalZoomView.h"

@interface AudioViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (nonatomic)  NSObject <ORDisplayItemProtocol> *item;

@end
