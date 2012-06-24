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
#import "TestFlight.h"

@implementation ORAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
    [Analytics setup];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:ORDefaultsAreLoaded]) {
        [ORDefaults registerDefaults];
    }
    
    NSLog(@"gfchgchgchgchg");
    if([PutIOClient sharedClient].ready){
        [self showApp];
    }else{
        [self showLogin];
    }
    return YES;
}

- (void)showApp {
    [[PutIOClient sharedClient] startup];
    NSLog(@"startup");
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
    NSLog(@"KK");
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentModalViewController:oauthVC animated:YES];
}

- (void)authorizationDidFinishWithController:(OAuthViewController *)controller {
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    [self showApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
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

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
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
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Puttio.sqlite"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSPersistentStoreCoordinator* psc = __persistentStoreCoordinator;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Migrate datamodel
        NSDictionary *options = nil;
        
        // this needs to match the entitlements and provisioning profile
        NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:@"NETCV7NTVF.com.github.orta.puttio"];
        NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"data"];
        if ([coreDataCloudContent length] != 0) {
            // iCloud is available
            cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
            
            options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                       NSInferMappingModelAutomaticallyOption: @YES,
                       NSPersistentStoreUbiquitousContentNameKey: @"Puttio.store",
                       NSPersistentStoreUbiquitousContentURLKey: cloudURL};
        } else {
            // iCloud is not available
            options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                       NSInferMappingModelAutomaticallyOption: @YES};
        }
        
        NSError *error = nil;
        [psc lock];
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [psc unlock];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"asynchronously added persistent store!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
        });
    });
    
    return __persistentStoreCoordinator;
}

- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc {
    [moc mergeChangesFromContextDidSaveNotification:note]; 
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
