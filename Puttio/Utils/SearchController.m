//
//  SearchController.m
//  Puttio
//
//  Created by orta therox on 14/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchController.h"
#import "AFHTTPRequestOperation.h"

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
    query = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];    
    [self searchISOHunt:query];
    [self searchMininova:query];
}

+ (void)searchISOHunt:(NSString *)query {
    
    NSString *address = [NSString stringWithFormat:@"http://isohunt.com/js/json.php?ihq=%@", query];
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        
        NSArray *results = [self dictionariesForJSONData:responseObject atKeyPath:@"items.list"];
        
        NSMutableArray *searchResults = [NSMutableArray array];
        for (NSDictionary *item in results) {
            //        seedersCount, peersCount, hostName, torrentURL, magenetURL, name, ranking, size;
            SearchResult *result = [[SearchResult alloc] init];
            result.seedersCount = [[item valueForKeyPath:@"Seeds"] intValue];
            result.peersCount = [[item valueForKeyPath:@"leechers"] intValue];
            result.torrentURL = [item valueForKeyPath:@"enclosure_url"];
            NSString *title = [item valueForKeyPath:@"title"];
            result.name = [title stripHTMLtrimWhiteSpace:YES];
            result.hostName = [item valueForKeyPath:@"original_site"];
            result.sizeString = [item valueForKeyPath:@"size"];
            [searchResults addObject:result];
        }
        [self passArrayToDelegate:searchResults];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
        NSLog(@"fail whale %@", error);
    }];
    [operation start];
}

+ (void)searchMininova:(NSString *)query {
    NSString *address = [NSString stringWithFormat:@"http://www.mininova.org/vuze.php?search=%@", query];
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        result = [result stringByReplacingOccurrencesOfString:@"\"hash\"" withString:@",\"hash\""];
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSASCIIStringEncoding] options:0 error:&error];
        NSArray *results = [json objectForKey:@"results"];

        NSMutableArray *searchResults = [NSMutableArray array];
        for (NSDictionary *item in results) {
            SearchResult *result = [[SearchResult alloc] init];
            result.seedersCount = [[item valueForKeyPath:@"seeds"] intValue];
            result.peersCount = [[item valueForKeyPath:@"peers"] intValue];
            result.torrentURL = [item valueForKeyPath:@"download"];
            result.size = [[item valueForKeyPath:@"size"] intValue];
            NSString *title = [item valueForKeyPath:@"title"];
            result.name = [title stripHTMLtrimWhiteSpace:YES];
            result.hostName = @"mininova.org";
            [searchResults addObject:result];
        }
        [self passArrayToDelegate:searchResults];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"fail whale %@", error);
    }];
    [operation start];
}

+ (void)passArrayToDelegate: (NSArray *)results {
    if ([self sharedInstance] && [self sharedInstance].delegate) {
        if ([[self sharedInstance].delegate respondsToSelector:@selector(searchController:foundResults:)]) {
            [[self sharedInstance].delegate searchController:[self sharedInstance] foundResults:results];
        }
    }
}

+ (NSArray *)dictionariesForJSONData:(NSData *)data atKeyPath:(NSString *)keyPath {
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"json parsing error.");
    }
    return [json valueForKeyPath:keyPath];
}

+ (NSString*)getExampleJSON:(NSString*)filename {
    NSString * response = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"json"] encoding:NSASCIIStringEncoding error:nil];
    return response;
}

@end
