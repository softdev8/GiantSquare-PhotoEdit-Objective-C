//
//  GSMainViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 12/20/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "GSBuyPopupView.h"
#import <StoreKit/StoreKit.h>
#import "Global.h"

@interface GSMainViewController : GSAbstractViewController <UIAlertViewDelegate, MPAdViewDelegate, GSBuyPopupViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate>{
    IBOutlet UIButton *mInstagramButton;
    IBOutlet UIButton *mFacebookButton;
    IBOutlet UIButton *mAppoxxeeButton;
    IBOutlet UIButton *mTwitterButton;
    IBOutlet UIButton *mSettingsButton;
    IBOutlet UIButton *mManualButton;
    IBOutlet UIButton *mGoProButton;
    IBOutlet UIButton *mHelpButton;
    IBOutlet UIImageView *mMainImageView;
    IBOutlet UIImageView *mTitleImageView;
    MPAdView *mAdView;
    GSBuyPopupView *mBuyPopupView;
    GSPurchaseType mPurchaseTag;
    
    BOOL mIsBannerAppear;

    NSMutableArray *mProductsArray;
}

- (IBAction) goProButtonPressed:(id)pSender;

@end
