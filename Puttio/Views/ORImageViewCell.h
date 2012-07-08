//
//  ORImageViewCell.h
//  Puttio
//
//  Created by orta therox on 27/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//


#import "GMGridViewCell.h"

@interface ORImageViewCell : GMGridViewCell

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) id item;
@property (nonatomic, assign) BOOL watched;

@end
