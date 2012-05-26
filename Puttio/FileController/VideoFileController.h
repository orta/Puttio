//
//  VideoFileController.h
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileController.h"

@class FileInfoViewController;
@interface VideoFileController : NSObject <FileController>

@property (strong) FileInfoViewController *infoController;
@property (strong) File *file;

@end
