//
//  SearchController.m
//  Puttio
//
//  Created by orta therox on 14/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchController.h"

static SearchController *sharedInstance;

@interface SearchController ()
+ (void)searchISOHunt:(NSString *)query;
+ (void)searchMininova:(NSString *)query;
@end

@implementation SearchController

@synthesize delegate;

+ (SearchController *)sharedInstance {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void)searchForString:(NSString *)query {
    [self searchISOHunt:query];
    [self searchMininova:query];
}

+ (void)searchISOHunt:(NSString *)query {
    NSString *JSONString = [self getExampleJSON:@"isohunt"];
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSASCIIStringEncoding] options:0 error:&error];
    if (error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"json parsing error.");
    }
    
    NSArray *results = [json valueForKeyPath:@"items.list"];
    NSMutableArray *searchResults = [NSMutableArray array];
    for (NSDictionary *item in results) {
//        seedersCount, peersCount, hostName, torrentURL, magenetURL, name, ranking, size;
        SearchResult *result = [[SearchResult alloc] init];
        result.seedersCount = [[item valueForKeyPath:@"Seeds"] intValue];
        result.peersCount = [[item valueForKeyPath:@"leechers"] intValue];
        result.torrentURL = [item valueForKeyPath:@"enclosure_url"];
        result.name = [item valueForKeyPath:@"title"];
        result.hostName = [item valueForKeyPath:@"original_site"];
        [searchResults addObject:result];
    }
    
    if ([self sharedInstance] && [self sharedInstance].delegate) {
        if ([[self sharedInstance].delegate respondsToSelector:@selector(searchController:foundResults:)]) {
            [[self sharedInstance].delegate searchController:[self sharedInstance] foundResults:searchResults];
        }
    }
}

+ (void)searchMininova:(NSString *)query {
    NSString *JSONString = [self getExampleJSON:@"mininova"];
}

+ (NSString*)getExampleJSON:(NSString*)filename {
    NSString * response = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"] encoding:NSASCIIStringEncoding error:nil];
    return response;
}

@end
