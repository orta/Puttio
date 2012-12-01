//
//  LocalFile.m
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "LocalFile.h"

@implementation LocalFile

@dynamic id, name, parentID, displayName, screenShotURL, watched;

+ (LocalFile *) localFileWithFile:(File *)file {
    LocalFile *localFile = [LocalFile object];
    localFile.displayName = file.displayName;
    localFile.id = file.id;
    localFile.name = file.name;
    localFile.parentID = file.parentID;
    
    localFile.screenShotURL = file.screenshot;
    return localFile;
}

- (void)deleteItem {
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForFile] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForScreenshot] error:nil];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    [self deleteEntity];
    
    if ([context persistentStoreCoordinator].persistentStores.count) {
        [context save:nil];
    }
}

- (NSString *)localPathForFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:[self.id stringByAppendingPathExtension:@"mp4"]];
}

- (NSString *)localPathForScreenshot {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:[self.id stringByAppendingPathExtension:@"jpg"]];
}

- (BOOL)hasPreviewThumbnail {
    return YES;
}

@end
