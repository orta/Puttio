//
//  ORHorizontalImageViewCell.m
//  Puttio
//
//  Created by orta therox on 08/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORHorizontalImageViewCell.h"

@implementation ORHorizontalImageViewCell

+ (CGFloat) cellHeight { return 60; }
+ (CGFloat) cellWidth { return 200; }

- (void)layoutSubviews {
    [super layoutSubviews];
    [imageView setFrame: CGRectMake(-4, 4, 60, 40)];
    [titleLabel setFrame:CGRectMake(64, -4, 140, 60)];
    titleLabel.textAlignment = UITextAlignmentLeft;
}

@end
