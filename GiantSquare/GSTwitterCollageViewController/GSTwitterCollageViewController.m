//
//  GSTwitterCollageViewController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSTwitterCollageViewController.h"
#import "GSTwitterSelectAccauntViewController.h"
#import "Flurry.h"
#import "Reachability.h"
#import "MBBProgressHUD.h"
#import "SBJsonParser.h"
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <RevMobAds/RevMobAds.h>

@interface GSTwitterCollageViewController ()
- (UIImage*) imageForBanner;
- (UIImage*) imageForAvatar;
- (void) postWithServer;
- (void) postWithNativeSDK;
- (void)showAlerViewWithTitle:(NSString *)pTitle message:(NSString *)pMessage;
@end

@implementation GSTwitterCollageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mTutorialType = GSTutorialTypeTwitterCollage;
        mWatermarkType = GSWatermarkTypeTwitterCollage;
        mIsPortraite = NO;
        mCountOfFreeCollages = 5;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set background
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar_iPhone5.png"]];
    } else {
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar.png"]];
    }
    
    //set background image
    [mMainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundLightLandscape.png", @"backgroundLightLandscape_iPhone5.png")]]];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.view.frame.size.width > 480) {
        [mSwitchButton setCenter:CGPointMake(144.0, mSwitchButton.center.y)];
    }
    
    // show tutorial at first start
    if (!getVal(@"firstStartFacebookCollage")) {
        setVal(@"firstStartFacebookCollage", @"NO");
        [self helpPressed:nil];
    }
    
    [mCollageController setFrame:CGRectMake(40.0f, 232.0f, mMainView.frame.size.width - 40.0f, 80.0f)];
}

- (void) initAds {
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        BOOL lUseHasRemovedAds;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
            lUseHasRemovedAds = YES;
        } else {
            lUseHasRemovedAds = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED];
        }
        if (!lUseHasRemovedAds) {
            mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                    size:MOPUB_BANNER_SIZE];
            [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height + MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
            
            mIsBannerAppear = NO;
        }
    }
}

- (void) initCollagesArray {
    mArrayOfColages = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"twitter_collages" ofType:@"plist"]];
}

- (void) initSwitcher {
    GSCollageSwitcher *lSwitcher = [[GSCollageSwitcher alloc] initWithFrame:CGRectMake(155.0, 2.0, 100.0, 40.0)];
    [lSwitcher setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [lSwitcher setDelegate:self];
    [mMainView addSubview:lSwitcher];
}

- (void) initCollageController {
    mCollageController = [[GSCollageController alloc] initWithFrame:CGRectMake(40.0f, 232.0f, mMainView.frame.size.height - 40.0f, 80.0f)];
    [mCollageController setDelegate:self];
    [mCollageController loadTemplates];
    [mMainView addSubview:mCollageController];
}

#pragma mark - GSCollageController delegate
- (CGSize) GSCollageControllerDelegateTemplateSize {
    return CGSizeMake(100.0f, 48.0f);
}

- (UIImage*) GSCollageControllerDelegateImageForTemplate:(NSUInteger)pIndex {
    return [UIImage imageNamed:[NSString stringWithFormat:@"twitter_collage_%i.png", pIndex]];
}

- (UIImage*) GSCollageControllerDelegateImageForActiveTemplate:(NSUInteger)pIndex {
    return [UIImage imageNamed:[NSString stringWithFormat:@"twitter_collage_%i_active.png", pIndex]];
}

#pragma mark - buttons Methods
- (IBAction) backPressed {
    if ([mCollageView isViewEmpty]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to exit and lose your progress?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        lAlert.tag = 3;
        [lAlert show];
    }
    [Flurry endTimedEvent:@"twitterCollagePressed" withParameters:nil];
}

- (IBAction) donePressed {
    [super donePressed];
    [Flurry endTimedEvent:@"twitterCollagePressed" withParameters:nil];
}

- (IBAction) publishPressed {
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Publish to Twitter", nil];
	lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[lActionSheet showInView:self.view];
    [Flurry logEvent:@"publishPressed"];
}

- (IBAction) helpPressed:(id)pSender {
    [super helpPressed:pSender];
}

#pragma mark - saving methods
- (void)saveImage:(UIImage*)pImage toAlbum:(NSString*)pName saveNext:(BOOL)pNeedToSave {
    ALAssetsLibrary *lLibrary = [[ALAssetsLibrary alloc] init];
    [lLibrary writeImageToSavedPhotosAlbum:pImage.CGImage orientation:pImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {        if (error == nil) {
        [lLibrary addAssetURL:assetURL toAlbum:pName withCompletionBlock:^(NSError *error) {
            NSLog(@"addAssetURL error: %@", error);
            if (error == nil){
                if (pNeedToSave) {
                    [self saveImage:[self imageForAvatar] toAlbum:ALBUM_NAME saveNext:NO];
                }else{
                    [MBBProgressHUD hideHUDForView:self.view animated:YES];
                    [self showSuccessMessage];
                }
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

#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == LOAD_ACTION_SHEET_TAG) {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    } else {
        if (buttonIndex == 0) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self saveImage:[self imageForBanner] toAlbum:ALBUM_NAME];
        }else if (buttonIndex == 1){
            Reachability *lReachebility = [Reachability reachabilityForInternetConnection];
            
            if ([lReachebility currentReachabilityStatus] != NotReachable) {
                [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                //[self postWithServer];
                [self postWithNativeSDK];
            } else {
                UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No internet connection. Do you want to save image to Camera Roll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
                lAlertView.tag = 2;
                [lAlertView show];
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - GSTwitterLoginViewDelegate
- (void)getPicture:(NSString *)pToken andSecret:(NSString*)pSecret{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_twitter_user/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [lRequest setHTTPMethod:@"POST"];
    NSString *lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\", \"access_token_secret\":\"%@\"}", pToken, pSecret];
    DLog(@"request json:%@",lJsonString);
    
    NSData *requestData = [NSData dataWithBytes:[lJsonString UTF8String] length:[lJsonString length]];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [lRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [lRequest setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:lRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               
                               if (error == nil) {
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       
                                       NSMutableString *lResultStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       
                                       DLog(@"response:%@",lResultStr);
                                       if (lResultStr != nil && ![lResultStr isEqual: @""] && [data length] > 0) {
                                           
                                           SBJsonParser *lParser = [SBJsonParser new];
                                           id lJson = [lParser objectWithString:lResultStr];
                                           if (lJson != nil ) {
                                               NSString *lName = @"";
                                               if ([lJson objectForKey:@"name"]) {
                                                   lName = [lJson objectForKey:@"name"];
                                               }
                                               [self addTwitterAccountWithToken:pToken andSecret:pSecret andName:lName];
                                           }
                                       }
                                       
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                                   UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [lAlertView show];
                               }
                               [MBBProgressHUD hideHUDForView:self.view animated:YES];
                           }];
    
}

- (void)addTwitterAccountWithToken:(NSString*)pToken andSecret:(NSString*)pSecret andName:(NSString*)pName{
    
    NSMutableArray *lAccountsArray = [NSMutableArray new];
    if (getVal(TWITTER_ACCOUNTS_ARRAY)){
        [lAccountsArray setArray:getVal(TWITTER_ACCOUNTS_ARRAY)];
    }
    NSMutableDictionary *lDictionary = [NSMutableDictionary new];
    [lDictionary setValue:pToken forKey:TWITTER_ACCES_TOKEN];
    [lDictionary setValue:pSecret forKey:TWITTER_ACCES_SECRET];
    [lDictionary setValue:pName forKey:TWITTER_ACCES_NAME];
    [lDictionary setValue:@"YES" forKey:TWITTER_ACCES_STATE];
    
    [lAccountsArray addObject:lDictionary];
    setVal(TWITTER_ACCOUNTS_ARRAY, lAccountsArray);
    NSLog(@"TWITTER_ACCOUNTS_ARRAY  - %@", getVal(TWITTER_ACCOUNTS_ARRAY));
    
    GSTwitterSelectAccauntViewController *lView = [[GSTwitterSelectAccauntViewController alloc] initWithNibName:@"GSTwitterSelectAccauntViewController" bundle:nil andImage:[self imageForAvatar] andImage:[self imageForBanner]];
    [self.navigationController pushViewController:lView animated:YES];
}

- (void)didReceiveOAuthAccessToken:(OAToken *)token {
    NSLog(@"access token %@", token);
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
    DLog(@"token.key - %@", token.key);
    DLog(@"token.secret - %@", token.secret);
    
    if (token) {
        [self getPicture:token.key andSecret:token.secret];
    }else{
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
}

- (void)didFailOAuthWithError:(NSError *)error {
    NSLog(@"error oauth %@", error);
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
}
- (void)didTwitterCancelPressed{
    DLog(@"didTwitterCancelPressed");
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }else{
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*) imageForAvatar {
    UIImage *lResult = nil;
//    UIImage *lImage = [mCollageView getImageForPublish];
//    if (lImage != nil) {
//        CGFloat lScaleX = 46 / mScrollView.contentSize.width;
//        CGFloat lScaleY = 46 / mScrollView.contentSize.height;
//        CGFloat lScaleOffsetX = (mScrollView.contentOffset.x + 137.0f) / mScrollView.contentSize.width;
//        CGFloat lScaleOffsetY = (mScrollView.contentOffset.y + 16.0f) / mScrollView.contentSize.height;
//        CGFloat lNewImageWidth = roundf(lScaleX * lImage.size.width);
//        CGFloat lNewImageHeight = roundf(lScaleY * lImage.size.height);
//        
//        CGSize lNewImageSize = CGSizeMake(lNewImageWidth, lNewImageHeight);
//        CGRect lRect = CGRectMake(-(lImage.size.width*lScaleOffsetX), -(lImage.size.height*lScaleOffsetY), lImage.size.width, lImage.size.height);
//        
//        UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
//        [lImage drawInRect:lRect];
//        lResult = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
    
    return lResult;
}

- (UIImage*) imageForBanner {
    UIImage *lResult = [mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeTwitterCollage];
    return lResult;
}

- (void) postWithServer {
    //check for existing account if no - show login page
    if (getVal(TWITTER_ACCOUNTS_ARRAY) && [getVal(TWITTER_ACCOUNTS_ARRAY) count] > 0) {
        
        GSTwitterSelectAccauntViewController *lView = [[GSTwitterSelectAccauntViewController alloc] initWithNibName:@"GSTwitterSelectAccauntViewController" bundle:nil andImage:[self imageForBanner]];
        [self.navigationController pushViewController:lView animated:YES];
    } else {
        mTwitterLogin = [[GSTwitterLoginView alloc] initWithFrame:self.view.frame];
        [mTwitterLogin setDelegate:self];
        [mTwitterLogin startAuthorization];
        [self.view addSubview:mTwitterLogin];
        [self.view bringSubviewToFront:mTwitterLogin];
    }
    [MBBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) postWithNativeSDK {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0) {
        return;
    }
    
    NSURL *postBannerUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/update_profile_banner.json"];
    
    __block NSData *lBannerImageData = UIImageJPEGRepresentation([self imageForBanner], 0.2f);
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"There are no Twitter account configured." message:@"You can add or create a Twitter account in Settings -> Twitter" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [lAlertView setTag:36];
                [lAlertView show];
            });
        } else {
            NSArray *accounts = [account accountsWithAccountType:accountType];
            if ([accounts count] > 0) {
                TWRequest *postBanerImageRequest = [[TWRequest alloc] initWithURL:postBannerUrl
                                                                       parameters:nil
                                                                    requestMethod:TWRequestMethodPOST];
                
                //  self.accounts is an array of all available accounts;
                //  we use the first one for simplicity
                [postBanerImageRequest setAccount:[accounts objectAtIndex:0]];
                
                //  Obtain NSData from the UIImage
                
                
                //  Add the data of the image with the
                //  correct parameter name, "media[]"
                [postBanerImageRequest addMultiPartData:lBannerImageData
                                 withName:@"banner"
                                     type:@"image/jpg"];
                
                
                [postBanerImageRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (responseData) {
                        NSDictionary *lResultDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                        if (![lResultDict objectForKey:@"errors"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                // advertisment
                                if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
                                    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
                                        [[RevMobAds session] showFullscreen];
                                    }
                                }
                                [self showAlerViewWithTitle:@"Woohoo!" message:@"Your collage has been posted to Twitter! Go and check it out!"];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                DLog(@"error: %@", lResultDict);
                                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                [self showAlerViewWithTitle:@"Error" message:[error localizedDescription]];
                            });
                        }
                    }else{
                        [MBBProgressHUD hideHUDForView:self.view animated:YES];
                    }
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"There are no Twitter account configured." message:@"You can add or create a Twitter account in Settings -> Twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [lAlertView show];
                });
            }
        }
    }];
}

- (void)showAlerViewWithTitle:(NSString *)pTitle message:(NSString *)pMessage {
    UIAlertView *lAlerView = [[UIAlertView alloc] initWithTitle:pTitle
                                                        message:pMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [lAlerView show];
}

#pragma mark - MPAdViewDelegate methods
- (void) animationStart {
    mIsBannerAppear = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [mAdView setCenter:CGPointMake(self.view.frame.size.width - MOPUB_BANNER_SIZE.height / 2.0, mAdView.center.y)];
    [mMainView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - MOPUB_BANNER_SIZE.height, self.view.frame.size.height)];
    [mCollageController setFrame:CGRectMake(40.0f, 232.0f, self.view.frame.size.width - 40.0f - MOPUB_BANNER_SIZE.height, 80.0f)];
    [UIView commitAnimations];
}
- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        [mAdView setCenter:CGPointMake(self.view.frame.size.width + MOPUB_BANNER_SIZE.height / 2.0, self.view.frame.size.height / 2.0)];
        [mAdView setTransform:CGAffineTransformMakeRotation(- M_PI_2)];
        [self.view addSubview:mAdView];
        [self animationStart];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}

- (void) removeAds {
    [super removeAds];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [mAdView setCenter:CGPointMake(self.view.frame.size.width + MOPUB_BANNER_SIZE.height / 2.0, mAdView.center.y)];
        [mMainView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [mCollageController setFrame:CGRectMake(40.0f, 232.0f, self.view.frame.size.width - 40.0f, 80.0f)];
    } completion:^(BOOL finished) {
        [mAdView setHidden:YES];
        [mAdView removeFromSuperview];
        mAdView = nil;
    }];
}

@end
