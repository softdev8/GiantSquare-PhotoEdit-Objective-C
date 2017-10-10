//
//  Global.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk on 2/7/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#ifndef Resume_Global_h
#define Resume_Global_h

#define START_POINT_X 2
#define START_POINT_Y 52
#define SQUARE_SIZE 104

// AFNetworking
#define COCOAPODS_POD_AVAILABLE_AFNetworking
#define COCOAPODS_VERSION_MAJOR_AFNetworking 1
#define COCOAPODS_VERSION_MINOR_AFNetworking 3
#define COCOAPODS_VERSION_PATCH_AFNetworking 2

// Chute-SDK
#define COCOAPODS_POD_AVAILABLE_Chute_SDK
#define COCOAPODS_VERSION_MAJOR_Chute_SDK 0
#define COCOAPODS_VERSION_MINOR_Chute_SDK 0
#define COCOAPODS_VERSION_PATCH_Chute_SDK 1

// DCKeyValueObjectMapping
#define COCOAPODS_POD_AVAILABLE_DCKeyValueObjectMapping
#define COCOAPODS_VERSION_MAJOR_DCKeyValueObjectMapping 1
#define COCOAPODS_VERSION_MINOR_DCKeyValueObjectMapping 4
#define COCOAPODS_VERSION_PATCH_DCKeyValueObjectMapping 0

// Lockbox
#define COCOAPODS_POD_AVAILABLE_Lockbox
#define COCOAPODS_VERSION_MAJOR_Lockbox 1
#define COCOAPODS_VERSION_MINOR_Lockbox 4
#define COCOAPODS_VERSION_PATCH_Lockbox 3

// MBProgressHUD
#define COCOAPODS_POD_AVAILABLE_MBProgressHUD
#define COCOAPODS_VERSION_MAJOR_MBProgressHUD 0
#define COCOAPODS_VERSION_MINOR_MBProgressHUD 7
#define COCOAPODS_VERSION_PATCH_MBProgressHUD 0

#define CHUTE_PICKER_REQUIRED_VERSION 6.0

//Facebook server URL
#define OUR_FACEBOOK_SERVER_URL @"http://ec2-54-218-115-129.us-west-2.compute.amazonaws.com/"

//Mopub ID
#define MOPUB_ID @"2ec27cdca39211e295fa123138070049"
#define FULL_SCREEN_AD_ID @"1321f3dcc2ea11e295fa123138070049"

//RevMob id
#define REVMOB_APP_ID @"5225f53a79e44b76c6000067"

//detect free version
#ifdef FREE
#define MOPUB_ADVERTISMENT @"ON"
#else
#define MOPUB_ADVERTISMENT @"OFF" // OFF
#endif


//iOS5 texts
#define IOS5_ALERT_TITLE_TEXT @"Important note:"
#define IOS5_ALERT_DESCRIPTION @"To load pictures directly from your social accounts you need to update your iOS-version to iOS6 or higher"
#define IOS5_ALERT_DONT_REMIND_BUTTON @"Don’t remind me again"
#define IOS5_ALERT_SUCCESS_BUTTON @"OK"

// social access tokens defines
#define FACEBOOK_ACCES_TOKEN @"facebookCurrentAccessToken"
#define TWITTER_ACCES_TOKEN @"twitterCurrentAccessToken"
#define TWITTER_ACCES_SECRET @"twitterCurrentAccessSecret"
#define TWITTER_ACCES_STATE @"twitterCurrrentAccessState"
#define TWITTER_ACCES_NAME @"twitterCurrentAccessName"

#define TWITTER_ACCOUNTS_ARRAY @"twitterAccountsArray"

#define ALBUM_NAME @"Giant Square"
#define PRIVATE_ALBUM_NAME @"Giant Square Private"
#define SHARE_STRING @"www.fb.com/giantsquare www.thegiantsquare.com"

#define REMOVE_AD_NOTIFICATION @"remove_ad_notification"

#define VKSafeRelease(object) \
if (object != nil) { \
    [object release]; \
    object = nil; \
}

//social appIDs
#ifdef FREE
#define FACEBOOK_APPID @"547313678652585"
#define FLURRY_APIID @"D4T62QJH4T4GMNK26BVG"
#define APPIRATER_APIID @"638402155"
#define APP_SDK_ID @"51bb2a0c500125.74581092"
#define APP_SECRET @"51bb2a0c5003d6.70935148"
#else
#define FACEBOOK_APPID @"312379095547319"  
#define FLURRY_APIID @"QYMZW34S768VJ66277J3"
#define APPIRATER_APIID @"602396401"
#define APP_SDK_ID @"bf08e270-828f-434a-ac50-e91a15a9fbb1"
#define APP_SECRET @"7c10de1f428e2bbb954a957bf1b3d342"
#endif


#define FACEBOOK_USER_NAME @"facebook_user_name"

#define PRODUCT_ID [NSArray arrayWithObjects: @"TGSProversion",@"TGSAdvertisement",@"TGSwatermark", @"TGSFrames", @"TGSFonts", nil]
#define IAP_OLD_PURCHASE @"TGS_AD_1"
#define IAP_PRO_VERSION @"TGSProversion"
#define IAP_ADS_REMOVED @"TGSAdvertisement"
#define IAP_WATERMARK @"TGSwatermark"
#define IAP_FRAMES @"TGSFrames"
#define IAP_FONTS  @"TGSFonts"

//add -DDEBUG flag to c flags
#ifdef DEBUG 
# define DLog(...) NSLog(__VA_ARGS__) 
#else 
# define DLog(...) /* */
#endif 
#define ALog(...) NSLog(__VA_ARGS__)



// degrees and radians
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


//Getting device name
#define IPHONE @"iPhone"
#define IPAD @"iPad"

CG_INLINE NSString *deviceType()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() )
		return IPAD;
	else
		return IPHONE;
#else
	return IPHONE;

#endif
}

// iPhone 5 support
#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)

//Getting is device IOS6
CG_INLINE BOOL isIOS6()
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
		return TRUE;
	else
		return FALSE;
}
typedef enum {
    GSWatermarkTypeFacebookCollage,
    GSWatermarkTypeInstagramCollage,
    GSWatermarkTypeTwitterCollage,
} GSWatermarkType;

typedef enum {
    GSTutorialTypeTwitter,
    GSTutorialTypeFacebookCollage,
    GSTutorialTypeInstagramCollage,
    GSTutorialTypeTwitterCollage,
    GSTutorialTypeFacebook,
    GSTutorialTypeInstagram,
    GSTutorialTypeFacebookAfterPublish,
    GSTutorialTypeMainScreen
} GSTutorialType;

typedef enum {
    GSPurchaseTypeFrames,
    GSPurchaseTypeWatermark,
    GSPurchaseTypeAds,
    GSPurchaseTypeGoPro,
    GSpurchasetypeFonts
} GSPurchaseType;

typedef enum {
    GS_INSTAGRAM_EDIT,
    GS_INSTAGRAM_COLLAGE,
    GS_INSTAGRAM_SQUARE
} GSCategory;

GSCategory global_GSCategory;

//defined for ios version 6.0 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#define IOS_6_VERSION 1
#else
#undef IOS_6_VERSION
#endif

//Set users Default values in system
#define getVal(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define getValDef(key,defaultVal) [[NSUserDefaults standardUserDefaults] objectForKey:key] == nil ? defaultVal : [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define setVal(key,val) [[NSUserDefaults standardUserDefaults] setObject:val forKey:key]; [[NSUserDefaults standardUserDefaults] synchronize]
#define ObjectForKey(dict, key, defaultVal) [dict objectForKey:key] == nil ? defaultVal : [dict objectForKey:key]

#endif
