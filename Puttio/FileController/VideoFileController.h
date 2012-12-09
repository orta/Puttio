//
//  VideoFileController.h
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileController.h"
#import "BaseFileController.h"
#import "MoviePlayer.h"
#import "OROpenSubtitleDownloader.h"

@class FileInfoViewController;
@interface VideoFileController : BaseFileController <FileController, MoviePlayerDelegate, UIDocumentInteractionControllerDelegate, OROpenSubtitleDownloaderDelegate>
@end
