//
//  TransferPopoverViewControllerViewController.m
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ProcessPopoverViewController.h"
#import "ORSimpleProgress.h"
#import "BaseProcess.h"

@interface ProcessPopoverViewController (){
    id _item;
}

@end

@implementation ProcessPopoverViewController

@dynamic item;
@synthesize progressLabel;
@synthesize titleLabel;
@synthesize progressView;

- (id)item {
    return _item;
}

- (void)setItem:(id)item {
    _item = item;

    if ([item respondsToSelector:@selector(displayName)]) {
        self.titleLabel.text = [item displayName];
    }
    
    if ([item respondsToSelector:@selector(primaryDescription)]) {
        self.titleLabel.text = [item primaryDescription];
    }

    if ([item respondsToSelector:@selector(percentDone)]) {
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", [[item percentDone] floatValue]];
        self.progressView.progress = [[item percentDone] floatValue]/100;
    }
    
    if ([item respondsToSelector:@selector(progress)]) {
//        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", [item progress] * 100 ];
//        self.progressView.progress = [item progress];
    }

    if ([item respondsToSelector:@selector(message)]) {
        if ([item message] != nil) {
            self.progressLabel.text = [item message];
        }
    }
    
    self.progressView.isLandscape = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
    [self setProgressLabel:nil];
    [self setTitleLabel:nil];
    [self setProgressView:nil];
    [self setItem:nil];
    [super viewDidUnload];
}
@end
