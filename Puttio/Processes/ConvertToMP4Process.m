//
//  ConvertToMP4Process.m
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ConvertToMP4Process.h"

@interface ConvertToMP4Process ()
@property (strong) File *file;
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
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            
            NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
            if ([status isEqualToString:@"COMPLETED"]) {
                [self end];
            }
            
            if ([status isEqualToString:@"CONVERTING"]) {
                if ([userInfoObject valueForKeyPath:@"mp4.percent_done"] != [NSNull null]) {
                    self.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                }
            }
        }
    }];
}
@end
