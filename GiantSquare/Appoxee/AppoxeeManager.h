//
//  AppoxeeViewController.h
//  AppoxeeTest
//
//  Created by sivori on 7/12/10.
//  Copyright 2010 Appoxee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppoxeeDelegate.h"

@class AppoxeeMessage;

@interface AppoxeeManager : NSObject

/**
 * Values to the options dictionary passed to Appoxee at init method
 * Should Appoxee be modal (boolean , YES=modal)
 */
FOUNDATION_EXTERN NSString * const AppoxeeManagerModalParam;

/**
 * If Appoxee isn't modal - select it's view hight (int)
 */
FOUNDATION_EXTERN NSString * const AppoxeeManagerViewHeightParam;

/**
 * 'New mail' sound file name (NSString*)
 */
FOUNDATION_EXTERN NSString * const AppoxeeManagerNewMailSoundFileName;

/**
 * Modal animation type key
 */
FOUNDATION_EXTERN NSString * const AppoxeeManagerViewAnimationTypeParam;
/**
 * Modal animation type possiable values
 */
FOUNDATION_EXTERN NSString * const AppoxeeManagerViewAnimationTypeParam_PageCurl;
FOUNDATION_EXTERN NSString * const AppoxeeManagerViewAnimationTypeParam_VerticalMove;

/**
 * Accessing the Appoxee shared manager
 * @return 'AppoxeeManager' instance.
 */
+ (id) sharedManager;

/**
 * Connection methods for the AppoxeeManager
 */
- (void) initManagerWithDelegate:(id<AppoxeeDelegate>)d andOptions:(NSDictionary*)options;
/**
 * Activate the Appoxee manager after the user's app has launched
 *
 * @see AppoxeeManagerModalParam
 * @see AppoxeeManagerViewHeightParam
 * @see AppoxeeManagerNewMailSoundFileName
 * @see AppoxeeManagerViewAnimationTypeParam
 * @see AppoxeeManagerViewAnimationTypeParam_PageCurl
 * @see AppoxeeManagerViewAnimationTypeParam_VerticalMove
 */
- (BOOL) managerParseLaunchOptions:(NSDictionary *)launchOptions;
/**
 * Register for remote notifications
 * Should call from '- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token'
 *
 * @param (NSData *)token that received from Apple delegate.
 */
- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token;
/**
 * Alert Appoxee about recieving remote notifications
 * Should call from '- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo'
 *
 * @param (NSDictionary *)userInfo that received from Apple delegate.
 */
- (BOOL) didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 * Modal Version
 * For modal version, asks the Appoxee to show inbox on screen
 */
- (void) show;
/**
 * Show 'More Apps' view controller on screen
 *
 * @return YES on success, No if this feature is disabled on the server.
 */
- (BOOL) showMoreAppsViewController;
/**
 * Show 'Feedback' view controller on screen
 *
 * @return YES on success, No if this feature is disabled on the server.
 */
- (BOOL) showFeedbackViewController;
/**
 * You can choose whether to show the MoreApps button on Appoxee's inbox or not.
 *
 * @param show = YES to enable the button on the Inbox, show = NO to diabled it.
 * Default value = YES
 */
- (void) showMoreAppsOnInbox:(BOOL)show; // default value is YES
/**
 * You can choose whether to show the Feedback button on Appoxee's inbox or not.
 *
 * @param show = YES to enable the button on the Inbox, show = NO to diabled it.
 * Default value = YES
 */
- (void) showFeedbackOnInbox:(BOOL)show; // default value is YES

/**
 * Non-Modal Version
 * you can change the view controller's center point and specify it's height using 'AppoxeeManagerViewHeightParam'.
 * Don't change the geometry of the getAppoxeeViewController.view element (ie : frame,bounds,transform etc)
 * On iPad's app TEHRE IS NO SUPPORT FOR NON-MODAL INBOX CONTROLLERS
 *  If you want to create a custom inbox for your iPad app, please use the "-(NSArray *)getInboxMessages".
 *
 * @return UIViewController representing Appoxee's mailbox
 */
- (UIViewController *) getAppoxeeViewController;


/**
 * Ask the Appoxee to recalculate the unread messages badge. This will initiate a call to 'AppoxeeNeedsToUpdateBadge' in the Appoxee delegate.
 */
- (void) recalculateUnreadMessagesBadge;

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////    Badge Methods     //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/**
 * Utility methods which paint a nice badge on a selected view.
 */
- (void) addBadgeToView:(UIView *)badgeView badgeText:(NSString *)badgeText badgeLocation:(CGPoint)badgeLocation;
- (void) addBadgeToView:(UIView *)badgeView badgeText:(NSString *)badgeText badgeLocation:(CGPoint)badgeLocation shouldFlashBadge:(BOOL)shouldFlashBadge;
- (void) addBadgeToView:(UIView *)badgeView badgeText:(NSString *)badgeText badgeLocation:(CGPoint)badgeLocation shouldFlashBadge:(BOOL)shouldFlashBadge withFontSize:(float)fontSize;

-(NSString*)getADID;

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////    Custom Inbox      //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/**
 * 
 * Inbox Messages Methods - using for creating custom inbox UIViewController
 *
 * @return NSArray of AppoxeeMessage Objects
 * @see AppoxeeMessage.h
 */
- (NSArray *) getInboxMessages; // return NSArray of AppoxeeMessage Objects (check AppoxeeMessage.h)
/**
 * Open Appoxee Message on Modal view
 *
 * @param AppoxeeMessage Object
 * @see AppoxeeMessage.h
 */
- (void) openAppoxeeMessage:(AppoxeeMessage *)appoxeeMessage;
/**
 * Delete Appoxee Message
 *
 * @param AppoxeeMessage Object
 * @see AppoxeeMessage.h
 */
- (void) deleteAppoxeeMessage:(AppoxeeMessage *)appoxeeMessage;


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////      Tags API        //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/**
 * Add tags to device
 *
 * @param tagsToAdd - NSArray of NSStrings of the selected tags
 * @param tagsToRemove - NSArray of NSStrings of the selected tags
 *
 * @return YES on success, NO if failed
 */
-(BOOL) addTagsToDevice:(NSArray *)tagsToAdd andRemove:(NSArray *)tagsToRemove;
/**
 * Add tags to device
 * And remove tags from device
 * @param tags - NSArray of NSStrings of the selected tags
 *
 * @return YES on success, NO if failed
 */
-(BOOL) addTagsToDevice:(NSArray *)tags;
/**
 * And remove tags from device
 * @param tags - NSArray of NSStrings of the selected tags
 *
 * @return YES on success, NO if failed
 */
-(BOOL) removeTagsFromDevice:(NSArray*)tags;
/**
 * Get device's tag list from the server
 *
 * @return NSArray of NSStrings
 */
-(NSArray *) getDeviceTags;
/**
 * Get App's tag list from the server
 *
 * @return NSArray of NSStrings
 */
-(NSArray *) getTagList;
/**
 * Clear tags local cache
 */
-(void) clearTagsCache;


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////      Aliases API     //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/**
 * Set device alias
 *
 * @return YES on success, NO if failed
 */
-(BOOL) setDeviceAlias:(NSString*)alias; 
/**
 * Remove device alias
 *
 * @return YES on success, NO if failed
 */
-(BOOL) removeDeviceAlias;  
/**
 * Get device alias
 *
 * @return YES on success, NO if failed
 */
-(NSString *) getDeviceAlias;
/**
 * Clear alias local cache
 */
-(void) clearAliasCache;



//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////    Key-Value API     //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/**
 * Assign key value to device
 *
 * @param NSDictionary - each record has key & value
 *
 * @return YES on success, NO if failed
 *
- (BOOL) assignKeyValueToDevice:(NSDictionary*)dict; 
**
 * Remove keys from device
 *
 * @param NSArray of NSString (keys)
 *
 * @return YES on success, NO if failed
 *
- (BOOL) removeKeysOnDevice:(NSArray *)keys; 
**
 * Get device value according to key
 *
 * @param NSString (key)
 *
 * @return YES on success, NO if failed
 *
- (NSString *) getDeviceKeyValue:(NSString *)key;
**
 * Get key list
 *
 * @return NSArray of NSString (keys)
 *
- (NSArray *) getKeyList;  
*/

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////    Device Info       //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/**
 * Get Device Os Name
 */
- (NSString *) getDeviceOsName;
/**
 * Get Device Os Number
 */
- (NSString *) getDeviceOsNumber;
/**
 * Get Hardware Type
 */
- (NSString *) getHardwareType;
/**
 * Get Device Localization
 */
- (NSString *) getDeviceLocale;
/**
 * Get Device Country
 */
- (NSString *) getDeviceCountry;
/**
 * Get Device Activations
 */
- (int) getDeviceActivations;
/**
 * Get Device inApp Payment
 * 
 * @return nil if not set yet.
 */
- (NSDecimalNumber *) getInAppPayment;
/**
 * Get Num Products Purchased
 */
- (int) getNumProductsPurchased;
/**
 * Increase inApp payment and number of product purchased
 *
 * @param payment (NSDecimalNumber *) 
 * @param numPurchased (int)
 */
- (BOOL) increaseInAppPayment:(NSDecimalNumber*)payment andNumPurchased:(int)numPurchased;
/**
 * Increase number of product purchased
 *
 * @param numPurchased (int)
 */
- (BOOL) increaseNumProductPurchased:(NSDecimalNumber*)payment;

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////    Push Managment    //////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

/**
 * Determines whether push is enabled.
 * Returns
 * True if push is enabled, false otherwise
 **/
- (BOOL) isPushEnabled;

/**
 * Determines whether sound is enabled.
 * Returns
 * A boolean indicated whether sound is enabled.
 **/
- (BOOL) isSoundEnabled;

/**
 * Determines whether vibration is enabled.
 * Returns
 * A boolean indicating whether vibration is enabled
 **/
- (BOOL) isBadgeEnabled;

- (void) setPushEnabled:(BOOL)enabled; // default is Yes
- (void) setSoundEnabled:(BOOL)enabled; // default is Yes
- (void) setBadgeEnabled:(BOOL)enabled; // default is Yes
@end

