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
    NSTimer *_timer;
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

    [self updateProgress];
    self.progressView.isLandscape = YES;

    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)tick {
    [self updateProgress];
}

- (void)updateProgress {
    if ([_item respondsToSelector:@selector(percentDone)]) {
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", [[_item percentDone] floatValue]];
        self.progressView.progress = [[_item percentDone] floatValue]/100;
    }

    if ([_item respondsToSelector:@selector(processProgress)]) {
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", [_item processProgress] * 100 ];
        self.progressView.progress = [_item processProgress];
    }

    if ([_item respondsToSelector:@selector(message)]) {
        if ([_item message] != nil) {
            self.progressLabel.text = [_item message];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)viewDidUnload {
    [_timer invalidate];
    _timer = nil;

//    [self setProgressLabel:nil];
//    [self setTitleLabel:nil];
//    [self setProgressView:nil];
//    [self setItem:nil];
    [super viewDidUnload];
}
@end
