//
//  NSDate+StringParsing.h
//  Puttio
//
//  Created by orta therox on 03/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (StringParsing)
+ (NSDate *)dateWithISO8601String:(NSString *)dateString;
@end
