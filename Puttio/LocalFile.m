//
//  LocalFile.m
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "LocalFile.h"

@implementation LocalFile

+ (id)fileWithTXTPath:(NSString *)path {
    LocalFile *file = [[LocalFile alloc] init];
    file.id = [[[path componentsSeparatedByString:@".txt"][0] componentsSeparatedByString:@"/"] lastObject];
    return file;
}

+ (void)finalizeFile:(File *)file {
    [file.name writeToFile:[self fileWithExtension:@"txt" withID:file.id] atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

- (void)deleteItem {
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForFile] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[self.class fileWithExtension:@"txt" withID:self.id] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForFile] error:nil];
}

+ (BOOL)localFileExists:(File *)file {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self fileWithExtension:@"txt" withID:file.id]];
}

+ (NSString *)localPathForMovieWithFile:(File *)file {
    return [self fileWithExtension:@"mp4" withID:file.id];
}


- (NSString *)name {
    return [self displayName];
}

- (NSString *)displayName {
    NSString *path = [self.class fileWithExtension:@"txt" withID:self.id];
    return [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
}

- (NSString *)localPathForFile {
    return [self.class fileWithExtension:@"mp4" withID:self.id];
}

- (NSString *)localPathForScreenshot {
    return [self.class fileWithExtension:@"jpg" withID:self.id];
}

+ (NSString *)fileWithExtension:(NSString *)extension withID:(NSString *)id {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:[id stringByAppendingPathExtension:extension]];
}

- (BOOL)hasPreviewThumbnail {
    return YES;
}

@end
