//
//  OpenSubtitleSearchResult.h
//  Puttio
//
//  Created by orta therox on 09/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenSubtitleSearchResult : NSObject

+ (OpenSubtitleSearchResult *)resultFromDictionary:(NSDictionary *)dictionary;

@property (copy) NSString *subtitleID;
@property (copy) NSString *subtitleLanguage;
@property (copy) NSString *iso639Language;
@property (copy) NSString *subtitleDownloadAddress;

@end
