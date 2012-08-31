//
//  ORSearchCell.m
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSearchCell.h"
#import "UIColor+PutioColours.h"

@implementation ORSearchCell
@synthesize fileNameLabel, fileSizeLabel, seedersLabel;

- (void)prepareForReuse {
    [super prepareForReuse];
    self.userInteractionEnabled = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.seedersLabel.textColor = [UIColor putioLightGray];
}

- (void)userHasSelectedFile {
    self.contentView.backgroundColor = [UIColor putioBlue];
    self.seedersLabel.textColor = [UIColor whiteColor];
    self.seedersLabel.text = @"Requesting download";
    self.fileSizeLabel.text = @"";
    self.userInteractionEnabled = NO;    
}

- (void)userHasFailedToAddFile {
    self.contentView.backgroundColor = [UIColor putioRed];
    self.seedersLabel.textColor = [UIColor whiteColor];
    self.seedersLabel.text = @"Adding file failed";
    self.fileSizeLabel.text = @"";
    self.userInteractionEnabled = YES;
}

- (void)userHasAddedFile {
    self.contentView.backgroundColor = [UIColor putioDarkBlue];
    self.seedersLabel.textColor = [UIColor putioBlue];
    self.seedersLabel.text = @"Added file to transfers";  
    self.fileSizeLabel.text = @"";
}

@end
