//
//  PutIOClient.m
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "PutIOClient.h"
#import "AFJSONRequestOperation.h"

// http://put.io/v2/docs/
NSString* API_ADDRESS = @"http://api.put.io/v2/";

@implementation PutIOClient

@synthesize apiToken;

+ (PutIOClient *)sharedClient {
    static PutIOClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PutIOClient alloc] initWithBaseURL:[NSURL URLWithString:API_ADDRESS]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setStringEncoding:NSASCIIStringEncoding];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getAPIToken) 
                                                 name:LoggedInNotification 
                                               object:nil];
    return self;
}

- (void)getAPIToken:(NSNotification *)notification {
    self.apiToken = [[NSUserDefaults standardUserDefaults] objectForKey:AppAuthTokenDefault];
}

@end
