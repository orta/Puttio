//
//  RarFileController.m
//  Puttio
//
//  Created by David Grandinetti on 6/2/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "RarFileController.h"

@implementation RarFileController

+ (BOOL)fileSupportedByController:(File *)aFile {
    NSSet *fileTypes = [NSSet setWithObjects:@"rar", nil];
    if ([fileTypes containsObject:aFile.extension]) {
        return YES;
    }
    return NO;
}

- (NSString *)primaryButtonText {
    return @"Not Implemented";
}

- (void)primaryButtonAction:(id)sender {
    //
    // 1 - build up a list of rar files in this folder [.rar,.r00.r01,...]
    //

    //
    // 2 - make a call to start the extraction.
    //

    //
    // 3 - subsequent calls to check status of extractions if this view is left open.
    //
}

- (BOOL)supportsSecondaryButton {
    return NO;
}

@end
