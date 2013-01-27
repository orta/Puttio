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

    NSMutableArray *knownIDs = [NSMutableArray array];
    for (NSString *path in filesInUserDocs) {
        if ([path isEqualToString:@"Puttio.sqlite"]) continue;
        if ([path rangeOfString:@".txt"].location != NSNotFound){
            NSString *fileID = [path componentsSeparatedByString:@"."][0];
            [knownIDs addObject:fileID];
        }
    }

    for (NSString *path in filesInUserDocs) {
        NSString *fileID = [path componentsSeparatedByString:@"."][0];
        if (![knownIDs containsObject:fileID]) {
            [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] error:nil];
        }
    }
}

@end
