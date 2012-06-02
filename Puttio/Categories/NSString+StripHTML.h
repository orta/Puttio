//
//  NSString+StripHTML.h
//  Puttio
//
//  Created by orta therox on 14/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StripHTML)
- (NSString *)stripHTMLtrimWhiteSpace:(BOOL)trim;
@end
