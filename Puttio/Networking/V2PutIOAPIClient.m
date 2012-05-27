//
//  V2PutIOClient.m
//  Puttio
//
//  Created by orta therox on 24/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

// http://put.io/v2/docs/

#import "V2PutIOAPIClient.h"
#import "PutIONetworkConstants.h"
#import "ORAppDelegate.h"
#import "NSDictionary+ObjectForKey.h"
#import "APP_SECRET.h"

typedef void (^BlockWithCallback)(id userInfoObject);

@interface V2PutIOAPIClient ()
@property (strong) NSMutableDictionary *actionBlocks;
@property (strong) NSString* apiToken;

- (NSArray *)filesAndFoldersFromJSONArray:(NSArray *)dictionaries withParent:(Folder *)folder;
- (void)genericGetAtPath:(NSString *)path :(void(^)(id userInfoObject))onComplete;
@end

@implementation V2PutIOAPIClient 
@synthesize apiToken, actionBlocks;

+ (id)setup {
    V2PutIOAPIClient *api = [[V2PutIOAPIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.put.io/"]];
                          
    if (api) {
        [[NSNotificationCenter defaultCenter] addObserver:api 
                                                 selector:@selector(getAPIToken:) 
                                                     name:OAuthTokenWasSavedNotification 
                                                   object:nil];
        [api getAPIToken:nil];
        api.actionBlocks = [NSMutableDictionary dictionary];
        [api registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return api;
}    

- (void)getAPIToken:(NSNotification *)notification {
    self.apiToken = [[NSUserDefaults standardUserDefaults] objectForKey:AppAuthTokenDefault];
}

- (void)getAccessTokenFromOauthCode:(NSString *)code {
    // https://api.put.io/v2/oauth2/access_token?client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&grant_type=authorization_code&redirect_uri=YOUR_REGISTERED_REDIRECT_URI&code=CODE
    
    NSString *address = [NSString stringWithFormat:PTFormatOauthTokenURL, @"10", APP_SECRET, @"authorization_code", PTCallbackOriginal, code];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[JSON valueForKeyPath:@"access_token"] forKey:AppAuthTokenDefault];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:OAuthTokenWasSavedNotification object:nil userInfo:nil];
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
}

- (void)getFolder:(Folder*)folder :(void(^)(id userInfoObject))onComplete {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.apiToken, @"oauth_token", folder.id, @"parent_id", nil];
    [self getPath:@"/v2/files/list" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (error) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            NSLog(@"json parsing error.");
        }
        if ([[json valueForKeyPath:@"status"] isEqualToString:@"OK"]) {
            onComplete([self filesAndFoldersFromJSONArray:[json valueForKeyPath:@"files"] withParent:folder]);
        }else{
            NSLog(@"%@", NSStringFromSelector(_cmd));
            NSLog(@"server said not ok");
            NSLog(@"request %@", operation.request.URL);
            NSLog(@"data %@", json);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        onComplete(error);        
    }];
}

- (NSArray *)filesAndFoldersFromJSONArray:(NSArray *)dictionaries withParent:(Folder *)parent{
    NSMutableArray *objects = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        
        id contentType = [dictionary objectForKey:@"content_type"];
        if ( contentType == [NSNull null] || [contentType isEqualToString:@"application/x-directory"]) {
            Folder *folder = [Folder object];
            folder.id = [[dictionary objectForKey:@"id"] stringValue];
            folder.name = [dictionary objectForKey:@"name"];
            folder.displayName = [folder.name capitalizedString];
            folder.screenShotURL =  [dictionary objectForKey:@"icon"];
            folder.parentID = [[dictionary objectForKey:@"parent_id"] stringValue];
            folder.size = [NSNumber numberWithInt:0];
            folder.parentFolder = parent;
            [objects addObject:folder];
        }else{
            File *file = [File object];
            file.id = [[dictionary objectForKey:@"id"] stringValue];
            file.name = [dictionary objectForKey:@"name"];
            [file setupDisplayName];
            file.screenShotURL =  [dictionary onlyStringForKey:@"screenshot"];
            if (!file.screenShotURL) {
                file.screenShotURL =  [dictionary onlyStringForKey:@"icon"];
            }
            file.contentType =  [dictionary objectForKey:@"content_type"];
            file.parentID = [[dictionary objectForKey:@"parent_id"] stringValue];
            file.size = [dictionary objectForKey:@"size"];
            [objects addObject:file];
        }
    }
    return objects;
}

- (void)getInfoForFile:(File*)file :(void(^)(id userInfoObject))onComplete {
    NSString *path = [NSString stringWithFormat:@"/v2/files/%@", file.id];
    [self genericGetAtPath:path :^(id userInfoObject) {
        onComplete(userInfoObject);
    }];
}

- (void)getMP4InfoForFile:(File*)file :(void(^)(id userInfoObject))onComplete {
    NSString *path = [NSString stringWithFormat:@"/v2/files/%@/mp4", file.id];
    [self genericGetAtPath:path :^(id userInfoObject) {
        onComplete(userInfoObject);
    }];
}

- (void)getTransfers :(void(^)(id userInfoObject))onComplete {
    [self genericGetAtPath:@"/v2/transfers/list" :^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            NSArray *transfers = [userInfoObject valueForKeyPath:@"transfers"];
            NSMutableArray *returnedTransfers = [NSMutableArray array];
            if (transfers) {
                for (NSDictionary *transferDict in transfers) {
                    Transfer *transfer = [[Transfer alloc] init];
                    transfer.name = [transferDict objectForKey:@"name"];
                    transfer.downloadSpeed =  [transferDict objectForKey:@"down_speed"];
                    transfer.percentDone =  [transferDict objectForKey:@"percent_done"];
                    transfer.estimatedTime = [transferDict objectForKey:@"estimated_time"];
                    [returnedTransfers addObject:transfer];
                }
            }
            onComplete(returnedTransfers);
            return;
        }
        onComplete(userInfoObject);
    }];
}

- (void)requestMP4ForFile:(File*)file {
    NSString *path = [NSString stringWithFormat:@"/v2/files/%@/mp4?oauth_token=%@", file.id, self.apiToken];
    [self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       NSLog(@"failure in requesting MP4 %@", error);
    }];
}

- (void)downloadTorrentOrMagnetURLAtPath:(NSString *)path :(void(^)(id userInfoObject))onComplete {
    NSString *address = [NSString stringWithFormat:@"/v2/transfers/add?oauth_token=%@", self.apiToken];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: path, @"url", nil];

    [self postPath:address parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"downloadTorrentOrMagnetURLAtPath completed %@", json);
        onComplete(json);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure in requesting torrent / magnet %@", error);
        onComplete(error);
    }];
}

#pragma mark internal API gubbins

- (void)genericGetAtPath:(NSString *)path :(void(^)(id userInfoObject))onComplete {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.apiToken, @"oauth_token", nil];
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSError *error= nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (error) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            NSLog(@"json parsing error.");
        }
        onComplete(json);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request %@", operation.request.URL);

        NSLog(@"failure!");
      onComplete(error);        
    }];
}

-(void)apiDidReturn:(id)arrOrDict forRoute:(NSString*)action { 
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([self.actionBlocks objectForKey:action]) {
       BlockWithCallback block = [self.actionBlocks objectForKey:action];
        block(arrOrDict);
    }
}

-(void)apiDidFail:(NSError*)error forRoute:(NSString*)action {
    if ([self.actionBlocks objectForKey:action]) {
        BlockWithCallback block = [self.actionBlocks objectForKey:action];
        block(error);
    }
}

- (BOOL)ready {
    return (self.apiToken != nil);
}

@end
