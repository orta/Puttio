//
//  SearchController.m
//  Puttio
//
//  Created by orta therox on 14/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchController.h"
#import "AFHTTPRequestOperation.h"
#import <IGHTMLQuery/IGHTMLQuery.h>
#import "NSString+StringBetweenStrings.h"

static SearchController *sharedInstance;

@interface SearchController ()
@property (assign) int foundNoResultsCount;
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
    sharedInstance.foundNoResultsCount = 0;
    
    query = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    [self searchMininova:query];
    [self searchArchiveOrg:query];
    if([[NSUserDefaults standardUserDefaults] boolForKey:ORUseAllSearchEngines]){
//        [self searchISOHunt:query];
        [self searchFenopy:query];
        [self searchPirateProxies:query];
    }
    [ARAnalytics incrementUserProperty:@"Started Search" byInt:1];
    [ARAnalytics event:@"User Started a Search"];
}

+ (void)searchArchiveOrg:(NSString *)query {
    NSString *address = [NSString stringWithFormat:@"http://archive.org/advancedsearch.php?q=%@", query];
    NSString *end = @"+AND+format%3A%22Archive+BitTorrent%22&fl%5B%5D=collection&fl%5B%5D=downloads&fl%5B%5D=identifier&fl%5B%5D=title&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=50&page=1&indent=yes&output=json&licensurl%3A%28creativecommons%29";
    address = [address stringByAppendingString:end];
    
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        if (!responseObject) {
            [self foundNoResults];
            return;
        }

        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        NSError *error = nil;
        NSData *data = [result dataUsingEncoding:NSASCIIStringEncoding];
        if (!data) {
            [self foundNoResults];
            return;
        }
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *results = [JSON valueForKeyPath:@"response.docs"];
        if (results.count) {
            NSMutableArray *searchResults = [NSMutableArray array];
            for (NSDictionary *dictionary in results) {
                SearchResult * result = [SearchResult resultWithArchiveOrgDictionary:dictionary];

                if (result.seedersCount && ![result.name isEqualToString:@""]) {

                    if([result.name rangeOfString:@"Full Album"].location == NSNotFound ){
                        [searchResults addObject:result];
                    }
                }
            }
            [self passArrayToDelegate:searchResults];
        }else{
            [self foundNoResults];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ARAnalytics incrementUserProperty:@"Archive Org Search Failed" byInt:1];
        [self foundNoResults];
        NSLog(@"fail whale archive org %@", error);
    }];

    [operation start];
}

+ (void)searchPirateProxies:(NSString *)query {

    NSArray *proxies = @[@"http://www.proxybay.de", @"http://tpb.unblocked.co", @"http://www.piratesniper.net", @"http://www.proxybay.eu", @"http://quluxingba.info", @"http://tpb.alb124.me", @"http://piratebay.come.in", @"http://tpb.occupyuk.co.uk", @"http://thepiratebay.tn"];
    NSUInteger randomIndex = arc4random() % [proxies count];
    NSString *proxy = proxies[randomIndex];

    NSString * address = [proxy stringByAppendingFormat:@"/search/%@/0/99/0", query];

    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        if (!responseObject) {
            [self foundNoResults];
            return;
        }

        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        NSString *chop = [result substringBetween:@"<table id=\"searchResult\">" and:@"</table>"];
        NSString *rootElement = [NSString stringWithFormat:@"<html>%@</html>", chop];
        NSMutableArray *searchResults = [NSMutableArray array];

        IGHTMLDocument* htmlDoc = [[IGHTMLDocument alloc] initWithHTMLString:rootElement error:nil];

        IGXMLNodeSet *contents = [htmlDoc queryWithXPath:@"//tr"];

        [contents enumerateNodesUsingBlock:^(IGXMLNode *node, NSUInteger idx, BOOL *stop) {
            __block SearchResult *result = [[SearchResult alloc] init];;
            result.seedersCount = NSNotFound;

            [[node queryWithXPath:@"td/a"] enumerateNodesUsingBlock:^(IGXMLNode *aNode, NSUInteger idx, BOOL *stop) {
                NSString *href = aNode[@"href"];

                if ([href hasPrefix:@"magnet"]) {
                    result.magnetURL = href;
                }
            }];

            [[node queryWithXPath:@"td/div/a"] enumerateNodesUsingBlock:^(IGXMLNode *aNode, NSUInteger idx, BOOL *stop) {
                if ([aNode[@"class"] hasPrefix:@"detLink"] ) {
                    result.name = [aNode[@"title"] stringByReplacingOccurrencesOfString:@"Details for " withString:@""];
                }
            }];

            [[node queryWithXPath:@"td"] enumerateNodesUsingBlock:^(IGXMLNode *aNode, NSUInteger idx, BOOL *stop) {

                if ([aNode[@"align"] isEqualToString:@"right"] ) {
                    if (result.seedersCount == NSNotFound) {
                        result.seedersCount = [aNode.text integerValue];
                    } else {
                        result.peersCount = [aNode.text integerValue];
                    }
                }
            }];

            [[node queryWithXPath:@"td/font"] enumerateNodesUsingBlock:^(IGXMLNode *aNode, NSUInteger idx, BOOL *stop) {
                if (!result.sizeString) {
                    result.sizeString = [aNode.text substringBetween:@"Size" and:@", UL"];
                }
            }];

            result.hostName = @"PirateBay";
            [result generateRanking];

            if ((result.peersCount > 0 || result.seedersCount) && result.name.length ) {
                [searchResults addObject:result];
            }
        }];

        if (searchResults.count) {
            [self passArrayToDelegate:searchResults];
        }else{
            [self foundNoResults];
        }


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ARAnalytics incrementUserProperty:@"PIrate Bay Search Failed" byInt:1];
        [self foundNoResults];
        NSLog(@"fail whale fenopy %@", error);
    }];
    [operation start];
}

+ (void)searchFenopy:(NSString *)query {
    NSString *address = [NSString stringWithFormat:@"http://unblockfenopy.eu/module/search/api.php?keyword=%@&format=json", query];
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        if (!responseObject) {
            [self foundNoResults];
            return;
        }

        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        NSError *error = nil;
        NSData *data = [result dataUsingEncoding:NSASCIIStringEncoding];
        if (!data) {
            [self foundNoResults];
            return;
        }

        NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (results.count) {
            NSMutableArray *searchResults = [NSMutableArray array];
            for (NSDictionary *dictionary in results) {
                SearchResult * searchResult = [SearchResult resultWithFenopyDictionary:dictionary];
                if (searchResult.seedersCount > 0) {
                    [searchResults addObject:searchResult];
                }
            }
            [self passArrayToDelegate:searchResults];
        }else{
            [self foundNoResults];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ARAnalytics incrementUserProperty:@"Fenopy Search Failed" byInt:1];
        [self foundNoResults];
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
        if (!responseObject) {
            [self foundNoResults];
            return;
        }

        NSArray *results = [self dictionariesForJSONData:responseObject atKeyPath:@"items.list"];
        if (results.count) {
            NSMutableArray *searchResults = [NSMutableArray array];
            for (NSDictionary *item in results) {
                SearchResult *result = [SearchResult resultWithISOHuntDictionary:item];
                if (result.seedersCount > 0) {
                    [searchResults addObject:result];
                }            }
            [self passArrayToDelegate:searchResults];
        }else{
            [self foundNoResults];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ARAnalytics incrementUserProperty:@"Isohunt Search Failed" byInt:1];
        [self foundNoResults];
//        NSLog(@"fail whale %@", error);
    }];
    [operation start];
}

+ (void)searchMininova:(NSString *)query {
    NSString *address = [NSString stringWithFormat:@"http://www.mininova.org/vuze.php?search=%@", query];
    NSURL *url = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        if (!responseObject) {
            [self foundNoResults];
            return;
        }

        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        result = [result stringByReplacingOccurrencesOfString:@"\"hash\"" withString:@",\"hash\""];
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSASCIIStringEncoding] options:0 error:&error];
        NSArray *results = json[@"results"];
        if (results.count) {
            NSMutableArray *searchResults = [NSMutableArray array];
            for (NSDictionary *item in results) {
                SearchResult *result = [SearchResult resultWithMininovaDictionary:item];
                if (result.seedersCount > 0) {
                    [searchResults addObject:result];
                }
            }
            [self passArrayToDelegate:searchResults];
        }else{
            [self foundNoResults];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ARAnalytics incrementUserProperty:@"Mininova Search Failed" byInt:1];
        [self foundNoResults];
        NSLog(@"fail whale %@", error);
    }];
    [operation start];
}

+ (void)foundNoResults {
    sharedInstance.foundNoResultsCount++;
    BOOL allSearchEngines = [[NSUserDefaults standardUserDefaults] boolForKey:ORUseAllSearchEngines];
    int neededResults = allSearchEngines? 4 : 2;
    
    if (neededResults == sharedInstance.foundNoResultsCount) {
        if ([self sharedInstance] && [self sharedInstance].delegate) {
            if ([[self sharedInstance].delegate respondsToSelector:@selector(searchControllerFoundNoResults:)]) {
                [[self sharedInstance].delegate searchControllerFoundNoResults:[self sharedInstance]];
            }
        }
    }
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
