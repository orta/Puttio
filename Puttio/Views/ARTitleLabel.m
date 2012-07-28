//
//  ARTitleLabel.m
//  Puttio
//
//  Created by orta therox on 27/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ARTitleLabel.h"

@implementation ARTitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.font = [UIFont titleFontWithSize:self.font.pointSize];
}

@end
