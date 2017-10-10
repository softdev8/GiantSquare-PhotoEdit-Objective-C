//
//  GSAppDelegate.h
//  GiantSquare
//
//  Created by roman.andruseiko on 12/20/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Appoxee.h"
#import <iAd/iAd.h>
#import <FacebookSDK/FacebookSDK.h>
@class GSCustomNavigationController;
@class GSMainViewController;
@interface GSAppDelegate : UIResponder <UIApplicationDelegate, AppoxeeDelegate, ADBannerViewDelegate, UIAlertViewDelegate>{
    GSMainViewController *mMainViewController;
	GSCustomNavigationController *mNavigationController;
    NSInteger mBadgeNumber;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readwrite) NSInteger badgeNumber;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
