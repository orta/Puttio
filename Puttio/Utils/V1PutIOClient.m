//
//  PutIOClient.m
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "V1PutIOClient.h"
#import "AFJSONRequestOperation.h"
#import "NSDictionary+JSON.h"

// http://put.io/v2/docs/
NSString* API_V1_ADDRESS = @"http://api.put.io/v1/";

@implementation V1PutIOClient
@synthesize apiKey, apiSecret;

+ (V1PutIOClient *)sharedClient {
    static V1PutIOClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[V1PutIOClient alloc] initWithBaseURL:[NSURL URLWithString:API_V1_ADDRESS]];
    });
    
    return _sharedClient;
}

+ (NSDictionary *)paramsForRequestAtMethod:(NSString *)method withParams:(NSDictionary *)params {
    // http://api.put.io/v1/user?method=info&request={"api_key":"YOUR_API_KEY","api_secret":"YOUR_API_SECRET","params":{}} 

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:method forKey:@"method"];
    NSMutableDictionary *request = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self sharedClient].apiKey, @"api_key", [self sharedClient].apiSecret, @"api_secret", nil];
    [request setObject:params forKey:@"params"];
    [dict setObject:[request toJSONString] forKey:@"request"];
    return dict;
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
    
    return self;
}

@end
