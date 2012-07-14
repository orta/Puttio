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

// these are here so the subclasses can access them if needs be

@interface BaseFileController : NSObject <FileController>{
    File *_file;
    NSInteger fileSize;
}

@property FileInfoViewController *infoController;
@property File *file;

- (void)markFileAsViewed;
- (void)downloadFileAtPath:(NSString*)path backgroundable:(BOOL)showTransferInBG withCompletionBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success andFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
