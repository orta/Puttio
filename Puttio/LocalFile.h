//
//  LocalFile.h
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFile : NSObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;

+ (id)fileWithTXTPath:(NSString *)path;
+ (void)finalizeFile:(File *)file;
+ (BOOL)localFileExists:(File *)file;
+ (NSString *)localPathForMovieWithFile:(File *)file;

- (void)deleteItem;

- (NSString *)localPathForFile;
- (NSString *)localPathForScreenshot;
- (BOOL)hasPreviewThumbnail;
@end
