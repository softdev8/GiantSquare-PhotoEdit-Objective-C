//
//  GSCollageViewController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/15/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSCollageViewController.h"

#import "Flurry.h"
#import "Social/Social.h"
#import "GSAppDelegate.h"
#import "Reachability.h"
#import "MBBProgressHUD.h"
#import "GSInspirationViewController.h"
#import "GSCustomNavigationController.h"
#import <RevMobAds/RevMobAds.h>

#define SHOW_AD_TIME 45

@interface GSCollageViewController ()
- (void) showFullScreenAd;
- (void) checkCollageIsEmpty;
@end

@implementation GSCollageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mCurrentCollage  = 0;
        mIsPublish = NO;
        mFrameWidth = 1.0;
        
        [self initCollagesArray];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
            mUseHasBoughtCollages = YES;
        } else {
            mUseHasBoughtCollages = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_FRAMES];
        }
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (mUseHasBoughtCollages) {
        mCountOfFreeCollages = mArrayOfColages.count;
    }
    
    mCollageView.delegate = self;
    [mCollageView reloadElements];
    
    [self initAds];
    [self initSwitcher];
    [self initCollageController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAdTimer];
}

- (void) initAds {
    
}

- (void) initCollagesArray {
    
}

- (void) initSwitcher {
    
}

- (void) initCollageController {
    
}

#pragma mark - GSCollageView delegate
- (void) GSCollageViewDelegateDidSelectCollage
{
    if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
        PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] init];
        [lPhotoController setDelegate:self];
        [lPhotoController setIsMultipleSelectionEnabled:YES];
        [self presentModalViewController:lPhotoController animated:YES];
    }else{
        if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
            [self openCameraRoll];
        }else{
            [self showiOS5Alert];
        }
        
    }

}

- (NSUInteger) GSCollageViewDelegateCountOfElemets {
    return [[mArrayOfColages objectAtIndex:mCurrentCollage] count];
}

- (NSArray *)GSCollageViewDelegateArraOfPointForElement:(NSUInteger)pElementIndex {
    
    return [[mArrayOfColages objectAtIndex:mCurrentCollage] objectAtIndex:pElementIndex];
}

#pragma mark - GSCollageSwitcher delegate
- (void) GSCollageSwitcherDelegateSelectedType:(GSCollageSwitcherType)pType {
    if (pType == GSCollageSwitcherTypeWhite) {
        [mCollageView setFrameColor:[UIColor whiteColor]];
    } else {
        [mCollageView setFrameColor:[UIColor blackColor]];
    }
    
}

#pragma mark - GSCollageController delegate
- (BOOL) GSCollageControllerDelegateSelectedCollage:(NSUInteger)pIndex {
    mCurrentCollage = pIndex;
    [mCollageView reloadElements];
    
    if (pIndex >= mCountOfFreeCollages) {
        if (mUseHasBoughtCollages) {
            [self checkCollageIsEmpty];
            mBuyCollagesButton.hidden = YES;
            mPublishButton.hidden = NO;
        } else {
            mBuyCollagesButton.hidden = NO;
            mPublishButton.hidden = YES;
        }
    } else {
        [self checkCollageIsEmpty];
        mBuyCollagesButton.hidden = YES;
        mPublishButton.hidden = NO;
    }
    return YES;
}

- (CGSize) GSCollageControllerDelegateTemplateSize {
    return CGSizeMake(0.0f, 0.0f);
}

- (UIImage*) GSCollageControllerDelegateImageForTemplate:(NSUInteger)pIndex {
    return nil;
}

- (UIImage*) GSCollageControllerDelegateImageForActiveTemplate:(NSUInteger)pIndex {
    return nil;
}

- (NSUInteger) GSCollageControllerDelegateCountOfTamplates {
    if(global_GSCategory == GS_INSTAGRAM_SQUARE)
    {
        return 12;
    }
    {
        return mArrayOfColages.count;
    }
}

- (NSUInteger) GSCollageControllerDelegateCountOfFreeTamplates {
    if(global_GSCategory == GS_INSTAGRAM_SQUARE)
    {
        return 12;
    }
    {
        return mCountOfFreeCollages;
    }
}

#pragma mark - GSTutorialOverlayView Delegate
- (void) viewExamplesPressed {
    GSInspirationViewController *lViewController = [[GSInspirationViewController alloc] initWithNibName:@"GSInspirationViewController" bundle:nil andMode:mTutorialType];
    [lViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lViewController animated:YES];
    lViewController.backButton.hidden = YES;
}

#pragma mark - PhotoPickerPlusDelegate
- (void)photoImagePickerControllerDidCancel:(PhotoPickerViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self checkCollageIsEmpty];
}

- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    outputImage = [outputImage getScaledImageFromHQ];
    [mCollageView setImageForSelectedElement:outputImage];
    [self checkCollageIsEmpty];
    [self dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

-  (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info {
    DLog(@"info count - %i", [info count]);
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([info count] > 0) {
        [mCollageView setImagesForFreePlaces:info];
        [self checkCollageIsEmpty];
    }
}

#pragma mark - Custom ActionSheet delegate
- (void) customAlertDidSelectButtonAtIndex:(NSInteger)pIndex {
    
    if (pIndex >= 1) {
        
        if (pIndex == 2) {
            UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            [self presentViewController:imagePickerController animated:YES completion:NULL];
            
        }else{
            if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
                if (pIndex == 1) {
                    PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
                    [lPhotoController setDelegate:self];
                    [lPhotoController setIsMultipleSelectionEnabled:NO];
                    [self presentModalViewController:lPhotoController animated:YES];
                }else if (pIndex == 3) {
                    PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
                    [lPhotoController setDelegate:self];
                    [lPhotoController setIsMultipleSelectionEnabled:NO];
                    [self presentModalViewController:lPhotoController animated:YES];
                    
                    [self.navigationItem setHidesBackButton:YES];
                }else if (pIndex == 4) {
                    PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
                    [lPhotoController setDelegate:self];
                    [lPhotoController setIsMultipleSelectionEnabled:NO];
                    [self presentModalViewController:lPhotoController animated:YES];
                }
            }else{
                if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
                    [self openCameraRoll];
                }else{
                    [self showiOS5Alert];
                } 
            }
        }
    }
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    outputImage = [outputImage getScaledImageFromHQ];
    [mCollageView setImageForSelectedElement:outputImage];
    [self checkCollageIsEmpty];
    [self dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
        
            [self saveImage:[mCollageView getImageForPublishWithWatermarkType:mWatermarkType] toAlbum:ALBUM_NAME];
        }
    }else if (alertView.tag == 4) {
        if (buttonIndex == 1) {
            setVal(@"stopRepeatAlert", @"YES");
        }
        [self openCameraRoll];
    }else if (alertView.tag == 8) {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:1.0f];
    }
}



#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == LOAD_ACTION_SHEET_TAG) {
        if (buttonIndex == 3) {//camera
            UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            [self presentViewController:imagePickerController animated:YES completion:NULL];
        }else if (buttonIndex == 4) {//cancel
            
        }else{
            if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
                if (buttonIndex == 0) {//facebook
                    PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] initWithService:1];
                    [lPhotoController setDelegate:self];
                    [lPhotoController setIsMultipleSelectionEnabled:YES];
                    [self presentModalViewController:lPhotoController animated:YES];
                    
                    [self.navigationItem setHidesBackButton:YES];
                } else if (buttonIndex == 1) {//instagram
                    PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] initWithService:3];
                    [lPhotoController setDelegate:self];
                    [lPhotoController setIsMultipleSelectionEnabled:YES];
                    [self presentModalViewController:lPhotoController animated:YES];
                    
                } else if (buttonIndex == 2) {//camera roll
                    PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
                    [lPhotoController setDelegate:self];
                    [lPhotoController setIsMultipleSelectionEnabled:YES];
                    [self presentModalViewController:lPhotoController animated:YES];
                }
            }else{
                if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
                    [self openCameraRoll];
                }else{
                    [self showiOS5Alert];
                }
            }
        }
    }
}


#pragma mark - iOS5 alert
- (void)showiOS5Alert{
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:IOS5_ALERT_TITLE_TEXT message:IOS5_ALERT_DESCRIPTION delegate:nil cancelButtonTitle:IOS5_ALERT_SUCCESS_BUTTON otherButtonTitles:IOS5_ALERT_DONT_REMIND_BUTTON, nil];
    lAlertView.delegate = self;
    lAlertView.tag = 4;
    [lAlertView show];
}

- (void)openCameraRoll{
    UIImagePickerController *lPicker = [[UIImagePickerController alloc] init];
    lPicker.delegate = self;
    lPicker.allowsEditing = YES;
    lPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:lPicker animated:YES];
}

#pragma mark - buttons Methods
- (IBAction) shuffleButtonPressed:(id)pSender {
    [mCollageView shuffleImage];
}

- (IBAction) changeFrameButtonPressed:(id)pSender {
    if ([mTimer isValid]) {
        [mTimer invalidate];
    }
    if ([(UIButton*)pSender tag] == 11) {
        [self changeFrameIncrease];
        mTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(changeFrameIncrease)userInfo:nil repeats:YES];
    } else {
        [self changeFrameReduce];
        mTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(changeFrameReduce)userInfo:nil repeats:YES];
    }
}

- (IBAction) stopFramePressing {
    if ([mTimer isValid]) {
        [mTimer invalidate];
    }
}


-(void)changeFrameIncrease{
    
    mFrameWidth ++;
    
    if (mFrameWidth <= 0) {
        mFrameWidth = 0;
    }
    
    if (mFrameWidth >= MAX_FRAMEWIDTH) {
        mFrameWidth = MAX_FRAMEWIDTH;
    }
    NSLog(@"fb setFrameWidth %f", mFrameWidth);
    [mCollageView setFrameWidth:mFrameWidth];
    [mFrameWidthLabel setText:[NSString stringWithFormat:@"%ipx", (int)(mFrameWidth*2)]];
}

-(void)changeFrameReduce{
    
    mFrameWidth --;
    
    if (mFrameWidth <= 0) {
        mFrameWidth = 0;
    }
    
    if (mFrameWidth >= MAX_FRAMEWIDTH) {
        mFrameWidth = MAX_FRAMEWIDTH;
    }
    NSLog(@"fb setFrameWidth %f", mFrameWidth);
    [mCollageView setFrameWidth:mFrameWidth];
    [mFrameWidthLabel setText:[NSString stringWithFormat:@"%ipx", (int)(mFrameWidth*2)]];
}


- (IBAction) backPressed {
    NSLog(@"-----------back pressed---------");
    if ([mCollageView isViewEmpty]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to exit and lose your progress?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        lAlert.tag = 3;
        [lAlert show];
    }
}


-(IBAction) donePressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) buyCollagesButtonPressed {
    if (mBuyPopupView != nil) {
        [mBuyPopupView removeFromSuperview];
        mBuyPopupView = nil;
    }

    mBuyPopupView = (GSBuyPopupView*)[[[NSBundle mainBundle] loadNibNamed:@"GSBuyPopupView" owner:nil options:nil] objectAtIndex:0];
    mBuyPopupView.delegate = self;
    [self.view addSubview:mBuyPopupView];
    [mBuyPopupView startDisplaying];
    
    [Flurry logEvent:@"buyCollagesButtonPressed" timed:NO];
}

- (IBAction) publishPressed {
    
}

- (IBAction) helpPressed:(id)sender {
    GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:mTutorialType];
    lHelp.delegate = self;
    [self.view addSubview:lHelp];
    [lHelp loadTutorial];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods
-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    NSLog(@"willBeginSendingToApplication %@", application);
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    NSLog(@"didEndSendingToApplication %@", application);
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
}

#pragma mark - saving methods
- (void)saveImage:(UIImage*)pImage toAlbum:(NSString*)pName {
    ALAssetsLibrary *lLibrary = [[ALAssetsLibrary alloc] init];
    [lLibrary writeImageToSavedPhotosAlbum:pImage.CGImage orientation:pImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error == nil) {
        [lLibrary addAssetURL:assetURL toAlbum:pName withCompletionBlock:^(NSError *error) {
            NSLog(@"addAssetURL : %@", assetURL);
            if (error == nil){
                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                [self showSuccessMessage];
            } else {
                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                [self showErrorMessage];
            }
        }];
    } else {
        [MBBProgressHUD hideHUDForView:self.view animated:YES];
        [self showErrorMessage];
    }
    }];
    
}

- (void)showAds{
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
            [[RevMobAds session] showFullscreen];
        }
    }
}

- (void) showSuccessMessage {
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image saved to album." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    lAlert.tag = 8;
    [lAlert show];

}

- (void) showErrorMessage {
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please turn on location services." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [lAlert show];
}

#pragma mark - GSBuyPopupViewDelegate methods
- (void)GSBuyPopupViewDelegateAdsPressed{
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

- (void)GSBuyPopupViewDelegateBuyPressed {
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
    
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_PRO_VERSION]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeGoPro;
}

- (void)GSBuyPopupViewDelegateCancelPressed {
    [mBuyPopupView hideMessage];
    mBuyPopupView = nil;
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
    }}

#pragma mark -SKPaymentTransactionObserver-
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
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
}

// this method called when user buy this purchase and it disable ads display
- (void)goPro {
    if (mPurchaseTag == GSPurchaseTypeWatermark) {
        [self removeWatermark];
    } else if (mPurchaseTag == GSPurchaseTypeFrames) {
        [self buyFrames];
        [self removeLockers];
    } else if (mPurchaseTag == GSPurchaseTypeAds) {
        [self removeAds];
    } else if (mPurchaseTag == GSPurchaseTypeGoPro) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_OLD_PURCHASE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self removeLockers];
    }
}

- (void)removeLockers {
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_AD_NOTIFICATION object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_OLD_PURCHASE];
    
    mUseHasBoughtCollages = YES;
    mCountOfFreeCollages = mArrayOfColages.count;
    [mCollageController loadTemplates];
    
    mBuyCollagesButton.hidden = YES;
    mPublishButton.hidden = NO;
}

- (void)removeWatermark {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
}

- (void)removeAds {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
}

- (void)buyFrames {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
}

- (void) showFullScreenAd {
    if (mInterstitialAdController.ready) {
        [self stopAdTimer];
        [mInterstitialAdController showFromViewController:self];
    } else {
        [mInterstitialAdController loadAd];
        [self startAdTimer];
    }
}

- (void) startAdTimer {
    [self stopAdTimer];
    mAdTimer = [NSTimer scheduledTimerWithTimeInterval:SHOW_AD_TIME target:self selector:@selector(showFullScreenAd) userInfo:nil repeats:NO];
}

- (void) stopAdTimer {
    if (mAdTimer != nil) {
        if (mAdTimer.isValid) {
            [mAdTimer invalidate];
        }
        mAdTimer = nil;
    }
}

- (void) checkCollageIsEmpty {
    if ([mCollageView isViewFull]) {
        [mPublishButton setEnabled:YES];
    } else {
        [mPublishButton setEnabled:NO];
    }
}

#pragma mark Interstitial delegate methods
- (UIViewController *)viewControllerForPresentingModalView {
	return self;
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
	NSLog(@"Interstitial did load Ad: %@",interstitial);
}

- (void)dismissInterstitial:(MPInterstitialAdController *)interstitial {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial{
	NSLog(@"Interstitial did fail to return ad %@",interstitial);
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial{
	NSLog(@"Interstitial will appear: %@",interstitial);
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    NSLog(@"interstitialDidDisappear: %@",interstitial);
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
  
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    // Reload the interstitial ad, if desired.
    [mInterstitialAdController loadAd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
