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
    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    V2PutIOClient *api = [V2PutIOClient setupWithManagedObjContext:appDelegate.managedObjectContext
                          withPersistentStoreCoord:appDelegate.persistentStoreCoordinator
                               withManagedObjModel:appDelegate.managedObjectModel
                               withDevelopmentBase:@"http://api.put.io/"
                                withProductionBase:@"http://api.put.io/"];

    if (api) {
        [[NSNotificationCenter defaultCenter] addObserver:api 
                                                 selector:@selector(getAPIToken:) 
                                                     name:OAuthTokenWasSavedNotification 
                                                   object:nil];
        [api getAPIToken:nil];
        api.actionBlocks = [NSMutableDictionary dictionary];
        [api setPath:@"/v2/files/list" forClass:@"File" requestType:RSHTTPRequestTypeGet];
    }
    return api;
}    

- (void)getAPIToken:(NSNotification *)notification {
    self.apiToken = [[NSUserDefaults standardUserDefaults] objectForKey:AppAuthTokenDefault];
    [self setAPIToken:self.apiToken named:@"oauth_token"];
}

- (void)getFolderAtPath:(NSString*)path :(void(^)(id userInfoObject))onComplete {
    NSString *parentID = nil;
    if ([path isEqualToString:@"/"]) {
        parentID = @"0";
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:parentID forKey:@"parent_id"];
    [self call:@"/v2/files/list" params:params withDelegate:self];
    [self.actionBlocks setObject:onComplete forKey:@"/v2/files/list"];
    
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
