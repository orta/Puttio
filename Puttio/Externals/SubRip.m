//
//  SubRip.m
//
/*
 This software is licensed under the terms of the BSD license:
 
 Copyright (c) 2011, Sam Stigler
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */ 

#import "SubRip.h"

@implementation SubRip

@dynamic totalCharacterCountOfText;
@synthesize subtitleItems;

-(SubRip *)initWithFile:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        return [self initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

-(SubRip *)initWithURL:(NSURL *)fileURL encoding:(NSStringEncoding)encoding error:(NSError **)error {
    if ([fileURL checkResourceIsReachableAndReturnError:error] == YES) {
        NSData *data = [NSData dataWithContentsOfURL:fileURL
                                             options:NSDataReadingMappedIfSafe
                                               error:error];
        return [self initWithData:data encoding:encoding];
    } else {
        return nil;
    }
}

-(SubRip *)initWithData:(NSData *)data {
    return [self initWithData:data encoding:NSUTF8StringEncoding];
}

-(SubRip *)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    NSString *str = [[NSString alloc] initWithData:data encoding:encoding];
    return [self initWithString:str];
}

-(SubRip *)initWithString:(NSString *)str {
    if (str.length == 0) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        self.subtitleItems = [NSMutableArray arrayWithCapacity:100];
        
        //add a blank text SubRipItem as index 0
        SubRipItem *indexZeroItem=[SubRipItem new];
        indexZeroItem.text= @" ";
        indexZeroItem.startTime = CMTimeMake(0, 1);
        indexZeroItem.endTime = CMTimeMake(0.2, 1);;
        [self.subtitleItems addObject:indexZeroItem];
        
        BOOL success = [self _populateFromString:str];
        if (!success) {
            return nil;
        }
    }
    
    return self;
}
  
- (void)parseTimecodeString:(NSString *)timecodeString intoSeconds:(NSInteger *)totalNumSeconds milliseconds:(NSInteger *)milliseconds {
    NSArray *timeComponents = [timecodeString componentsSeparatedByString:@":"];
    
    NSInteger hours = [(NSString *)[timeComponents objectAtIndex:0] integerValue];
    NSInteger minutes = [(NSString *)[timeComponents objectAtIndex:1] integerValue];
    
    NSArray *secondsComponents = [(NSString *)[timeComponents objectAtIndex:2] componentsSeparatedByString:@","];
    NSInteger seconds = [(NSString *)[secondsComponents objectAtIndex:0] integerValue];
    
    *milliseconds = [(NSString *)[secondsComponents objectAtIndex:1] integerValue];
    *totalNumSeconds = (hours * 3600) + (minutes * 60) + seconds;
}

- (CMTime)parseIntoCMTime:(NSString *)timecodeString {
    NSInteger milliseconds;
    NSInteger totalNumSeconds;
    
    [self parseTimecodeString:timecodeString
                  intoSeconds:&totalNumSeconds
                 milliseconds:&milliseconds];
    
    CMTime startSeconds = CMTimeMake(totalNumSeconds, 1);
    CMTime millisecondsCMTime = CMTimeMake(milliseconds, 1000);
    CMTime time = CMTimeAdd(startSeconds, millisecondsCMTime);
    
    return time;
}

// returns YES if successful, NO if not succesful.
// assumes that str is a correctly-formatted SRT file.
-(BOOL)_populateFromString:(NSString *)str {
    NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
    
    SubRipItem __block *cur = [SubRipItem new];
    SubRipScanPosition __block scanPosition = SubRipScanPositionArrayIndex;
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        // skip over blank lines.
        NSRange r = [line rangeOfCharacterFromSet:alphanumericCharacterSet];
        if (r.location != NSNotFound) {
            BOOL actionAlreadyTaken = NO;
            
            if (scanPosition == SubRipScanPositionArrayIndex) {
                scanPosition = SubRipScanPositionTimes; // skip past the array index number.
                actionAlreadyTaken = YES;
            }
            
            if ((scanPosition == SubRipScanPositionTimes) && (!actionAlreadyTaken)) {
                NSArray *times = [line componentsSeparatedByString:@" --> "];
                if (times.count > 1) {
                    NSString *beginning = [times objectAtIndex:0];
                    NSString *ending = [times objectAtIndex:1];

                    cur.startTime = [self parseIntoCMTime:beginning];
                    cur.endTime = [self parseIntoCMTime:ending];
                }
                
                scanPosition = SubRipScanPositionText;
                actionAlreadyTaken = YES;
            }
            
            if ((scanPosition == SubRipScanPositionText) && (!actionAlreadyTaken)) {
                NSString *prevText = cur.text;
                if (prevText == nil) {
                    cur.text = line;
                } else {
                    cur.text = [cur.text stringByAppendingFormat:@"\n%@", line];
                }
                scanPosition = SubRipScanPositionText;
            }
        }
        else {
            if (CMTIME_IS_VALID(cur.startTime) && CMTIME_IS_VALID(cur.endTime) && cur.text) {
                [subtitleItems addObject:cur];
            }
            cur = [SubRipItem new];
            scanPosition = SubRipScanPositionArrayIndex;
        }
    }];
    
    if (scanPosition == SubRipScanPositionText) {
        if (CMTIME_IS_VALID(cur.startTime) && CMTIME_IS_VALID(cur.endTime) && cur.text) {
            [subtitleItems addObject:cur];
        }
    }
    
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"SRT file: %@", self.subtitleItems];
}

-(NSUInteger)indexOfSubRipItemWithStartTime:(CMTime)theTime {
//    return [self indexOfSubRipItemWithStartTime:(theTime.value / theTime.timescale)];
    return nil;
}

-(NSUInteger)indexOfSubRipItemWithStartTimeInterval:(NSInteger)desiredTime {
    NSInteger __block desiredTimeInSeconds = desiredTime;
    
    NSUInteger index = [self.subtitleItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ((desiredTimeInSeconds >= [(SubRipItem *)obj startTimeInSeconds]) &&
            (desiredTimeInSeconds <= [(SubRipItem *)obj endTimeInSeconds])) {
            return true;
        } else {
            return false;
        }
    }];


    //When the CMTime is not found, it result NSNotFound. The return value will become a big number.
    //It always happens when the audio at the beginning, the CMTime is very small.
    //So add a SubRipItem at index 0 when init a SubRip, in this SubRipItem make the textLine @" "(show nothing); so that when the index is NSNotFound, it can set index as 0

    if (index==NSNotFound) {
        return 0;
    }else{
        return index;
    }

}

-(NSUInteger)indexOfSubRipItemWithCharacterIndex:(NSUInteger)idx {
    if (idx >= self.totalCharacterCountOfText) {
        return NSNotFound;
    }
    NSUInteger currentCharacterCount = 0;
    NSUInteger currentItemIndex = 0;
    SubRipItem *cur = [self.subtitleItems objectAtIndex:currentItemIndex];
    while (currentCharacterCount < idx) {
        currentCharacterCount += cur.text.length;
        currentItemIndex++;
    }
    return currentItemIndex;
}

-(NSUInteger)totalCharacterCountOfText {
    NSUInteger totalLength = 0;
    for (SubRipItem *cur in self.subtitleItems) {
        totalLength += cur.text.length;
    }
    return totalLength;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:subtitleItems forKey:@"subtitleItems"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    self.subtitleItems = [decoder decodeObjectForKey:@"subtitleItems"];
    return self;
}

@end

@implementation SubRipItem

@synthesize startTime = _startTime, endTime = _endTime, text = _text, uniqueID = _uniqueID;
@dynamic startTimeString, endTimeString;

- (id)init {
    self = [super init];
    if (self) {
        _uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    return self;
}

-(NSString *)startTimeString {
    return [self _convertCMTimeToString:_startTime];
}

-(NSString *)endTimeString {
    return [self _convertCMTimeToString:_endTime];
}

-(NSString *)_convertCMTimeToString:(CMTime)theTime {
    // Need a string of format "hh:mm:ss". (No milliseconds.)
    NSInteger seconds = theTime.value / theTime.timescale;
    NSDate *date1 = [NSDate new];
    NSDate *date2 = [NSDate dateWithTimeInterval:seconds sinceDate:date1];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *converted = [[NSCalendar currentCalendar] components:unitFlags fromDate:date1 toDate:date2 options:0];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:6];
    if ([converted hour] < 10) {
        [str appendString:@"0"];
    }
    [str appendFormat:@"%ld:", (long)[converted hour]];
    if ([converted minute] < 10) {
        [str appendString:@"0"];
    }
    [str appendFormat:@"%ld:", (long)[converted minute]];
    if ([converted second] < 10) {
        [str appendString:@"0"];
    }
    [str appendFormat:@"%ld", (long)[converted second]];
    return str;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ ---> %@\n%@", self.startTimeString, self.endTimeString, self.text];
}
            
-(NSInteger)startTimeInSeconds {
    return _startTime.value / _startTime.timescale;
}

-(NSInteger)endTimeInSeconds {
    return _endTime.value / _endTime.timescale;
}

-(double)startTimeDouble {
    return (double)_startTime.value / _startTime.timescale;
}

-(double)endTimeDouble {
    return (double)_endTime.value / _endTime.timescale;
}

-(BOOL)containsString:(NSString *)str {
    NSRange searchResult = [_text rangeOfString:str options:NSCaseInsensitiveSearch];
    if (searchResult.location == NSNotFound) {
        if ([str length] < 9) {
            searchResult = [[self startTimeString] rangeOfString:str options:NSCaseInsensitiveSearch];
            if (searchResult.location == NSNotFound) {
                searchResult = [[self endTimeString] rangeOfString:str options:NSCaseInsensitiveSearch];
                if (searchResult.location == NSNotFound) {
                    return false;
                } else {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            return false;
        }
    } else {
        return true;
    }
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCMTime:_startTime forKey:@"startTime"];
    [encoder encodeCMTime:_endTime forKey:@"endTime"];
    [encoder encodeObject:_text forKey:@"text"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    _startTime = [decoder decodeCMTimeForKey:@"startTime"];
    _endTime = [decoder decodeCMTimeForKey:@"endTime"];
    _text = [decoder decodeObjectForKey:@"text"];
    return self;
}
            
@end