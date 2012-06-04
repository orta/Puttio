//
//  TransferPopoverViewControllerViewController.m
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "TransferPopoverViewController.h"
#import "ORSimpleProgress.h"

@interface TransferPopoverViewController (){
    Transfer *_transfer;
}

@end

@implementation TransferPopoverViewController

@dynamic transfer;
@synthesize progressLabel;
@synthesize titleLabel;
@synthesize progressView;

- (Transfer *)transfer {
    return _transfer;
}

- (void)setTransfer:(Transfer *)transfer {
    _transfer = transfer;
    
    self.titleLabel.text = transfer.name;
    self.progressLabel.text = [NSString stringWithFormat:@"%.1f %", [transfer.percentDone floatValue]];
    self.progressView.progress = [transfer.percentDone floatValue]/100;
    self.progressView.isLandscape = YES;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
    [self setProgressLabel:nil];
    [self setTitleLabel:nil];
    [self setProgressView:nil];
    [self setTransfer:nil];
    [super viewDidUnload];
}
@end
