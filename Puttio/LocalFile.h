//
//  LocalFile.h
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFile : File
+ (LocalFile *) localFileWithFile:(File *)file;
- (void)deleteItem;
- (NSString *)localPathForFile;
- (NSString *)localPathForScreenshot;
@end
