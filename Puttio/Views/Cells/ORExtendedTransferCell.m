//
//  ORExtendedTransferCell.m
//  Puttio
//
//  Created by orta therox on 14/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSimpleProgress.h"
#import "ORExtendedTransferCell.h"

@interface ORExtendedTransferCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToGoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStartedLabel;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *downloadProgress;

@end

@implementation ORExtendedTransferCell

- (void)setTransfer:(Transfer *)transfer {
    _titleLabel.text = [transfer displayName];
    _timeStartedLabel.text = [[transfer estimatedTime] stringValue];
    _timeToGoLabel.text = [transfer createdAt];
    _downloadProgress.progress = [transfer percentDone].floatValue / 100;
    _downloadProgress.isLandscape = YES;
}

@end
