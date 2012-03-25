// NSString+Matching.m
//
// Copyright (c) 2012 Michael Dinerstein
// Written for Boundabout (http://www.boundaboutwith.us)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NSString+Matching.h"

@implementation NSString (Matching)

//The string to match is the one with the wildcards
- (BOOL)matches:(NSString *)stringToMatch{
  NSString *matchRest = stringToMatch;
  NSString *selfRest = self;
  
  NSRange wildRange = [matchRest rangeOfString:@":"];
  while (wildRange.length > 0){
    if (wildRange.location >= selfRest.length)   return NO;    //If we overshoot
    
    NSString *soFarMatch = [matchRest substringToIndex:wildRange.location-1];
    NSString *soFarSelf = [selfRest substringToIndex:wildRange.location-1];
    if (![soFarSelf isEqualToString:soFarMatch]){
      return NO;
    }
    
    NSRange slashPosMatch = [[matchRest substringFromIndex:wildRange.location] rangeOfString:@"/"];
    NSRange slashPosSelf = [[selfRest substringFromIndex:wildRange.location] rangeOfString:@"/"];
    
    //If we have a more slashes, there might be more wildcards
    if (slashPosMatch.length > 0 && slashPosSelf.length > 0){
      matchRest = [[matchRest substringFromIndex:wildRange.location] substringFromIndex:slashPosMatch.location];
      selfRest = [[selfRest substringFromIndex:wildRange.location] substringFromIndex:slashPosSelf.location];
      wildRange = [matchRest rangeOfString:@":"];
    }
    else if (slashPosMatch.length > 0 && slashPosSelf.length == 0){
      return NO;
    }
    else{
      //If both do not have slahes, the wild card was at the end of the string. So as long as self doesn't have a slash, we are true
      return YES;
    }
  }
  
  //After all of the wildcards are removed, we need to check for equivalence on the remaining strings
  if ([matchRest isEqualToString:selfRest]){
    return YES;
  }
  else{
    return NO;
  }
}

@end
