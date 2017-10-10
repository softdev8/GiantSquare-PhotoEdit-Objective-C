//
//  GSAppDelegate.m
//  GiantSquare
//
//  Created by roman.andruseiko on 12/20/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import "GSAppDelegate.h"
#import "GSMainViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GSCustomNavigationController.h"
#import "TapjoyConnect.h"
#import "GSSettingsViewController.h"
#import "Global.h"
#import "MPAdConversionTracker.h"
#import "Flurry.h"
#import "SBJson.h"
#import "Appirater.h"
#import <RevMobAds/RevMobAds.h>
#import "GCConfiguration.h"


@implementation GSAppDelegate

- (void)dealloc
{
    [mMainViewController release];
    [mNavigationController release];
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize badgeNumber;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //check for first start
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"firstStart"]) {
        setVal(@"firstStart", @"NO");
        setVal(@"publicPostsEnabled", @"YES");
        setVal(FACEBOOK_USER_NAME, @"My Profile");

#ifdef FREE
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IAP_OLD_PURCHASE];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IAP_ADS_REMOVED];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IAP_WATERMARK];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IAP_FRAMES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IAP_PRO_VERSION];
#else
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_PRO_VERSION];
#endif
    }
    
    //set bought state for old users
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_OLD_PURCHASE]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_PRO_VERSION];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
#ifdef FREE
    [RevMobAds startSessionWithAppID:@"5225f53a79e44b76c6000067"];
#else
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_OLD_PURCHASE];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_PRO_VERSION];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
#endif
    
    //appoxee init
    [[AppoxeeManager sharedManager] initManagerWithDelegate:self andOptions:NULL];
    [[AppoxeeManager sharedManager] managerParseLaunchOptions:launchOptions];
    
    //register for remote notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //load root viewcontroller
    mMainViewController = [[GSMainViewController alloc] initWithNibName:@"GSMainViewController" bundle:nil];
    mNavigationController = [[GSCustomNavigationController alloc] initWithRootViewController:mMainViewController];
    mNavigationController.isPortrait = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = mNavigationController;
    [self.window makeKeyAndVisible];
    
    //initAppirater
    [Appirater setAppId:APPIRATER_APIID];
    [Appirater setDaysUntilPrompt:10];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    //init Tapjoy
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectFail:) name:TJC_CONNECT_FAILED object:nil];
    [TapjoyConnect requestTapjoyConnect:@"6e67d0a2-334b-4515-b02c-44bb95e520b9" secretKey:@"FDTYG33JC4Rn3W7BAzfE"];
    
    //init MoPub
    [[MPAdConversionTracker sharedConversionTracker] reportApplicationOpenForApplicationID:@"agltb3B1Yi1pbmNyDQsSBFNpdGUYmtauFgw"];
    
    //init Flurry
    [Flurry startSession:FLURRY_APIID];
   

    
    [GCConfiguration configuration];
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //Appirater Entered Foreground
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
	[FBSession.activeSession close];
    [self saveContext];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // Place your code for what to do when the registration fails
    NSLog(@"Registration Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Forward the call to the AppoxeeManager
    if([[AppoxeeManager sharedManager] didReceiveRemoteNotification:userInfo])
    {
        // If the manager handled the event.. return
        return;
    }

    //Otherwise do what you want because the push didn't came from Appoxee.
    
    
    if ([userInfo valueForKey:@"aps"] && [[userInfo valueForKey:@"aps"] valueForKey:@"alert"]) {
        NSDictionary *lAlert = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        
        if ([lAlert objectForKey:@"body"]) {
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Update" message:[NSString stringWithFormat:@"%@",[lAlert objectForKey:@"body"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [lAlertView show];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{
    // Forward the call to the AppoxeeManager
    NSString *deviceToken = [[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    DLog(@"token: %@", deviceToken);
    [[AppoxeeManager sharedManager] didRegisterForRemoteNotificationsWithDeviceToken:token];
    
    
    // REGISTER DEVICE     
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@register_device/",OUR_FACEBOOK_SERVER_URL]]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [lRequest setHTTPMethod:@"POST"];
    
    NSString *lFreeAppStateString = @"";
    
    if ([MOPUB_ADVERTISMENT isEqualToString:@"ON"]) {
        lFreeAppStateString = @"true";
    } else {
        lFreeAppStateString = @"false";
    }

    NSString *lDeviceToken = [[[[token description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];

    NSString *lJsonString = [NSString stringWithFormat:@"{\"free\":\"%@\",\"device_id\":\"%@\"}",lFreeAppStateString,lDeviceToken];
    
    DLog(@"lJson :%@",lJsonString);
    
    NSData *requestData = [lJsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [lRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [lRequest setHTTPBody:requestData];
    
    
    [NSURLConnection
     sendAsynchronousRequest:lRequest
     queue:[NSOperationQueue currentQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         if (error == nil) {
             if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                 NSMutableString *lResultStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 DLog(@"registration request result:%@",lResultStr);
                 
                 [lResultStr release];
             }
         } else {
             DLog(@"registration request error :%@",error.localizedDescription);
         }
         
     }];
}

#pragma mark - Appoxee delegate
- (NSString *)AppoxeeDelegateAppSDKID {
    return APP_SDK_ID;
}

- (NSString *)AppoxeeDelegateAppSecret {
    return APP_SECRET;
}

- (void) AppoxeeNeedsToUpdateBadge:(int)badgeNum hasNumberChanged:(BOOL)hasNumberChanged {
    //Here you should update your display to let the user know about the unread messages.
    //Here's an example code which uses Appoxee's inherent badge view:
//    NSString *badgeText = NULL;
//    if(badgeNum > 0)
//    {
//        badgeText = [NSString stringWithFormat:@"%d",badgeNum];
//    }
    mBadgeNumber = badgeNum;
    
    //Use the Appoxee "helper" method to display the badge on a button.
    //Make sure the button is not null (meaning that your view's nib file is already loaded).
    
    //If your Appoxxe delegate receives this method prior to loading of the UIView on which the
    //badge will be display (in this case 'AppoxeeButton') then please save the badgeNum and
    //put it on the view after it finished loading.
    
//    [[AppoxeeManager sharedManager] addBadgeToView:self.viewController.inboxBadgeView
//                                         badgeText:badgeText
//                                     badgeLocation:CGPointMake(-15,0)
//                                  shouldFlashBadge:hasNumberChanged];
    
    
    //Please note that you can modify the location of the badge on your UIView using the
    //badgeLoaction param. In this case we put the badge at the top left most corner of
    //AppoxeeButton view.
    
    //Here for example we use the badgeNum to update the external app badge.
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNum;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgeNumberChanged" object:nil];
}

- (void)AppoxeeDelegateReciveAppoxeeClosed {
    //Implement your own code.
    //This method is called when the Appoxee client has been closed.
    //This method will only be fired while the Appoxee is in modal operation mode.
}

- (void)AppoxeeDelegateReciveAppoxeeRequestFocus {
    //Implement your own code.
    //This method is called when the Appoxee client wants to show. It is used mostly when
    //activating Appoxee in a non-modal operation.
}

- (void)appDidOpenFromPushNotification:(NSDictionary *)userInfo {
    NSLog(@"appDidOpenFromPushNotification: %@",userInfo);
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"appDidOpenFromPushNotification" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
}

#pragma mark - Save context

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    return UIInterfaceOrientationMaskPortrait;
//}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GiantSquare" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GiantSquare.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark TapjoyConnect Observer methods

-(void) tjcConnectSuccess:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy Connect Succeeded");
}

-(void) tjcConnectFail:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy Connect Failed");
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Facebook openUrl handling
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url
                             sourceApplication:sourceApplication];
    
    // add app-specific handling code here
    return wasHandled;
}

#pragma mark -AlertView delegate method-
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
         if ([MOPUB_ADVERTISMENT isEqualToString:@"ON"]) {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/the-giant-square-free/id638402155"]];
         } else {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/the-giant-square-free/id602396401"]];
         }
    }
}
@end
