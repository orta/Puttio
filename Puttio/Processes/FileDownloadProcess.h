//
//  FileDownloadProcess.h
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BaseProcess.h"

@class AFHTTPRequestOperation;
@interface FileDownloadProcess : BaseProcess

+ (FileDownloadProcess *)processWithHTTPRequest:(AFHTTPRequestOperation *)operation andFile:(File *)file;
@end
