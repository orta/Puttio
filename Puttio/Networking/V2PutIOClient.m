//
//  V2PutIOClient.m
//  Puttio
//
//  Created by orta therox on 24/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "V2PutIOClient.h"
#import "ORAppDelegate.h"

@interface V2PutIOClient ()
@property (strong) NSString* apiToken;
@end

@implementation V2PutIOClient
@synthesize apiToken;

+ (id)setup {
    ORAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    V2PutIOClient *api = [V2PutIOClient setupWithManagedObjContext:appDelegate.managedObjectContext
                          withPersistentStoreCoord:appDelegate.persistentStoreCoordinator
                               withManagedObjModel:appDelegate.managedObjectModel
                               withDevelopmentBase:@"http://api.put.io/v2/"
                                withProductionBase:@"http://api.put.io/v2/"];

    if (api) {
        [[NSNotificationCenter defaultCenter] addObserver:api 
                                                 selector:@selector(getAPIToken:) 
                                                     name:OAuthTokenWasSavedNotification 
                                                   object:nil];
        [api getAPIToken:nil];    
    }
    return api;
}    

- (void)getAPIToken:(NSNotification *)notification {
    self.apiToken = [[NSUserDefaults standardUserDefaults] objectForKey:AppAuthTokenDefault];
}

- (BOOL)ready {
    return (self.apiToken != nil);
}

@end
