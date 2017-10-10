//
//  GSCollageViewController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/15/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>
#import <StoreKit/StoreKit.h>

#import "PhotoPickerViewController.h"
#import "GSFacebookLoginView.h"
#import "GSTutorialOverlayView.h"
#import "GSCollageView.h"
#import "GSCollageController.h"
#import "GSCollageSwitcher.h"
#import "MPInterstitialAdController.h"
#import "GSBuyPopupView.h"

#import "MPAdView.h"

#define MAX_FRAMEWIDTH 15.0
#define LOAD_ACTION_SHEET_TAG 90

@interface GSCollageViewController : GSAbstractViewController <GSCollageViewDelegate, UINavigationControllerDelegate, GSCollageControllerDelegate, GSCollageSwitcherDelegate, PhotoPickerViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, GSTutorialOverlayViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, MPInterstitialAdControllerDelegate, UIDocumentInteractionControllerDelegate, MPAdViewDelegate, GSBuyPopupViewDelegate> {
    
    NSMutableArray *mArrayOfColages;
    
    IBOutlet GSCollageView *mCollageView;
    IBOutlet UIButton *mBackButton;
    IBOutlet UIButton *mPublishButton;
    IBOutlet UIButton *mBuyCollagesButton;
    IBOutlet UIButton *mSwitchButton;
    IBOutlet UILabel *mFrameWidthLabel;
    GSCollageController *mCollageController;
    GSBuyPopupView *mBuyPopupView;
    
    MPInterstitialAdController *mInterstitialAdController;
    MPAdView *mAdView;
    
    GSTutorialType mTutorialType;
    GSWatermarkType mWatermarkType;
    
    NSTimer *mTimer;
    NSTimer *mAdTimer;
    
    NSUInteger mCurrentCollage;
    NSUInteger mCountOfFreeCollages;
    
    CGFloat mFrameWidth;
    
    BOOL isPhotoGetting;
    BOOL mIsPublish;
    BOOL mIsPortraite;
    BOOL mUseHasBoughtCollages;
    BOOL mIsBannerAppear;
    
    GSPurchaseType mPurchaseTag;
}

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

- (void) initAds;
- (void) initCollagesArray;
- (void) initSwitcher;
- (void) initCollageController;
- (void) saveImage:(UIImage*)pImage toAlbum:(NSString*)pName;
- (void) customAlertDidSelectButtonAtIndex:(NSInteger)pIndex;
- (void) startAdTimer;
- (void) stopAdTimer;
- (void) removeAds;
- (void)showAds;

- (IBAction) backPressed;
- (IBAction) donePressed;
- (IBAction) buyCollagesButtonPressed;
- (IBAction) publishPressed;
- (IBAction) helpPressed:(id)pSender;
- (IBAction) shuffleButtonPressed:(id)pSender;
- (IBAction) changeFrameButtonPressed:(id)pSender;
- (IBAction) stopFramePressing;
- (void) showSuccessMessage;
- (void) showErrorMessage;

@end
