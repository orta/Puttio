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

// take the original method wholesale and add our check for whether we should add the no-backup flag

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __block ORFileDownloadOperation *this = self;

    self.completionBlock = ^ {
        if ([this isCancelled]) {
            return;
        }

        if (this.error) {
            if (failure) {
                dispatch_async(this.failureCallbackQueue ? this.failureCallbackQueue : dispatch_get_main_queue(), ^{
                    failure(this, this.error);
                });
            }
        } else {
            if (success) {
                if (!this.shouldBackupFileToCloud) {
                    [[NSFileManager defaultManager] addSkipBackupAttributeToFileAtPath:self.localPath];
                }
                
                dispatch_async(this.successCallbackQueue ? this.successCallbackQueue : dispatch_get_main_queue(), ^{
                    success(this, this.responseData);
                });
            }
        }
    };
}


@end
