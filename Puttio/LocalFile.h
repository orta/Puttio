//
//  LocalFile.h
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFile : NSManagedObject
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parentID;
@property (nonatomic, retain) NSString * screenShotURL;
@property (nonatomic, retain) NSNumber * watched;

+ (LocalFile *) localFileWithFile:(File *)file;
- (void)deleteItem;
- (NSString *)localPathForFile;
- (NSString *)localPathForScreenshot;
- (BOOL)hasPreviewThumbnail;
@end
