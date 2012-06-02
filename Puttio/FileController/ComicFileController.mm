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
#import "ORAppDelegate.h"
#import "FileSizeUtils.h"
#include <sys/param.h>  
#include <sys/mount.h>  

enum ComicType {
    ComicTypeZip,
    ComicTypeRar
};

@implementation ComicFileController {
    File *_file;
    int _fileType;
    NSString *extractedFolderPath;
    NSArray *comicPages;
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
    
    [self.infoController hideProgress];
    [self.infoController enableButtons];
    [[PutIOClient sharedClient] getInfoForFile:_file :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            fileSize = [[[userInfoObject valueForKeyPath:@"size"] objectAtIndex:0] intValue];
            self.infoController.titleLabel.text = [[userInfoObject valueForKeyPath:@"name"] objectAtIndex:0]; 
//            self.infoController.fileSizeLabel.text = unitStringFromBytes(fileSize);
        }
    }];
    
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
    extractedFolderPath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@/", _file.id];
    if ([rar extractToPath:extractedFolderPath]){
        [self openGalleryViewController];    
    }else {
        
    }
    
}

- (void)openZipAtPath:(NSString *)path {
    MiniZip *zip = [[MiniZip alloc] initWithArchiveAtPath:path];
    extractedFolderPath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@/", _file.id];
    if([zip extractToPath:extractedFolderPath]){
        [self openGalleryViewController];    
    }else{
        #warning failed
    }
    
}

- (void)openGalleryViewController {
    [self findExtractedFolderWithFiles];
    comicPages = [self getComicPagePaths];
    
    FGalleryViewController *controller = [[FGalleryViewController alloc] initWithPhotoSource:self];
    
    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *rootController = (UINavigationController*)appDelegate.window.rootViewController;
    [rootController pushViewController:controller animated:YES];
}

- (void)findExtractedFolderWithFiles {
    NSFileManager *file = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [file contentsOfDirectoryAtPath:extractedFolderPath error:&error];
    if (files.count == 1) {
        extractedFolderPath = [extractedFolderPath stringByAppendingPathComponent:[files objectAtIndex:0]];
        [self findExtractedFolderWithFiles];
        return;
    }
    
    NSLog(@"path = %@", extractedFolderPath);
}

- (NSArray *)getComicPagePaths {
    NSFileManager *file = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [file contentsOfDirectoryAtPath:extractedFolderPath error:&error];
    NSSet *fileTypes = [NSSet setWithObjects:@"jpg", @"jpeg", @"gif", @"png", @"tif", @"tiff", nil];
    NSMutableArray *tempFiles = [NSMutableArray array];
    
    for (NSString *file in files) {
        if ([fileTypes containsObject:[file pathExtension]]) {
            [tempFiles addObject:file];
        }
    }
    return tempFiles;
}
                 
#pragma mark -
#pragma mark Photo Gallery Data Source Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery {
    return comicPages.count;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index {
    return FGalleryPhotoSourceTypeLocal;
}

- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [extractedFolderPath stringByAppendingPathComponent:[comicPages objectAtIndex:index]];
}


@end
