//
//  ORAddBookmarkViewController.h
//  Puttio
//
//  Created by orta therox on 06/01/2013.
//  Copyright (c) 2013 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalZoomView.h"
#import "ORBookmarksViewController.h"
@interface ORAddBookmarkViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (assign, nonatomic) NSString *name;
@property (assign, nonatomic) NSString *address;
@property (weak) ORBookmarksViewController *bookmarksController;

@end
