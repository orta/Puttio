//
//  FileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileInfoViewController.h"
#import "UIImageView+AFNetworking.h"

@interface FileInfoViewController() {
    id _item;
}
@end


@implementation FileInfoViewController 
@synthesize titleLabel;
@synthesize additionalInfoLabel;
@synthesize thumbnailImageView;
@dynamic item;

- (void)setItem:(id)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }
    NSObject <ORDisplayItemProtocol> *object = item;
    titleLabel.text = object.name;
    additionalInfoLabel.text = object.description;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[object.iconURL stringByReplacingOccurrencesOfString:@"shot/" withString:@"shot/b/"]]];

}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setThumbnailImageView:nil];
    [self setAdditionalInfoLabel:nil];
    [super viewDidUnload];
}
- (IBAction)backButton:(id)sender {
}

- (IBAction)streamButton:(id)sender {
}
@end
