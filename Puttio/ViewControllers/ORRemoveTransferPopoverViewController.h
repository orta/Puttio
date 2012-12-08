//
//  ORRemoveTransferPopoverViewController.h
//  Puttio
//
//  Created by orta therox on 08/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORTransferViewController.h"

@interface ORRemoveTransferPopoverViewController : UIViewController

- (void)setTransfer:(Transfer *)transfer;
- (void)setTransferViewController:(ORTransferViewController *)transferVC;
@end
