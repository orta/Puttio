//
//  LocalFile.m
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "LocalFile.h"

@implementation LocalFile

+ (LocalFile *) localFileWithFile:(File *)file {
    LocalFile *localFile = [LocalFile object];
    localFile.displayName = file.displayName;
    localFile.id = file.id;
    localFile.name = file.name;
    localFile.parentID = file.parentID;
    
#warning stubbed screenShotURL
    localFile.screenShotURL = file.screenShotURL;
    
    return localFile;
}

- (void)deleteItem {
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForFile] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForScreenshot] error:nil];
    
    [self deleteEntity];
}

- (NSString *)localPathForFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:self.id];
}

- (NSString *)localPathForScreenshot {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:[self.id stringByAppendingPathExtension:@"jpg"]];
}


@end
