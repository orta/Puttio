//
//  ORImageViewCell.m
//  Puttio
//
//  Created by orta therox on 27/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORImageViewCell.h"
#import "UIImageView+AFNetworking.h"

static UIEdgeInsets ImageContentInsets = {.top = 10, .left = 6, .right = 6, .bottom = 55};

static CGFloat TitleLabelHeight = 40;
static CGFloat SubTitleLabelHeight = 24;

static CGFloat ImageBottomMargin = 10;
static CGFloat TitleBottomMargin = 1;


@implementation ORImageViewCell

@synthesize image;
@synthesize imageURL;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize item = _item;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIColor *black = [UIColor blackColor];
        
        self.opaque = NO;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.opaque = NO;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.opaque = NO;
        
        CGRect imageFrame = frame;
        imageFrame.size.width = CGRectGetWidth(self.frame) - ImageContentInsets.left - ImageContentInsets.right;
        imageFrame.size.height = CGRectGetHeight(self.frame) - ImageContentInsets.bottom - ImageContentInsets.top;
        
        imageFrame.origin.x = ImageContentInsets.left;
        imageFrame.origin.y = ImageContentInsets.top;
        imageView.frame = imageFrame;    
        [self addSubview:imageView];
        
		activityIndicatorView = 
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicatorView sizeToFit];
        [self addSubview:activityIndicatorView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = black;
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.opaque = NO;
        titleLabel.userInteractionEnabled = YES;
        titleLabel.numberOfLines = 2;
        [self addSubview:titleLabel];
        
        subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.textColor = [UIColor redColor];
        subtitleLabel.textAlignment = UITextAlignmentCenter;
        subtitleLabel.backgroundColor = [UIColor whiteColor];
        subtitleLabel.opaque = NO;
        [self addSubview:subtitleLabel];
    }
    return self;
}

- (void)prepareForReuse {
    titleLabel.text = @"";
    subtitleLabel.text = @"";
    self.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (imageView.image) {
        [activityIndicatorView stopAnimating];
        activityIndicatorView.frame = CGRectZero;
    }
    else {
        [activityIndicatorView stopAnimating];
        [activityIndicatorView sizeToFit];
        activityIndicatorView.center = imageView.center;
    }
    if ([_title length]) {
        titleLabel.frame = CGRectMake(ImageContentInsets.left, 
                                      CGRectGetMaxY(imageView.frame) + ImageBottomMargin, 
                                      CGRectGetWidth(self.bounds) - ImageContentInsets.left - ImageContentInsets.right, 
                                      TitleLabelHeight);        
    }
    else {
        titleLabel.frame = CGRectMake(ImageContentInsets.left, 
                                      CGRectGetMaxY(imageView.frame) + ImageBottomMargin, 
                                      CGRectGetWidth(self.bounds) - ImageContentInsets.left - ImageContentInsets.right, 
                                      0);
    }
    subtitleLabel.frame = CGRectMake(ImageContentInsets.left, 
                                     CGRectGetMaxY(titleLabel.frame) + TitleBottomMargin, 
                                     CGRectGetWidth(self.bounds) - ImageContentInsets.left - ImageContentInsets.right, 
                                     SubTitleLabelHeight);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle{
    _subtitle = subtitle;
    subtitleLabel.text = _subtitle;
}

- (void)setImageURL:(NSURL *)anImageURL {
    imageURL = anImageURL;
    [imageView setImageWithURL:anImageURL];
}

@end
