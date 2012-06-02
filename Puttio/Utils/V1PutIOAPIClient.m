//
//  PutIOClient.m
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "V1PutIOAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "NSDictionary+JSON.h"

// http://put.io/v2/docs/
NSString* API_V1_ADDRESS = @"http://api.put.io/v1/";

@interface V1PutIOAPIClient ()
@property(strong) NSString* apiKey;
@property(strong) NSString* apiSecret;
@end

@implementation V1PutIOAPIClient

@synthesize apiKey, apiSecret;

+ (V1PutIOAPIClient *)sharedClient {
    static V1PutIOAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[V1PutIOAPIClient alloc] initWithBaseURL:[NSURL URLWithString:API_V1_ADDRESS]];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(getAPICreds:) 
                                                 name:V1TokensWereSavedNotification 
                                               object:nil];
    [self getAPICreds:nil];
    return self;
}

- (void)getAPICreds:(NSNotification*)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.apiKey = [defaults objectForKey:APIKeyDefault];
    self.apiSecret = [defaults objectForKey:APISecretDefault];
}

- (void)getStreamToken {
    NSDictionary *params = [V1PutIOAPIClient paramsForRequestAtMethod:@"acctoken" withParams:[NSDictionary dictionary]];
    [self getPath:@"user" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"error"] boolValue] == NO) {
            NSLog(@"got new token %@", [responseObject valueForKeyPath:@"response.results.token"]);
            [[NSUserDefaults standardUserDefaults] setObject:[responseObject valueForKeyPath:@"response.results.token"] forKey:ORStreamTokenDefault];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"v1 server said not ok %@", error);
        NSLog(@"request %@", operation.request.URL);
    }];
}

- (void)getUserInfo:(void(^)(id userInfoObject))onComplete {
    // no need for params on an info request
    NSDictionary *params = [V1PutIOAPIClient paramsForRequestAtMethod:@"info" withParams:[NSDictionary dictionary]];
    [self getPath:@"user" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"error"] boolValue] == NO) {
            onComplete(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"v1 server said not ok %@", error);
        NSLog(@"request %@", operation.request.URL);
    }];
}

- (void)getFolderWithID:(NSString *)folderID :(void(^)(id userInfoObject))onComplete {
    // no need for params on an info request
    NSDictionary *params = [V1PutIOAPIClient paramsForRequestAtMethod:@"list" withParams:[NSDictionary dictionaryWithObject:folderID forKey:@"parent_id"]];
    [self getPath:@"files" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"error"] boolValue] == NO) {
            onComplete([responseObject valueForKeyPath:@"response.results"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"v1 server said not ok %@", error);
        NSLog(@"request %@", operation.request.URL);
    }];
}

- (void)getInfoForFile:(File *)file :(void(^)(id userInfoObject))onComplete {
    NSDictionary *params = [V1PutIOAPIClient paramsForRequestAtMethod:@"info" withParams:[NSDictionary dictionaryWithObject:file.id forKey:@"id"]];
    [self getPath:@"files" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"error"] boolValue] == NO) {
            onComplete([responseObject valueForKeyPath:@"response.results"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"v1 server said not ok %@", error);
        NSLog(@"request %@", operation.request.URL);
    }];
}

- (void)getMessages:(void(^)(id userInfoObject))onComplete {
    NSDictionary *params = [V1PutIOAPIClient paramsForRequestAtMethod:@"list" withParams:[NSDictionary dictionary]];
    [self getPath:@"messages" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"error"] boolValue] == NO) {
            
            NSArray *messages = [responseObject valueForKeyPath:@"response.results"];
            NSMutableArray *returnedMessages = [NSMutableArray array];
            if (messages) {
                for (NSDictionary *messageDict in messages) {
                    Message *message = [[Message alloc] init];
                    NSString *title = [messageDict objectForKey:@"title"];
                    message.message = [title stripHTMLtrimWhiteSpace:YES];
                    [returnedMessages addObject:message];
                }
            }
            onComplete(returnedMessages);
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"v1 server said not ok %@", error);
        NSLog(@"request %@", operation.request.URL);
    }];
}


- (BOOL)ready {
    return (self.apiKey && self.apiSecret);
}

@end
