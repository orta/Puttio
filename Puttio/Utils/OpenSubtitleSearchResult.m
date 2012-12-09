//
//  OpenSubtitleSearchResult.m
//  Puttio
//
//  Created by orta therox on 09/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "OpenSubtitleSearchResult.h"

@implementation OpenSubtitleSearchResult

+ (OpenSubtitleSearchResult *)resultFromDictionary:(NSDictionary *)dictionary {
    OpenSubtitleSearchResult *object = [[OpenSubtitleSearchResult alloc] init];

    object.subtitleID = dictionary[@"IDSubtitleFile"];
    object.subtitleLanguage = dictionary[@"SubLanguageID"];
    object.iso639Language = dictionary[@"ISO639"];
    object.subtitleDownloadAddress = dictionary[@"SubDownloadLink"];
    
    return object;
}

@end
