//
//  ComicFileController.h
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileController.h"
#import "BaseFileController.h"
#import "FGalleryViewController.h"

@interface ComicFileController : BaseFileController <FileController, FGalleryViewControllerDelegate>

@end
