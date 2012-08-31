//
//  SearchResult.m
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchResult.h"
#import "UIDevice+SpaceStats.h"

@implementation SearchResult

+ (SearchResult *)resultWithArchiveOrgDictionary: (NSDictionary *)item {
    SearchResult *result = [[SearchResult alloc] init];
    result.seedersCount = [[item valueForKeyPath:@"downloads"] intValue];
    result.peersCount = 1;
    // http://archive.org/download/catalegdelsmanus00atenuoft/catalegdelsmanus00atenuoft_archive.torrent
    NSString *path = @"http://archive.org/download/%@/%@_archive.torrent";
    result.torrentURL = [NSString stringWithFormat:path, [item valueForKeyPath:@"identifier"],[item valueForKeyPath:@"identifier"]];
    result.name = [item valueForKeyPath:@"title"];
    result.hostName = @"archive.org";
    result.sizeString = @"Archive.org";
    return result;
}


+ (SearchResult *)resultWithMininovaDictionary: (NSDictionary *)item {
    SearchResult *result = [[SearchResult alloc] init];
    result.seedersCount = [[item valueForKeyPath:@"seeds"] intValue];
    result.peersCount = [[item valueForKeyPath:@"peers"] intValue];
    result.torrentURL = [item valueForKeyPath:@"download"];
    result.size = [[item valueForKeyPath:@"size"] doubleValue];
    NSString *title = [item valueForKeyPath:@"title"];
    result.name = [title stripHTMLtrimWhiteSpace:YES];
    result.hostName = @"mininova.org";
    [result generateRanking];

    return result;
}

+ (SearchResult *)resultWithISOHuntDictionary: (NSDictionary *)item {
    SearchResult *result = [[SearchResult alloc] init];
    result.seedersCount = [[item valueForKeyPath:@"Seeds"] intValue];
    result.peersCount = [[item valueForKeyPath:@"leechers"] intValue];
    result.torrentURL = [item valueForKeyPath:@"enclosure_url"];
    NSString *title = [item valueForKeyPath:@"title"];
    result.name = [title stripHTMLtrimWhiteSpace:YES];
    result.hostName = [item valueForKeyPath:@"original_site"];
    result.sizeString = [item valueForKeyPath:@"size"];
    [result generateRanking];

    return result;
}

+ (SearchResult *)resultWithFenopyDictionary: (NSDictionary *)item {
    SearchResult *result = [[SearchResult alloc] init];
    result.seedersCount = [[item valueForKeyPath:@"seeder"] intValue];
    result.peersCount = [[item valueForKeyPath:@"leechers"] intValue];
    result.torrentURL = [item valueForKeyPath:@"torrent"];
    NSString *title = [item valueForKeyPath:@"name"];
    result.name = [title stripHTMLtrimWhiteSpace:YES];
    result.hostName = @"Fenopy";
    result.size = [[item valueForKeyPath:@"size"] doubleValue];
    
    if ([[item valueForKeyPath:@"verified"] integerValue] == 1) {
         result.ranking = result.seedersCount + (result.peersCount / 4) * 4;
    }else {
        [result generateRanking];
    }
    return  result;
}

- (void)generateRanking {
    self.ranking = _seedersCount + (_peersCount / 4) ;
}

- (NSString *)representedPath {
    if (self.torrentURL) {
        return self.torrentURL;
    }
    if (self.magnetURL) {
        return self.magnetURL;
    }
    return nil;
}

- (NSString *)representedSize {
    if (self.sizeString) {
        return self.sizeString;
    }else {
        return [UIDevice humanStringFromBytes:self.size];
    }
}

@end
