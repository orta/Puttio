//
//  ComicFileController.m
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ComicFileController.h"
#import "AFNetworking.h"
#import "FileInfoViewController.h"
#import "UnRAR.h"
#import "MiniZip.h"

enum ComicType {
    ComicTypeZip,
    ComicTypeRar
};

@implementation ComicFileController {
    File *_file;
    int _fileType;
}

+ (BOOL)fileSupportedByController:(File *)aFile {
    NSSet *fileTypes = [NSSet setWithObjects:@"cbr", @"cbz", nil];
    if ([fileTypes containsObject:aFile.extension]) {
        return YES;
    }
    return NO;
}


- (void)setFile:(File *)aFile {
    _file = aFile;
    if ([aFile.extension isEqualToString:@"cbr"]) {
        _fileType = ComicTypeRar;
    }else {
        _fileType = ComicTypeZip;
    }
    
    [self.infoController enableButtons];
//    [self getInfoWithBlock:^(id userInfoObject) {
//        
//    }];
}

- (NSString *)descriptiveTextForFile {
    return @"TEXT";
}

- (NSString *)primaryButtonText {
    return @"Read";
}

- (void)primaryButtonAction:(id)sender {    
    NSString *requestURL = [NSString stringWithFormat:@"http://put.io/v2/files/%@/download", _file.id];   

    [self downloadFileAtPath:requestURL WithCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_file.id];
        NSString *fullPath;
        if (_fileType == ComicTypeRar) {
            fullPath = [NSString stringWithFormat:@"%@.rar", filePath];            
        }else {
            fullPath = [NSString stringWithFormat:@"%@.zip", filePath];                        
        }
        [operation.responseData writeToFile:fullPath atomically:YES];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            if (_fileType == ComicTypeRar) {
                [self openRarAtPath:fullPath];
            } else {
                [self openZipAtPath:fullPath];
            }
        }
        
    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (BOOL)supportsSecondaryButton {
    return NO;
}

- (NSString *)secondaryButtonText {
    return @"Download";
}

- (void)openRarAtPath:(NSString *)path {
    UnRAR *rar = [[UnRAR alloc] initWithArchiveAtPath:path];
    [rar extractToPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%@/", _file.id]];
    NSLog(@"%@",[NSTemporaryDirectory() stringByAppendingFormat:@"%@/", _file.id]);
}

- (void)openZipAtPath:(NSString *)path {
    MiniZip *zip = [[MiniZip alloc] initWithArchiveAtPath:path];
    [zip extractToPath:[NSTemporaryDirectory() stringByAppendingFormat:@"%@/", _file.id]];
    NSLog(@"%@",[NSTemporaryDirectory() stringByAppendingFormat:@"%@/", _file.id]);
}

@end
