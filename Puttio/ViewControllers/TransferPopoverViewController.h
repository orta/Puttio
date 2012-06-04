//
//  TransferPopoverViewControllerViewController.h
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORSimpleProgress;
@interface TransferPopoverViewController : UIViewController

@property (strong) Transfer *transfer;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *progressView;

@end
