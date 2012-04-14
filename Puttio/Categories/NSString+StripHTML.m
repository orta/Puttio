//
//  NSString+StripHTML.m
//  Puttio
//
//  Created by orta therox on 14/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "NSString+StripHTML.h"

@implementation NSString (StripHTML)

- (NSString *)stripHTMLtrimWhiteSpace:(BOOL)trim {    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:self];
    NSString *returnedString = self;
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;                 
        // find end of tag         
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        returnedString = [returnedString stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
        
    } // while //
    
    // trim off whitespace
    return trim ? [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : returnedString;
}

@end
