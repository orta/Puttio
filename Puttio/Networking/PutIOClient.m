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
#import "V1PutIOAPIClient.h"
#import "V2PutIOAPIClient.h"

@interface PutIOClient ()
@property(strong) V1PutIOAPIClient *v1Client;
@property(strong) V2PutIOAPIClient *v2Client;
@end

@implementation PutIOClient

@synthesize v1Client, v2Client;

+ (PutIOClient *)sharedClient {
    static PutIOClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PutIOClient alloc] init];
    });
    
    return _sharedClient;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.v1Client = [V1PutIOAPIClient sharedClient];
    self.v2Client = [V2PutIOAPIClient setup];
    
    return self;
}

- (BOOL)ready {
    return ([self.v1Client ready] && [self.v2Client ready]);
}

- (void)startup {
    [self.v1Client getStreamToken];
}

+ (NSString *)appendOauthToken:(NSString *)inputURL {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:AppAuthTokenDefault];    
    return [NSString stringWithFormat:@"%@?oauth_token=%@", inputURL, token];    
}

+ (NSString *)appendStreamToken:(NSString *)inputURL {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:ORStreamTokenDefault];    
    return [NSString stringWithFormat:@"%@?token=%@", inputURL, token];
}

- (void)getUserInfo:(void(^)(id userInfoObject))onComplete {
    [self.v1Client getUserInfo:^(id userInfoObject) {
        onComplete(userInfoObject);
    }];
}

- (void)getFolder:(Folder *)folder :(void(^)(id userInfoObject))onComplete {
    [self.v2Client getFolder:folder :^(id userInfoObject)  {
        onComplete(userInfoObject);  
    }];
}

- (void)getInfoForFile:(File *)file :(void(^)(id userInfoObject))onComplete {
    [self.v1Client getInfoForFile:file :^(id userInfoObject)  {
        onComplete(userInfoObject);  
    }];
}

- (void)getMP4InfoForFile:(File *)file :(void(^)(id userInfoObject))onComplete {
    [self.v2Client getMP4InfoForFile:file :^(id userInfoObject)  {
        onComplete(userInfoObject);  
    }];
}

- (void)getMessages:(void(^)(id userInfoObject))onComplete {
    [self.v1Client getMessages :^(id userInfoObject) {
        onComplete(userInfoObject);  
    }];
}

- (void)getTransfers:(void(^)(id userInfoObject))onComplete {
    [self.v2Client getTransfers :^(id userInfoObject) {
        onComplete(userInfoObject);  
    }];
}

- (void)requestMP4ForFile:(File*)file {
    [self.v2Client requestMP4ForFile:file];
}


- (void)downloadTorrentOrMagnetURLAtPath:(NSString *)path :(void(^)(id userInfoObject))onComplete {
    [self.v2Client downloadTorrentOrMagnetURLAtPath:path :^(id userInfoObject) {
        onComplete(userInfoObject);
    }];
}
@end
