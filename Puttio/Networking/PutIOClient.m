//
//  PutIOClient.m
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "PutIOClient.h"
#import "AFJSONRequestOperation.h"
#import "ORAppDelegate.h"
#import "V1PutIOClient.h"
#import "V2PutIOClient.h"

// http://put.io/v2/docs/
NSString* API_ADDRESS = @"http://api.put.io/v2/";

@interface PutIOClient ()
@property(strong) V1PutIOClient *v1Client;
@property(strong) V2PutIOClient *v2Client;
@end

@implementation PutIOClient

@synthesize v1Client, v2Client;

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
    
    self.v1Client = [V1PutIOClient sharedClient];
    self.v2Client = [V2PutIOClient setup];
    return self;
}

- (BOOL)ready {
    return ([self.v1Client ready] && [self.v2Client ready]);
}

@end
