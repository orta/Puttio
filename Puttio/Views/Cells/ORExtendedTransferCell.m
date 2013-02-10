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
#import "NSDate+StringParsing.h"

@interface ORExtendedTransferCell (){
    UIView *_backgroundView;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;

@end

@implementation ORExtendedTransferCell

- (void)setTransfer:(Transfer *)transfer {
    _titleLabel.text = [transfer displayName];

    NSString *status = [[transfer statusMessage] stringByReplacingOccurrencesOfString:@"This download turned out to be larger than your available space." withString:@"Not enough space."];

    NSString *downloadSpeed = [UIDevice humanStringFromBytes:transfer.downSpeed.doubleValue];
    NSDate *transferDate = [NSDate dateWithISO8601String:transfer.createdAt];
    _additionalInfoLabel.textAlignment = UITextAlignmentLeft;

    UIImage *image = nil;
    switch (transfer.transferStatus) {
        case PKTransferStatusDownloading:
            image = [UIImage imageNamed:@"TransferDownloading"];
            _additionalInfoLabel.textAlignment = UITextAlignmentRight;
            _additionalInfoLabel.text = [NSString stringWithFormat:@"%@%% - %@", transfer.percentDone.stringValue, downloadSpeed];
            break;

        case PKTransferStatusCompleted:
            image = [UIImage imageNamed:@"TransferComplete"];
            if (transferDate) {
                _additionalInfoLabel.text = [self daysAgoSinceDate:transferDate];

            }
            break;

        case PKTransferStatusSeeding:
            image = [UIImage imageNamed:@"TransferUploading"];
            _additionalInfoLabel.text = @"Completed";
            if (transferDate) {
                _additionalInfoLabel.text = [self daysAgoSinceDate:transferDate];
            }
            break;

        case PKTransferStatusError:
            image = [UIImage imageNamed:@"TransferError"];
            _additionalInfoLabel.text = status;
            break;

        default:
            image = nil;
            _additionalInfoLabel.text = status;
    }
    _statusImageView.image = image;
}

- (NSString *)daysAgoSinceDate:(NSDate *)date {
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];

    int secondsInADay = 3600*24;
    int daysDiff = abs(timeInterval/secondsInADay);

    if (daysDiff == 0) {
        return @"Today.";
    }
    return [NSString stringWithFormat:@"%i days ago.", daysDiff];
}

- (void)prepareForReuse {
    self.alpha = 1;
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
}

- (void)deletedTransfer {
    CGRect buttonFrame = [[_backgroundView subviews][0] frame];
    ORTitleLabel *label = [[ORTitleLabel alloc] initWithFrame:buttonFrame];
    label.text = @"Removed";
    label.textAlignment = UITextAlignmentCenter;
    _statusImageView.image = nil;
    [[_backgroundView subviews][0] removeFromSuperview];
    [_backgroundView addSubview:label];
}

- (void)showCancelButtonWithTarget:(id)target {
    if (_backgroundView) return;
    
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
