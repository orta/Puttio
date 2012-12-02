//
//  ORAddTorrentFromBrowseViewController.h
//  Puttio
//
//  Created by orta therox on 02/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalZoomView.h"

@interface ORAddTorrentFromBrowseViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (strong, nonatomic) NSString *address;

@end
