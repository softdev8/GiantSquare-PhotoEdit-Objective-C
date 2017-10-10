//
//  GSTwitterPreviewViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 1/2/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSTwitterPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>
#import "MBBProgressHUD.h"
#import "Reachability.h"
#import "GSTwitterSelectAccauntViewController.h"
#import "Flurry.h"
#import "SBJsonParser.h"
#import <RevMobAds/RevMobAds.h>

#define MAX_IMAGE_LENGHT 699990.0f
#define WATERMARK_PROPORTION 0.3

@interface GSTwitterPreviewViewController ()
- (void) postWithServer;
- (void) postWithNativeSDK;
@end

@implementation GSTwitterPreviewViewController

- (id)initWithImage:(UIImage*)pImage isFromCamera:(BOOL)pFromCamera{
    self = [super initWithNibName:@"GSTwitterPreviewViewController" bundle:nil];
    if (self) {
        if (!pFromCamera) {
            mOriginalImage = pImage;
        }else{
            
            if ([UIScreen mainScreen].bounds.size.height < 560) {
                mOriginalImage = [pImage getTwitterCuttedImage];
            } else {
                mOriginalImage = [pImage getTwitterCuttedImageForIhone5];
            }
            
        }
        isContrastActive = NO;
        mAngle = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundLight.png", @"backgroundLight_iPhone5.png")]]];
    
    mFilteredImage = mOriginalImage;
    mScaledImage = mOriginalImage;
    mSelectedFilter = GSFilterTypeNormal;
    
    [self loadScrollView];
    
    //load filters controller
    mFilterController = [[GSFiltersController alloc] initWithFrame:CGRectMake(0.0f, 33.0f, self.view.frame.size.width, 80.0f)];
    [mFilterController setDelegate:self];
    
    // load help on first start
    if (!getVal(@"twitter_first_start")) {
        setVal(@"twitter_first_start", [NSNumber numberWithBool:YES]);
        
        UIButton *lInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        [lInfoButton setImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"imageInfoPreview@2x.png", @"imageInfoPreview_iPhone5@2x.png")] forState:UIControlStateNormal];
        [lInfoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:lInfoButton];
    }
    
   
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
            [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }
        
        mIsBannerAppear = NO;
    }
    
    [mScrollView scrollRectToVisible:CGRectMake(0, mScrollView.contentSize.height*0.3, mScrollView.frame.size.width, mScrollView.frame.size.height) animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)displayImage{
    CGFloat lPreviousScale = [mScrollView zoomScale];
    CGPoint lPreviousContentOffset = [mScrollView contentOffset];
    [mImageView setImage:mFilteredImage];
    [mScrollView setZoomScale:lPreviousScale];
    [mScrollView setContentOffset:lPreviousContentOffset];
    
}

- (void)loadScrollView{
    if (mScrollView) {
        [mScrollView removeFromSuperview];
        mScrollView = nil;
    }
    mScrollView = [[UIScrollView alloc] initWithFrame:mShadowImageView.frame];
    mScrollView.delegate = self;
    mScrollView.contentSize = mFilteredImage.size;
    [mScrollView setAutoresizingMask:mShadowImageView.autoresizingMask];
    mScrollView.clipsToBounds = YES;
    mScrollView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (mImageView) {
        [mImageView removeFromSuperview];
        mImageView = nil;
    }
    mImageView = [[UIImageView alloc] initWithImage:mFilteredImage];
    mImageView.bounds = CGRectMake(0, 0, mFilteredImage.size.width, mFilteredImage.size.height);
    
    // calculate correct zoom
    CGFloat lCoefitient;
    if (mScrollView.contentSize.width > mScrollView.contentSize.height) {
        lCoefitient = mScrollView.frame.size.width / mScrollView.contentSize.width;
    }else if(mScrollView.contentSize.width < mScrollView.contentSize.height){
        lCoefitient = mScrollView.frame.size.width / mScrollView.contentSize.width;
    }else {
        lCoefitient = mScrollView.frame.size.width / mScrollView.contentSize.width;
    }
    
    [mScrollView setZoomScale:lCoefitient];
    mScrollView.minimumZoomScale = lCoefitient;
    mScrollView.maximumZoomScale = lCoefitient * 4;
    [mScrollView addSubview:mImageView];
    [self setCorrectZoom:mScrollView];
    mScrollView.scrollEnabled = YES;
    [self.view insertSubview:mScrollView belowSubview:mShadowImageView];
    mScrollView.showsHorizontalScrollIndicator = NO;
    mScrollView.showsVerticalScrollIndicator = NO;
}

- (void) postWithServer {
    //check for existing account if no - show login page
    if (getVal(TWITTER_ACCOUNTS_ARRAY) && [getVal(TWITTER_ACCOUNTS_ARRAY) count] > 0) {
        GSTwitterSelectAccauntViewController *lView = [[GSTwitterSelectAccauntViewController alloc] initWithNibName:@"GSTwitterSelectAccauntViewController" bundle:nil andImage:[self imageForAvatar] andImage:[self imageForBanner]];
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
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/update_profile_image.json"];
    
    __block NSData *lImageData = UIImageJPEGRepresentation([self imageForAvatar], 0.2f);
    
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
                TWRequest *request = [[TWRequest alloc] initWithURL:url
                                                         parameters:nil
                                                      requestMethod:TWRequestMethodPOST];
                
                //  self.accounts is an array of all available accounts;
                //  we use the first one for simplicity
                [request setAccount:[accounts objectAtIndex:0]];
                
                //  Obtain NSData from the UIImage
                
                
                //  Add the data of the image with the
                //  correct parameter name, "media[]"
                [request addMultiPartData:lImageData
                                 withName:@"image"
                                     type:@"image/jpg"];
                
                
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (responseData) {
                        NSDictionary *dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                        if ([dict objectForKey:@"errors"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                [self showAlerViewWithTitle:@"Error" message:[error localizedDescription]];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"start");
                                [self performSelector:@selector(postSecondImageWithNative:) withObject:[accounts objectAtIndex:0] afterDelay:2.0f];
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

- (void)postSecondImageWithNative:(id)pAccount{
//    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"second");
        NSURL *postBannerUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/update_profile_banner.json"];
        __block NSData *lBannerImageData = UIImageJPEGRepresentation([self imageForBanner], 0.2f);
        TWRequest *postBanerImageRequest = [[TWRequest alloc] initWithURL:postBannerUrl
                                                               parameters:nil
                                                            requestMethod:TWRequestMethodPOST];
        
        [postBanerImageRequest setAccount:pAccount];
        

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
                        [self showAlerViewWithTitle:@"You picture has been posted to Twitter!" message:@"Note: The profile and header picture alignment is optimized for web view on computer. If you preview picture on mobile app it will be 2% out of alignment"];
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
            lBannerImageData = nil;
        }];

//    });
}

#pragma mark - GSFiltersController Delegate
- (void) GSFiltersControllerDelegateFilteredImage:(UIImage *)pFilteredImage {
    if (pFilteredImage != nil) {
        mFilteredImage = pFilteredImage;
        [self displayImage];
    }
}

- (UIImage *) GSFiltersControllerDelegateOriginalImage {
    return mOriginalImage;
}

-(void)filterSetted:(NSInteger)pIndex{
    mSelectedFilter = pIndex;
}

#pragma mark -UIScrollView
- (void)setCorrectZoom:(UIScrollView*)pScroll{
    [pScroll setZoomScale:pScroll.minimumZoomScale];
    [pScroll setNeedsDisplay];
    [mScrollView setNeedsDisplay];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return mImageView;
}

#pragma mark - saving methods
- (void)saveImage:(UIImage*)pImage toAlbum:(NSString*)pName saveNext:(BOOL)pNeedToSave{
    NSLog(@"pImage.size.width - %f, pImage.size.height - %f ", pImage.size.width, pImage.size.height);
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

- (void)showErrorMessage{
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please turn on location services." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [lAlert show];
}

- (void)showSuccessMessage{
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
            [[RevMobAds session] showFullscreen];
        }
    }
    
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Images saved to album." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [lAlert show];
}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    DLog(@"buttonIndex  - %i", buttonIndex);
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            mOriginalImage = [mOriginalImage getScaledImageFromHQ];
            if (mAngle > 0) {
                mOriginalImage = [mOriginalImage rotateImageToAngle:mAngle];
                mAngle = 0;
            }
            if (mSelectedFilter != GSFilterTypeNormal) {
                mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
            }
            
            [self saveImage:[self imageForBanner] toAlbum:ALBUM_NAME saveNext:YES];
        }
    }
}


#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        mOriginalImage = [mOriginalImage getScaledImageFromHQ];

        DLog(@"mSelectedFilter  - %i", mSelectedFilter);
        if (mSelectedFilter != GSFilterTypeNormal) {
            mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
        }
        
        [self saveImage:[self imageForBanner] toAlbum:ALBUM_NAME saveNext:YES];
    }else if (buttonIndex == 1){
        Reachability *lReachebility = [Reachability reachabilityForInternetConnection];
        
        if ([lReachebility currentReachabilityStatus] != NotReachable) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            mOriginalImage = [mOriginalImage getScaledImageFromHQ];
            
            if (mSelectedFilter != GSFilterTypeNormal) {
                mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
            }else{
                mFilteredImage = mOriginalImage;
            }
            
            //[self postWithServer];
            [self postWithNativeSDK];
                        
        } else {
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No internet connection. Do you want to save image to Camera Roll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
            lAlertView.tag = 2;
            [lAlertView show];
        }
    }
  
}

#pragma mark - buttons methods
- (IBAction)backPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)exportPressed:(id)sender{
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Publish to Twitter", nil];
	lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[lActionSheet showInView:self.view];
}

- (IBAction)rotatePressed:(id)sender{
    if (mAngle < 270) {
        mAngle = mAngle + 90;
    }else{
        mAngle = 0;
    }
    mOriginalImage = [mOriginalImage rotateImageToAngle:90];
    mFilteredImage = [mFilteredImage rotateImageToAngle:90];
    [self loadScrollView];
}

- (IBAction)contrastPressed:(id)sender{
    isContrastActive = !isContrastActive;
    if (isContrastActive) {
        mSelectedFilter = GSFilterTypeContrast;
        mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
    } else {
        mSelectedFilter = GSFilterTypeNormal;
        mFilteredImage = mOriginalImage;
    }
    
    [self displayImage];
}

- (UIImage*) imageForAvatar {
    UIImage *lResult = nil;
    if (mFilteredImage != nil) {
        CGFloat lScaleX = 46 / mScrollView.contentSize.width;
        CGFloat lScaleY = 46 / mScrollView.contentSize.height;
        CGFloat lScaleOffsetX = (mScrollView.contentOffset.x + 137.0f) / mScrollView.contentSize.width;
        CGFloat lScaleOffsetY = (mScrollView.contentOffset.y + 16.0f) / mScrollView.contentSize.height;
        CGFloat lNewImageWidth = roundf(lScaleX * mFilteredImage.size.width);
        CGFloat lNewImageHeight = roundf(lScaleY * mFilteredImage.size.height);
        
        CGSize lNewImageSize = CGSizeMake(lNewImageWidth, lNewImageHeight);
        CGRect lRect = CGRectMake(-(mFilteredImage.size.width*lScaleOffsetX), -(mFilteredImage.size.height*lScaleOffsetY), mFilteredImage.size.width, mFilteredImage.size.height);
        
        UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
        [mFilteredImage drawInRect:lRect];
        lResult = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(516.0, 516.0), NO, 1);
        [lResult drawInRect:CGRectMake(0.0, 0.0, 516.0, 516.0)];
        lResult = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return lResult;
}

- (UIImage*) imageForBanner {
    UIImage *lResult = nil;
    if (mFilteredImage != nil) {
        CGFloat lScaleX = 320 / mScrollView.contentSize.width;
        CGFloat lScaleY = 162 / mScrollView.contentSize.height;
        CGFloat lScaleOffsetX = mScrollView.contentOffset.x / mScrollView.contentSize.width;
        CGFloat lScaleOffsetY = mScrollView.contentOffset.y / mScrollView.contentSize.height;
        CGFloat lNewImageWidth = roundf(lScaleX * mFilteredImage.size.width);
        CGFloat lNewImageHeight = roundf(lScaleY * mFilteredImage.size.height);
        
        DLog(@"filtered image size: %@", NSStringFromCGSize(mFilteredImage.size));
        CGSize lNewImageSize = CGSizeMake(lNewImageWidth, lNewImageHeight);
        CGRect lRect = CGRectMake(-(mFilteredImage.size.width*lScaleOffsetX), -(mFilteredImage.size.height*lScaleOffsetY), mFilteredImage.size.width, mFilteredImage.size.height);

        UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
        [mFilteredImage drawInRect:lRect];
        lResult = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //add watermark
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
            UIImage *lWatermarkImage = [UIImage imageNamed:@"cover_collage_watermark.png"];
            UIGraphicsBeginImageContextWithOptions(lResult.size, FALSE, 0.0);
            [lResult drawInRect:CGRectMake( 0, 0, lResult.size.width, lResult.size.height)];
            [lWatermarkImage drawInRect:CGRectMake( lResult.size.width - lResult.size.width * WATERMARK_PROPORTION, 0, lResult.size.width * WATERMARK_PROPORTION, lWatermarkImage.size.height * lResult.size.width * WATERMARK_PROPORTION/lWatermarkImage.size.width)];
            lResult = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }

    } else {
        lResult = mFilteredImage;
    }
    return lResult;
}

- (void)showAlerViewWithTitle:(NSString *)pTitle message:(NSString *)pMessage {
    UIAlertView *lAlerView = [[UIAlertView alloc] initWithTitle:pTitle
                                                        message:pMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [lAlerView show];
}

- (void) infoButtonPressed:(UIButton*)pInfoButton {
    if (pInfoButton != nil) {
        [pInfoButton setEnabled:NO];
        [UIView animateWithDuration:0.5 animations:^{
            [pInfoButton setAlpha:0.0];
        } completion:^(BOOL finished) {
            [pInfoButton removeFromSuperview];
        }];
    }
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - MPAdViewDelegate methods
- (void) animationStart {
    mIsBannerAppear = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    
    [UIView commitAnimations];
    
}

- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        [self.view insertSubview:mAdView aboveSubview:mBottomMenu];
        mIsBannerAppear = YES;
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
  
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
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
}

- (void)didFailOAuthWithError:(NSError *)error {
    NSLog(@"error oauth %@", error);
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
}
- (void)didTwitterCancelPressed{
    DLog(@"didTwitterCancelPressed");
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }else{
        return NO;
    }
}


@end
