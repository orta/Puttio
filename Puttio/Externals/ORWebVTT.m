//
//  ORWebVTT.m
//  Puttio
//
//  Created by Orta on 28/09/2013.
//  Copyright (c) 2013 ortatherox.com. All rights reserved.
//

#import "ORWebVTT.h"
#import "SubRip.h"

// https://en.wikipedia.org/wiki/WebVTT#WebVTT
// http://dev.w3.org/html5/webvtt/

// doesn't look too hard, check each line for a  "-->" and if it has it switch "," to "."

@implementation ORWebVTT {
    NSMutableString *_content;
}

//+ (instancetype)webVTTWithSubRipFile:(NSString *)subripPath
//{
//    NSString *originalFile = [NSString stringWithContentsOfFile:subripPath encoding:<#(NSStringEncoding)#> error:<#(NSError *__autoreleasing *)#>]
//}
//
//- (void)saveToFile:(NSString *)filePath
//{
//
//}

@end
