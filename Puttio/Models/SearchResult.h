//
//  SearchResult.h
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum cellSelectedState {
    SearchResultNormal,
    SearchResultSending, 
    SearchResultSent,
    SearchResultFailed
};

@interface SearchResult : NSObject

@property (assign) NSInteger ranking;
@property (assign) NSInteger seedersCount;
@property (assign) NSInteger peersCount;

@property (assign) double size;
@property (strong) NSString *hostName;
@property (strong) NSString *torrentURL;
@property (strong) NSString *magnetURL;
@property (strong) NSString *name;
@property (strong) NSString *sizeString;

@property (assign) int selectedState;

- (void)generateRanking;
- (NSString *)representedPath;
- (NSString *)representedSize;

+ (SearchResult *)resultWithArchiveOrgDictionary: (NSDictionary *)item;
+ (SearchResult *)resultWithMininovaDictionary: (NSDictionary *)item;
+ (SearchResult *)resultWithISOHuntDictionary: (NSDictionary *)item;
+ (SearchResult *)resultWithFenopyDictionary: (NSDictionary *)item;
@end
