//
//  ConvertToMP4Process.m
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ConvertToMP4Process.h"

@interface ConvertToMP4Process ()
@property  PKFile *file;
@end

@implementation ConvertToMP4Process {
    BOOL _waiting;
}

+ (ConvertToMP4Process *)processWithFile:(File *)aFile {
    ConvertToMP4Process *this = [[self alloc] initWithFile:aFile];
    this.file = aFile;
    return this;
}

- (NSString *)primaryDescription {
    return [NSString stringWithFormat:@"Converting %@ for iOS", self.file.displayName];
}

- (void)tick {
    [super tick];
    
    if (_file && !_waiting) {
        _waiting = YES;

        [[PutIOClient sharedClient] getMP4InfoForFile:_file :^(PKMP4Status *status) {

            switch (status.mp4Status) {
                case PKMP4StatusCompleted:
                    [self end];
                    break;
                case PKMP4StatusConverting:
                    _message = nil;
                    self.processProgress = status.progress.floatValue;
                    break;
                case PKMP4StatusQueued:
                    _message = @"In Queue";
                    break;
                case PKMP4StatusNotAvailable:
                    _message = @"Not Available";
                default:
                    _message = [NSString stringWithFormat:@"%@ Conversion Error", [UIDevice deviceString]];
                    [self end];
                    break;
            }
            _waiting = NO;

        } failure:^(NSError *error) {
            _waiting = NO;
        }];
    }
}

@end
