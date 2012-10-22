//
//  ORMigration.m
//  Puttio
//
//  Created by orta therox on 22/10/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORMigration.h"

@implementation ORMigration

+ (void)migrate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastVersion = [defaults integerForKey:ORMigrationVersionDefault];

    if (lastVersion < 1.22) {
        
        NSString *dataFileName = @"Puttio.sqlite";
        NSString *localStore = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName] path];
        NSString *iCloudDataDirectoryName = @"Data.nosync";
        NSString *iCloudLogsDirectoryName = @"Logs";

        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
        NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];

        if (iCloud) {
            NSString *iCloudData = [[[iCloud path]
                                     stringByAppendingPathComponent:iCloudDataDirectoryName]
                                    stringByAppendingPathComponent:dataFileName];

            if ([[NSFileManager defaultManager] fileExistsAtPath:iCloudData]) {

                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:iCloudData error:&error];
                if (error) {
                    NSLog(@"error deleting CD model %@", error.localizedDescription);
                }

                [defaults setFloat:1.22 forKey:ORMigrationVersionDefault];
            } else {
                NSLog(@"could not find data model");
            }
        }
        
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:iCloud error:&error];
    }
}


+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
