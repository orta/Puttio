//
//  SearchResult.h
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

// higher is better in the ranking
@property (assign) NSInteger ranking;
@property (assign) NSInteger seedersCount;
@property (assign) NSInteger peersCount;

@property (assign) NSInteger size;
@property (strong) NSString *hostName;
@property (strong) NSString *torrentURL;
@property (strong) NSString *magenetURL;
@property (strong) NSString *name;
@end
