//
//  ARFileDownloadOperation.h
//  Artsy Folio
//
//  Created by orta therox on 24/07/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface ORFileDownloadOperation : AFHTTPRequestOperation

+ (ORFileDownloadOperation *)fileDownloadFromURL:(NSURL *)url toLocalPath:(NSString *)localPath;
@property BOOL shouldBackupFileToCloud;

@end
