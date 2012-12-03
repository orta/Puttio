//
//  ORExtendedTransferCell.m
//  Puttio
//
//  Created by orta therox on 14/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSimpleProgress.h"
#import "ORExtendedTransferCell.h"
#import "UIDevice+SpaceStats.h"
#import "NSDate+HumanizedTime.h"
#import "ORDestructiveButton.h"
#import "ORTitleLabel.h"

@interface ORExtendedTransferCell (){
    UIView *_backgroundView;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToGoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStartedLabel;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *downloadProgress;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *downloadSpeedLabel;

@end

@implementation ORExtendedTransferCell

- (void)setTransfer:(Transfer *)transfer {
    _titleLabel.text = [transfer displayName];
    if (transfer.estimatedTime) {
        _timeStartedLabel.text = [[transfer estimatedTime] stringValue];
    }

    NSString *status = [[transfer statusMessage] stringByReplacingOccurrencesOfString:@"This download turned out to be larger than your available space." withString:@"Not enough space."];
    _timeToGoLabel.text = status;
    _downloadProgress.progress = [transfer percentDone].floatValue / 100;
    _downloadProgress.isLandscape = YES;

    NSString *downloadSpeed = [UIDevice humanStringFromBytes:transfer.downSpeed.doubleValue];
    _downloadSpeedLabel.text = [NSString stringWithFormat:@"%@ps", downloadSpeed];

    _downloadProgress.hidden = YES;
    _downloadSpeedLabel.hidden = YES;
    _timeToGoLabel.hidden = NO;


    UIImage *image = nil;
    switch (transfer.transferStatus) {
        case PKTransferStatusDownloading:
            image = [UIImage imageNamed:@"TransferDownloading"];
            _downloadProgress.hidden = NO;
            _downloadSpeedLabel.hidden = YES;

            _timeToGoLabel.hidden = YES;
            break;
        case PKTransferStatusCompleted:
            image = [UIImage imageNamed:@"TransferComplete"];
            break;
        case PKTransferStatusSeeding:
            image = [UIImage imageNamed:@"TransferUploading"];
            break;
        default:
            image = [UIImage imageNamed:@"TransferError"];
            break;
    }
    _statusImageView.image = image;
}

- (void)prepareForReuse {
    self.alpha = 1;
    [_backgroundView removeFromSuperview];
}

- (void)deletedTransfer {
    CGRect buttonFrame = [[_backgroundView subviews][0] frame];
    ORTitleLabel *label = [[ORTitleLabel alloc] initWithFrame:buttonFrame];
    label.text = @"Removed";
    label.textAlignment = UITextAlignmentCenter;
    [[_backgroundView subviews][0] removeFromSuperview];
    [_backgroundView addSubview:label];
}

- (void)showCancelButtonWithTarget:(id)target {
    CGRect slideViewStart = self.bounds;
    slideViewStart.origin.x = self.bounds.size.width;

    _backgroundView = [[UIView alloc] initWithFrame:slideViewStart];
    _backgroundView.backgroundColor = [UIColor putioBlue];
    [self.contentView addSubview:_backgroundView];

    ORDestructiveButton *cancelButton = [ORDestructiveButton buttonWithType:UIButtonTypeCustom];

    cancelButton.tag = self.tag;
    if (self.transfer.transferStatus != PKTransferStatusDownloading) {
        [cancelButton setTitle:@"Remove Transfer" forState:UIControlStateNormal];
    } else {
        [cancelButton setTitle:@"Cancel Transfer" forState:UIControlStateNormal];
    }
    
    cancelButton.frame = CGRectInset(_backgroundView.bounds, 32, 21);
    [cancelButton addTarget:target action:@selector(cancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.enabled = YES;
    [_backgroundView addSubview:cancelButton];

    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.frame = self.bounds;
    }];
}

@end
