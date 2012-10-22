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
        // dont do anything for now
    }
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
