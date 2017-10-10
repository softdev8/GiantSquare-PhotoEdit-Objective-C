//
//  GSSettingsViewController.h
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/4/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>

#import "MPAdView.h"
#import "GSFacebookLoginView.h"
#import "GSTwitterLoginView.h"

@interface GSSettingsViewController : GSAbstractViewController <MPAdViewDelegate, GSFacebookLoginViewDelegate, GSTwitterLoginViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    
    IBOutlet UISwitch *mSettingsSwitch;
    IBOutlet UIButton *mBackButton;
    IBOutlet UIButton *mAccountsButton;
    IBOutlet UIButton *mRestoreButton;
    IBOutlet UILabel *mMainLabel;
    IBOutlet UIView *mSecondView;
    MPAdView *mAdView;
    BOOL mIsBannerAppear;
    
    GSTwitterLoginView *mTwitterLogin;
//    NSMutableArray *mt
}

- (IBAction) restoreButtonPressed:(id)pSender;

@end
