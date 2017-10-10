//
//  GSMainViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 12/20/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import "GSMainViewController.h"
#import "GSMainManualViewController.h"
#import "GSTwitterCoosingViewController.h"
#import "Appoxee.h"
#import "GSFacebookChoosingViewController.h"
#import "GSManualViewController.h"
#import "GSCustomNavigationController.h"
#import "GSSettingsViewController.h"
#import "GSInstagramChoosingViewController.h"
#import "GSAppDelegate.h"
#import "GSManualViewController.h"
#import "MBBProgressHUD.h"
#import "GSFacebookCollageViewController.h"

@interface GSMainViewController ()

@end

@implementation GSMainViewController

#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view life cycle 
- (void)viewDidLoad
{
    [super viewDidLoad];
    //set background image
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDark_iPhone5.png"]]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDark.png"]]];
    }
    
    if (!getVal(@"isFirstStart")) {
        setVal(@"isFirstStart", @"NO");
        setVal(@"facebookActiveToken", @"none");
//        [self performSelector:@selector(showHelp) withObject:nil afterDelay:2.0f];
    }
    
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        BOOL lUseHasRemovedAds = NO;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
            lUseHasRemovedAds = YES;
        } else {
            lUseHasRemovedAds = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED];
        }
        if (!lUseHasRemovedAds) {
            mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                    size:MOPUB_BANNER_SIZE];
            [mAdView setFrame:CGRectMake((self.view.frame.size.width  - MOPUB_BANNER_SIZE.width)/2, - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        } else {
            [mTitleImageView setCenter:CGPointMake(self.view.frame.size.width / 2.0, mTitleImageView.center.y)];
        }
        mIsBannerAppear = NO;
    } else {
        [mTitleImageView setCenter:CGPointMake(self.view.frame.size.width / 2.0, mTitleImageView.center.y)];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    // show/hide goPro button
    [self showHideGoProButton];
    
    //hide navigation bar
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;

    //add appoxee badge
    [self updateBadge];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackNotification:) name:nil object:nil];
    
    BOOL lUseHasRemovedAds;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
        lUseHasRemovedAds = YES;
        [mGoProButton setHidden:YES];
    } else {
        lUseHasRemovedAds = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED];
    }
    if (lUseHasRemovedAds) {
        
        
        [mTitleImageView setCenter:CGPointMake(self.view.frame.size.width / 2.0, mTitleImageView.center.y)];
        if (mIsBannerAppear) {
            [mFacebookButton setCenter:CGPointMake(mFacebookButton.center.x, self.view.frame.size.height / 4.0)];
            [mInstagramButton setCenter:CGPointMake(mInstagramButton.center.x, self.view.frame.size.height / 2.0)];
            [mTwitterButton  setCenter:CGPointMake(mTwitterButton.center.x, (self.view.frame.size.height / 4.0) * 3.0)];
            [mAdView setHidden:YES];
            [mAdView removeFromSuperview];
            mAdView = nil;
        }
    }
}

- (void)updateBadge{
    for (NSInteger i = 0; i < [[mAppoxxeeButton subviews] count]; i++) {
        UIView *lView = [[mAppoxxeeButton subviews] objectAtIndex:i];
        if (lView.tag == 3) {
            [lView removeFromSuperview];
        }
    }
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        UIView *lBadgeView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, 2, 2)];
        lBadgeView.tag = 3;
        lBadgeView.backgroundColor = [UIColor clearColor];
        [[AppoxeeManager sharedManager] addBadgeToView:lBadgeView badgeText:[NSString stringWithFormat:@"%i", [UIApplication sharedApplication].applicationIconBadgeNumber] badgeLocation:CGPointMake(0, 0)];
        [mAppoxxeeButton addSubview:lBadgeView];
    }
}

- (void)showHideGoProButton{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] || ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED] && [[NSUserDefaults standardUserDefaults] boolForKey:IAP_FRAMES] && [[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK])) {
        [mGoProButton setHidden:YES];
    }else{
        [mGoProButton setHidden:NO];
    }
}

- (void)trackNotification:(NSNotification *) notification{
    //Name of the event caught
	id name = [notification name];
	if ([name isEqual:@"badgeNumberChanged"]) {
        [self updateBadge];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - buttons methods

- (IBAction)instagramPressed:(id)sender{
    DLog(@"instagramPressed");
    GSInstagramChoosingViewController *lViewController = [[GSInstagramChoosingViewController alloc] initWithNibName:@"GSInstagramChoosingViewController" bundle:nil];
    [self.navigationController pushViewController:lViewController animated:YES];

    [Flurry logEvent:@"instagramPressed" timed:YES];

}

- (IBAction) facebookPressed:(id)sender {
    
    GSFacebookChoosingViewController *lViewController = [[GSFacebookChoosingViewController alloc] initWithNibName:@"GSFacebookChoosingViewController" bundle:nil];
    GSCustomNavigationController *lNavigationController = [[GSCustomNavigationController alloc] initWithRootViewController:lViewController];
    lNavigationController.navigationBar.hidden = YES;
    lNavigationController.navigationBarHidden = YES;
    lNavigationController.isPortrait = NO;
    [self presentModalViewController:lNavigationController animated:YES];
    
    [Flurry logEvent:@"facebookPressed" timed:YES];
}

- (IBAction) twitterPressed:(id)sender {
    DLog(@"twitterPressed");
    GSTwitterCoosingViewController *lViewController = [[GSTwitterCoosingViewController alloc] initWithNibName:@"GSTwitterCoosingViewController" bundle:nil];
    [self.navigationController pushViewController:lViewController animated:YES];
    
    [Flurry logEvent:@"twitterPressed" timed:YES];

}

- (IBAction) manualPressed:(id)sender {
   
    DLog(@"manualPressed");
    GSMainManualViewController *lViewController = [[GSMainManualViewController alloc] initWithNibName:@"GSMainManualViewController" bundle:nil ];
    [lViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.navigationController pushViewController:lViewController animated:YES];
}

- (IBAction) goProButtonPressed:(id)pSender {
    if (mBuyPopupView != nil) {
        [mBuyPopupView removeFromSuperview];
        mBuyPopupView = nil;
    }

    mBuyPopupView = (GSBuyPopupView*)[[[NSBundle mainBundle] loadNibNamed:@"GSBuyPopupView" owner:nil options:nil] objectAtIndex:0];
    mBuyPopupView.delegate = self;
    [self.view addSubview:mBuyPopupView];
    [mBuyPopupView startDisplaying];
    
    [Flurry logEvent:@"goProButtonPressed" timed:NO];
}

- (void)showHelp{
    GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeMainScreen];
    lHelp.alpha = 0.0f;
    [self.view addSubview:lHelp];
    [UIView animateWithDuration:0.4f animations:^{
        lHelp.alpha = 1.0f;
    }];
    [lHelp loadTutorial];
}

- (IBAction)helpOverlayPressed:(id)sender{
    [self showHelp];
}

- (IBAction)appoxxeePressed:(id)sender{
    [[AppoxeeManager sharedManager] show];
}

-(IBAction)settingsButtonPressed:(id)sender{
    GSSettingsViewController * lViewController = [[GSSettingsViewController alloc] initWithNibName:@"GSSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:lViewController animated:YES];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - GSBuyPopupViewDelegate methods
- (void)GSBuyPopupViewDelegateAdsPressed{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
    
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_ADS_REMOVED]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    
    mPurchaseTag = GSPurchaseTypeAds;
    
}

- (void)GSBuyPopupViewDelegateWatermarkPressed{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_WATERMARK]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeWatermark;
}

- (void)GSBuyPopupViewDelegateFramesPressed{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_FRAMES]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeFrames;
}

- (void)GSBuyPopupViewDelegateBuyPressed{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
    
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_PRO_VERSION]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeGoPro;
}

- (void)GSBuyPopupViewDelegateCancelPressed {
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
}


#pragma mark - MPAdViewDelegate methods

- (void) animationStart {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    mIsBannerAppear = YES;

    [mAdView setFrame:CGRectMake(0.0f, mMainImageView.frame.size.height - 2, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [mFacebookButton setFrame:CGRectMake(mFacebookButton.frame.origin.x, mFacebookButton.frame.origin.y + mAdView.frame.size.height, mFacebookButton.frame.size.width, mFacebookButton.frame.size.height)];
        [mInstagramButton setFrame:CGRectMake(mInstagramButton.frame.origin.x, mInstagramButton.frame.origin.y + mAdView.frame.size.height/2 + 10, mInstagramButton.frame.size.width, mInstagramButton.frame.size.height)];
        [mTwitterButton setFrame:CGRectMake(mTwitterButton.frame.origin.x, mTwitterButton.frame.origin.y + mAdView.frame.size.height/3, mTwitterButton.frame.size.width, mTwitterButton.frame.size.height)];
    }else{
        [mFacebookButton setFrame:CGRectMake(mFacebookButton.frame.origin.x, mFacebookButton.frame.origin.y + mAdView.frame.size.height - 3, mFacebookButton.frame.size.width, mFacebookButton.frame.size.height)];
        [mInstagramButton setFrame:CGRectMake(mInstagramButton.frame.origin.x, CGRectGetMaxY(mFacebookButton.frame) + 5, mInstagramButton.frame.size.width, mInstagramButton.frame.size.height)];
        [mTwitterButton setFrame:CGRectMake(mTwitterButton.frame.origin.x, CGRectGetMaxY(mInstagramButton.frame) + 5, mTwitterButton.frame.size.width, mTwitterButton.frame.size.height)];
    }
    [mHelpButton setCenter:CGPointMake(mHelpButton.center.x, mFacebookButton.frame.origin.y + mHelpButton.frame.size.height/2)];
    
    [UIView commitAnimations];
    
}

- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        [self.view insertSubview:mAdView belowSubview:mMainImageView];
        [self animationStart];
    }
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view{

}

#pragma mark -SKProductsRequestDelegate-

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *products = response.products;
    if (products.count != 0) {
        SKPayment *payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Product not found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products){
        NSLog(@"Product not found: %@", product);
    }
}

#pragma mark -SKPaymentTransactionObserver-
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                [self goPro];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Transaction Failed");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                [self goPro];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            default:
                break;
        }
    }
    [MBBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [MBBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"didFailWithError");
    
}
// this method called when user buys purchase for removing watermark
- (void) removeWatermark {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
    [self showHideGoProButton];
}

// this method called when user buys purchase for removing adds
- (void) removeAdds {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mAdView setFrame:CGRectMake((self.view.frame.size.width  - MOPUB_BANNER_SIZE.width)/2, - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        
        [mFacebookButton setCenter:CGPointMake(mFacebookButton.center.x, self.view.frame.size.height / 4.0)];
        [mInstagramButton setCenter:CGPointMake(mInstagramButton.center.x, self.view.frame.size.height / 2.0)];
        [mTwitterButton  setCenter:CGPointMake(mTwitterButton.center.x, (self.view.frame.size.height / 4.0) * 3.0)];
        [mTitleImageView setCenter:CGPointMake(self.view.frame.size.width / 2.0, mTitleImageView.center.y)];
    } completion:^(BOOL finished) {
        [mAdView setHidden:YES];
        [mAdView removeFromSuperview];
        mAdView = nil;
        [self showHideGoProButton];
    }];
}

// this method called when user buys purchase for more frames
- (void) buyMoreFrames {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
    [self showHideGoProButton];
}

// this method called when user buy this purchase and it disable ads display
- (void) goPro {
    if (mPurchaseTag == GSPurchaseTypeWatermark) {
        [self removeWatermark];
    } else if (mPurchaseTag == GSPurchaseTypeFrames) {
        [self buyMoreFrames];
    } else if (mPurchaseTag == GSPurchaseTypeAds) {
        [self removeAdds];
    } else if (mPurchaseTag == GSPurchaseTypeGoPro) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_OLD_PURCHASE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [mAdView setFrame:CGRectMake((self.view.frame.size.width  - MOPUB_BANNER_SIZE.width)/2, - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            
            [mFacebookButton setCenter:CGPointMake(mFacebookButton.center.x, self.view.frame.size.height / 4.0)];
            [mInstagramButton setCenter:CGPointMake(mInstagramButton.center.x, self.view.frame.size.height / 2.0)];
            [mTwitterButton  setCenter:CGPointMake(mTwitterButton.center.x, (self.view.frame.size.height / 4.0) * 3.0)];
            [mTitleImageView setCenter:CGPointMake(self.view.frame.size.width / 2.0, mTitleImageView.center.y)];
        } completion:^(BOOL finished) {
            [mAdView setHidden:YES];
            [mAdView removeFromSuperview];
            mAdView = nil;
            [self showHideGoProButton];
        }];
    }
}

@end
