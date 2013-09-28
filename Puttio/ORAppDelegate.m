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
#import "LoginViewController.h"
#import "ModalZoomView.h"
#import "APP_SECRET.h"
#import "ORMigration.h"
#import "ORPasteboardParser.h"
#import "ORDownloadCleanup.h"
#import "MSVCLeakHunter.h"

@implementation ORAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [ORMigration migrate];
    [ARAnalytics  setupWithAnalytics:@{
        ARTestFlightAppToken : TESTFLIGHT_SECRET,
        ARMixpanelToken: MIXPANEL_TOKEN,
        ARCrashlyticsAPIKey: CRASHLYTICS_API_KEY
     }];

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
    [ARAnalytics identifyUserWithID:[[NSUserDefaults standardUserDefaults] objectForKey:ORUserAccountNameDefault] andEmailAddress:nil];
    [ARAnalytics incrementUserProperty:@"User App Launched" byInt:1];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SearchViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"searchView"];
    
    UINavigationController *rootNav = (UINavigationController*)self.window.rootViewController;
    BrowsingViewController *canvas = (BrowsingViewController *)rootNav.topViewController;
    canvas.searchVC = searchVC;
    
    [canvas addChildViewController:searchVC];
    [canvas.view addSubview:searchVC.view];
    [searchVC didMoveToParentViewController:canvas];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:ORVideoFinishedNotification object:nil];
}

- (void)showLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];

    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    loginVC.delegate = self;

    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentModalViewController:loginVC animated:NO];
}

- (void)authorizationDidFinishWithController:(LoginViewController *)controller {
    [[NSUserDefaults standardUserDefaults] setObject:controller.usernameTextfield.text forKey:ORUserAccountNameDefault];
    
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    [self showApp];

    UINavigationController *rootNav = (UINavigationController *)self.window.rootViewController;
    BrowsingViewController *canvas = (BrowsingViewController *)rootNav.topViewController;
    [canvas setupRootFolder];
}

- (void)movieFinished:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double currentMinutes = [defaults doubleForKey:ORTotalVideoDuration];

    NSNumber *extraMinutesNumber = notification.userInfo[ORVideoDurationKey];
    currentMinutes += [extraMinutesNumber doubleValue];
    [defaults setDouble:currentMinutes forKey:ORTotalVideoDuration];
    [defaults synchronize];

    [ARAnalytics incrementUserProperty:@"RevisedTotalTimeWatched" byInt:extraMinutesNumber.integerValue];

    if (currentMinutes > (5 * 60) && ![defaults boolForKey:ORHasShownReviewNagOneDefault]) {
        [ModalZoomView fadeOutViewAnimated:NO];
        [self performSelector:@selector(showNag) withObject:nil afterDelay:0.2];
    }
}

- (void)showNag {
    NSString *identifier = [UIDevice isPad]? @"nagView" : @"nagPhoneView";
    [ModalZoomView showWithViewControllerIdentifier:identifier];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ORHasShownReviewNagOneDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Core Data / iCloud stuff


- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [ARAnalytics event:@"Save CD Context Error" withProperties:@{@"error": @(error.code)}];
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
        moc.mergePolicy = [[NSMergePolicy alloc] initWithMergeType: NSMergeByPropertyObjectTrumpMergePolicyType];

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
        @try {
            // remove any LocalFiles because they used to be core data objects, so they could be in iCloud
            // but now they cause a crasher. Should only happen to oldbies

            NSMutableSet *inserts = [[notification userInfo][@"inserted"] mutableCopy];
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return ([[evaluatedObject description] rangeOfString:@"LocalFile"].location == NSNotFound);
            }];

            NSMutableDictionary *dict = [[notification userInfo] mutableCopy];
            dict[@"inserted"] = [inserts filteredSetUsingPredicate:predicate];

            NSNotification *copyNotification = [NSNotification notificationWithName:notification.name object:notification.object userInfo:dict];


            [moc mergeChangesFromContextDidSaveNotification:copyNotification];
            NSNotification* refreshNotification = [NSNotification notificationWithName:ORReloadGridNotification
                                                                                object:self
                                                                              userInfo:[notification userInfo]];

            [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];

        }
        @catch (NSException *exception) {
            NSLog(@"Exception in merging changes in iCloud %@", exception);
        }
        @finally { }
        [ORDownloadCleanup cleanup];
    }];
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
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
            
//            NSLog(@"iCloudEnabledAppID = %@",iCloudEnabledAppID);
//            NSLog(@"dataFileName = %@", dataFileName);
//            NSLog(@"iCloudDataDirectoryName = %@", iCloudDataDirectoryName);
//            NSLog(@"iCloudLogsDirectoryName = %@", iCloudLogsDirectoryName);
//            NSLog(@"iCloud = %@", iCloud);
//            NSLog(@"iCloudLogsPath = %@", iCloudLogsPath);

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
            
//            NSLog(@"iCloudData = %@", iCloudData);

            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            [options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
            [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
            
            [psc lock];
            NSError *error = nil;
            [psc addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[NSURL fileURLWithPath:iCloudData]
                                    options:options
                                      error:nil];
            if (error) {
                NSLog(@"Core Data error %@", error.localizedDescription);
            }
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
            [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadGridNotification object:self userInfo:nil];
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
