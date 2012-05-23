//
//  SearchResult.m
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchResult.h"
#import "FileSizeUtils.h"

@implementation SearchResult

@synthesize seedersCount, peersCount, hostName, torrentURL, magnetURL, name, ranking, size, sizeString;

- (void)generateRanking {
    self.ranking = seedersCount + (peersCount / 4) ;
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
        return unitStringFromBytes(self.size);
    }
}

@end
