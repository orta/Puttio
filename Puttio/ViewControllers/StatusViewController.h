//
//  StatusViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORSimpleProgress;
@interface StatusViewController : UIViewController

@property (weak, nonatomic) IBOutlet ORSimpleProgress *bandwidthProgressView;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *spaceProgressView;
- (void)setup;
@end
