//
//  SearchController.h
//  Puttio
//
//  Created by orta therox on 14/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchController;
@protocol SearchResultsDelegate <NSObject>
- (void)searchController:(SearchController *)controller foundResults:(NSArray *)searchResults;
@end

@interface SearchController : NSObject
@property (weak) NSObject <SearchResultsDelegate> *delegate;
+ (SearchController *)sharedInstance;
+ (void)searchForString:(NSString *)query;
@end
