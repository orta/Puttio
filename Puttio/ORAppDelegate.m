//
//  ORAppDelegate.m
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORAppDelegate.h"

#import "ORDefaults.h"
#import "StatusViewController.h"
#import "SearchViewController.h"
#import "BrowsingViewController.h"
#import "OAuthViewController.h"

@implementation ORAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    [Analytics setup];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:ORLoggedOutDefault];
    if (![defaults boolForKey:ORDefaultsAreLoaded]) {
        [ORDefaults registerDefaults];
    }
    
    if([PutIOClient sharedClient].ready){
        [self showApp];
    }else{
        [self showLogin];
    }
    return YES;
}

- (void)showApp {
    [Analytics setUserAccount:[[NSUserDefaults standardUserDefaults] objectForKey:ORUserAccountNameDefault]];
    [Analytics incrementCounter:@"User App Launched" byInt:1];

    [[PutIOClient sharedClient] startup];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SearchViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"searchView"];
    
    UINavigationController *rootNav = (UINavigationController*)self.window.rootViewController;
    BrowsingViewController *canvas = (BrowsingViewController *)rootNav.topViewController;

    [canvas addChildViewController:searchVC];
    [canvas.view addSubview:searchVC.view];
    [searchVC viewWillAppear:NO];
}

- (void)showLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];

    OAuthViewController *oauthVC = [storyboard instantiateViewControllerWithIdentifier:@"oauthView"];
    oauthVC.delegate = self;
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentModalViewController:oauthVC animated:NO];
}

- (void)authorizationDidFinishWithController:(OAuthViewController *)controller {
    [[NSUserDefaults standardUserDefaults] setObject:controller.usernameTextfield.text forKey:ORUserAccountNameDefault];
    
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    [self showApp];

    UINavigationController *rootNav = (UINavigationController*)self.window.rootViewController;
    BrowsingViewController *canvas = (BrowsingViewController *)rootNav.topViewController;
    [canvas setupRootFolder];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
- (NSManagedObjectContext *)managedObjectContext {
	
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            [moc setPersistentStoreCoordinator: coordinator];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        }];
        __managedObjectContext = moc;
    }
    
    return __managedObjectContext;
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    
	NSLog(@"Merging in changes from iCloud...");
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    [moc performBlock:^{
        
        [moc mergeChangesFromContextDidSaveNotification:notification];
        
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"SomethingChanged"
                                                                            object:self
                                                                          userInfo:[notification userInfo]];
        
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Puttio" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if((__persistentStoreCoordinator != nil)) {
        return __persistentStoreCoordinator;
    }
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSPersistentStoreCoordinator *psc = __persistentStoreCoordinator;
    
    // Set up iCloud in another thread:
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString *iCloudEnabledAppID = @"NETCV7NTVF.com.github.orta.puttio";
        NSString *dataFileName = @"Puttio.sqlite";
        
        NSString *iCloudDataDirectoryName = @"Data.nosync";
        NSString *iCloudLogsDirectoryName = @"Logs";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
        NSURL *iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
        
        if (iCloud) {
            
            NSLog(@"iCloud is working");
            
            NSURL *iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent:iCloudLogsDirectoryName]];
            
            NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
            NSLog(@"dataFileName = %@", dataFileName);
            NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
            NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);
            NSLog(@"iCloud = %@", iCloud);
            NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);
            
            if([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
                NSError *fileSystemError;
                [fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:&fileSystemError];
                if(fileSystemError != nil) {
                    NSLog(@"Error creating database directory %@", fileSystemError);
                }
            }
            
            NSString *iCloudData = [[[iCloud path]
                                     stringByAppendingPathComponent:iCloudDataDirectoryName]
                                    stringByAppendingPathComponent:dataFileName];
            
            NSLog(@"iCloudData = %@", iCloudData);
            
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            [options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
            [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
            
            [psc lock];
            
            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:iCloudData]
                                    options:options
                                      error:nil];
            
            [psc unlock];
        }
        else {
            NSLog(@"iCloud is NOT working - using a local store");
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            
            [psc lock];
            
            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:localStore
                                    options:options
                                      error:nil];
            [psc unlock];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:self userInfo:nil];
        });
    });
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:ORLoggedOutDefault]) {
        exit(YES);
    }
}
@end
