//
//  V2PutIOClient.m
//  Puttio
//
//  Created by orta therox on 24/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

// http://put.io/v2/docs/

#import "V2PutIOClient.h"
#import "ORAppDelegate.h"

typedef void (^BlockWithCallback)(id userInfoObject);

@interface V2PutIOClient ()
@property (strong) NSMutableDictionary *actionBlocks;
@property (strong) NSString* apiToken;
@end

@implementation V2PutIOClient 
@synthesize apiToken, actionBlocks;

+ (id)setup {
    V2PutIOClient *api = [[V2PutIOClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.put.io/"]];
                          
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

- (void)getFolderWithID:(NSString*)folderID :(void(^)(id userInfoObject))onComplete {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.apiToken, @"oauth_token", folderID, @"parent_id", nil];
    [self getPath:@"/v2/files/list" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (error) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            NSLog(@"json parsing error.");
        }
        
        if ([[json valueForKeyPath:@"status"] isEqualToString:@"OK"]) {
            onComplete([json valueForKeyPath:@"files"]);
            NSLog(@"data %@", json);

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
