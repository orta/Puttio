//
//  ORDownloadCleanup.m
//  Puttio
//
//  Created by orta therox on 03/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORDownloadCleanup.h"
#import "LocalFile.h"

@implementation ORDownloadCleanup

+ (void)cleanup {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *filesInUserDocs = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error) {
        NSLog(@"error %@", error.localizedDescription);
        return;
    }
    for (NSString *path in filesInUserDocs) {
        if ([path isEqualToString:@"Puttio.sqlite"]) continue;

        NSString *fileID = [path componentsSeparatedByString:@"."][0];
        if (![LocalFile findFirstByAttribute:@"id" withValue:fileID]) {
            NSLog(@"removing %@", fileID);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] error:&error];
            if (error) {
                NSLog(@"delete error %@", error.localizedDescription);
            }
        }
    }
}

@end
