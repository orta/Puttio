//
//  ConvertToMP4Process.m
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ConvertToMP4Process.h"

@interface ConvertToMP4Process ()
@property  File *file;
@end

@implementation ConvertToMP4Process

+ (ConvertToMP4Process *)processWithFile:(File *)aFile {
    ConvertToMP4Process *this = [[self alloc] init];
    this.file = aFile;
    return this;
}

- (NSString *)primaryDescription {
    return [NSString stringWithFormat:@"Converting %@ for iOS", self.file.displayName];
}

- (void)tick {
    [[PutIOClient sharedClient] getMP4InfoForFile:self.file :^(id userInfoObject) {
        NSString *classString = NSStringFromClass([userInfoObject class]);
        if (![@"NSURLError" isEqualToString:classString] && ![@"NSError" isEqualToString:classString]) {
            NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
            if ([status isEqualToString:@"COMPLETED"]) {
                [self end];
            }
            
            if ([status isEqualToString:@"CONVERTING"]) {
                if ([userInfoObject valueForKeyPath:@"mp4.percent_done"] != [NSNull null]) {
                    _message = nil;
                    self.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                }
            }
            
            if ([status isEqualToString:@"IN_QUEUE"]) {
                _message = @"In Queue";
            }
        }
    }];
}
@end
