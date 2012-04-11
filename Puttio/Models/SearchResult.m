//
//  SearchResult.m
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

@synthesize seedersCount, peersCount, hostName, torrentURL, magenetURL, name, ranking, size;

- (void)generateRanking {
    self.ranking = 99;
}

@end
