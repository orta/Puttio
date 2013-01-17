//
//  ARFileDownloadOperation.m
//  Artsy Folio
//
//  Created by orta therox on 24/07/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//

#import "ORFileDownloadOperation.h"
#import "NSFileManager+SkipBackup.h"

@interface ORFileDownloadOperation ()
@property (strong) NSString *localPath;
@end

@implementation ORFileDownloadOperation

+ (ORFileDownloadOperation *)fileDownloadFromURL:(NSURL *)url toLocalPath:(NSString *)localPath {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    ORFileDownloadOperation *this = [[self alloc] initWithRequest:request];
    this.localPath = localPath;
    this.outputStream = [NSOutputStream outputStreamToFileAtPath:localPath append:NO];
    this.shouldBackupFileToCloud = NO;
    return this;
}

@end
