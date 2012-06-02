//
//  BaseFileController.h
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileController.h"

@class AFHTTPRequestOperation;
@interface BaseFileController : NSObject <FileController>{
    File *_file;
    NSInteger fileSize;
}

@property (strong) FileInfoViewController *infoController;
@property (strong) File *file;

- (void)getInfoWithBlock:(void(^)(id userInfoObject))onComplete;
- (void)downloadFileAtPath:(NSString*)path WithCompletionBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success andFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
