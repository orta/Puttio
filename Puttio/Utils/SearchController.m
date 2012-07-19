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
+ (void)searchFenopy:(NSString *)query;
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
    [self searchMininova:query];

    if([[NSUserDefaults standardUserDefaults] boolForKey:ORUseAllSearchEngines]){
        [self searchISOHunt:query];
        [self searchFenopy:query];
    }
    [Analytics incrementCounter:@"Started Search" byInt:1];
    [Analytics event:@"User Started a Search"];
}

+ (void)searchFenopy:(NSString *)query {
    NSString *address = [NSString stringWithFormat:@"http://fenopy.eu/module/search/api.php?keyword=%@&format=json", query];
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        NSError *error = nil;
        NSArray *results = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSASCIIStringEncoding] options:0 error:&error];

        NSMutableArray *searchResults = [NSMutableArray array];
        for (NSDictionary *dictionary in results) {
            SearchResult * searchResult = [SearchResult resultWithFenopyDictionary:dictionary];
            [searchResults addObject:searchResult];
        }
        [self passArrayToDelegate:searchResults];
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Analytics incrementCounter:@"Fenopy Search Failed" byInt:1];
        NSLog(@"fail whale fenopy %@", error);

    }];
    [operation start];
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
            SearchResult *result = [SearchResult resultWithISOHuntDictionary:item];
            [searchResults addObject:result];
        }
        [self passArrayToDelegate:searchResults];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Analytics incrementCounter:@"Isohunt Search Failed" byInt:1];
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
        NSArray *results = json[@"results"];

        NSMutableArray *searchResults = [NSMutableArray array];
        for (NSDictionary *item in results) {
            SearchResult *result = [SearchResult resultWithMininovaDictionary:item];
            [searchResults addObject:result];
        }
        [self passArrayToDelegate:searchResults];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Analytics incrementCounter:@"Mininova Search Failed" byInt:1];
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

@end
