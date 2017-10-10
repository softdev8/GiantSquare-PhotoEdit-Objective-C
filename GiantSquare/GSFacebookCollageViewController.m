//
//  GSFacebookCollageViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>
#import "GSFacebookCollageViewController.h"
#import "GSCollageView.h"
#import "Social/Social.h"
#import "GSAppDelegate.h"
#import "Reachability.h"
#import "MBBProgressHUD.h"
#import "GSCustomNavigationController.h"
#import "Flurry.h"
#import "GSFacebookSelectAccountViewController.h"
#import "GSManualViewController.h"
#import "SBJson.h"
#import <RevMobAds/RevMobAds.h>

@interface GSFacebookCollageViewController ()
- (void) getPicture;
- (void) postWithServer;
- (void) postWithNativeFacebookSDK;
@end

@implementation GSFacebookCollageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mTutorialType = GSTutorialTypeFacebookCollage;
        mWatermarkType = GSWatermarkTypeFacebookCollage;
        mIsPortraite = NO;
        mCountOfFreeCollages = 16;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set background
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar_iPhone5.png"]];
    } else {
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar.png"]];
    }
    
//    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
//    if (!appDelegate.session.isOpen) {
//        // create a fresh session object
//        appDelegate.session = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"publish_actions, user_photos", nil]];
//        
//        [FBSession setActiveSession:appDelegate.session];
//        // if we don't have a cached token, a call to open here would cause UX for login to
//        // occur; we don't want that to happen unless the user clicks the login button, and so
//        // we check here to make sure we have a token before calling open
//        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
//            // even though we had a cached token, we need to login to make the session usable
//            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                             FBSessionState status,
//                                                             NSError *error) {
//                // we recurse here, in order to update buttons and labels
//            }];
//        }
//    }
    
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
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {

            if ([UIScreen mainScreen].bounds.size.height > 500) {
                mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                        size:MOPUB_BANNER_SIZE];
                [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height + MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
                mAdView.delegate = self;
                [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
                [mAdView loadAd];
                mIsBannerAppear = NO;
            } else {
                mInterstitialAdController = [MPInterstitialAdController interstitialAdControllerForAdUnitId:FULL_SCREEN_AD_ID];
                mInterstitialAdController.delegate = self;
                [mInterstitialAdController loadAd];
                
                [self startAdTimer];
            }
        }
    }
}

- (void) initCollagesArray {
    mArrayOfColages = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"facebook_collages" ofType:@"plist"]];
}

- (void) initSwitcher {
    GSCollageSwitcher *lSwitcher = [[GSCollageSwitcher alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 83.0, 2.0, 100.0, 40.0)];
    [lSwitcher setDelegate:self];
    [self.view addSubview:lSwitcher];
}

- (void) initCollageController {
    mCollageController = [[GSCollageController alloc] initWithFrame:CGRectMake(40.0f, 232.0f, mMainView.frame.size.height - 40.0f, 80.0f)];
    [mCollageController setDelegate:self];
    [mCollageController loadTemplates];
    [mMainView addSubview:mCollageController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GSCollageController delegate
- (CGSize) GSCollageControllerDelegateTemplateSize {
    return CGSizeMake(131.0f, 50.0f);
}

- (UIImage*) GSCollageControllerDelegateImageForTemplate:(NSUInteger)pIndex {
    return [UIImage imageNamed:[NSString stringWithFormat:@"facebook_collage_%i.png", pIndex]];
}

- (UIImage*) GSCollageControllerDelegateImageForActiveTemplate:(NSUInteger)pIndex {
    return [UIImage imageNamed:[NSString stringWithFormat:@"facebook_collage_%i_active.png", pIndex]];
}

#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == LOAD_ACTION_SHEET_TAG) {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    } else {
        if (buttonIndex == 0) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self saveImage:[mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeFacebookCollage] toAlbum:ALBUM_NAME];
        }else if (buttonIndex == 1){
            Reachability *lReachebility = [Reachability reachabilityForInternetConnection];
            if ([lReachebility currentReachabilityStatus] != NotReachable) {
                mIsPublish = YES;
                //[self postWithServer];
                [self postWithNativeFacebookSDK];
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
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - buttons Methods
- (IBAction) backPressed {
    if ([mCollageView isViewEmpty]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to exit and lose your progress?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        lAlert.tag = 3;
        [lAlert show];
    }
    [Flurry endTimedEvent:@"facebookCollagePressed" withParameters:nil];
}

- (IBAction) donePressed {
    [super donePressed];
    [Flurry endTimedEvent:@"facebookCollagePressed" withParameters:nil];
}
    
- (IBAction) publishPressed {
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Publish to Facebook", nil];
	lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[lActionSheet showInView:self.view];
    [Flurry logEvent:@"publishPressed"];
}

- (IBAction) helpPressed:(id)pSender {
    [super helpPressed:pSender];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - GSFacebookLoginViewDelegate
- (void)facebookAuthSucceeded:(NSString*)token{
    DLog(@"token  - %@", token);
    if (token && [token length] > 0) {
        NSArray* lParametersArray = [token componentsSeparatedByString: @"&"];
        NSString *lToken = [lParametersArray objectAtIndex:0];
        setVal(FACEBOOK_ACCES_TOKEN, lToken);

        [self getPicture];
        
        GSFacebookSelectAccountViewController *lViewController = [[GSFacebookSelectAccountViewController alloc] initWithNibName:@"GSFacebookSelectAccountViewController" bundle:nil andImage:[mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeFacebookCollage]];
        [self.navigationController pushViewController:lViewController animated:YES];
    }else{
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
    
}

- (void)facebookAuthFailed:(NSString*)error
               errorReason:(NSString*)errorReason
          errorDescription:(NSString*)errorMessage{
    DLog(@"facebookAuthFailed - %@   %@   %@", error, errorReason, errorMessage);
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook Auth Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
    
}
- (void)facebookAuthLoadFailed:(NSError*)error{
    DLog(@"facebookAuthLoadFailed - %@", error.localizedDescription);
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook AuthLoad Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
    
}
- (void)facebookAuthCancelled{
    DLog(@"facebookAuthCancelled");
}

- (void) getPicture {
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_picture/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [lRequest setHTTPMethod:@"POST"];
    NSString *lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\"}", getVal(FACEBOOK_ACCES_TOKEN)];
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
                                                   setVal(FACEBOOK_USER_NAME, lName);
                                               }
                                           }
                                       }
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                               }
                           }];
}

- (void) postWithServer {
    //check for existing account if no - show login page
    if (getVal(FACEBOOK_ACCES_TOKEN) && [getVal(FACEBOOK_ACCES_TOKEN) length] > 0) {
        GSFacebookSelectAccountViewController *lViewController = [[GSFacebookSelectAccountViewController alloc] initWithNibName:@"GSFacebookSelectAccountViewController" bundle:nil andImage:[mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeFacebookCollage]];
        [self.navigationController pushViewController:lViewController animated:YES];
    }else{
        GSFacebookLoginView *lFacebook = [[GSFacebookLoginView alloc] initWithFrame:self.view.frame];
        [lFacebook loadWebView];
        lFacebook.delegate = self;
        [self.view addSubview:lFacebook];
        [self.view bringSubviewToFront:lFacebook];
    }
}

- (void) postWithNativeFacebookSDK {
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
            ACAccountStore *lAcountStore = [[ACAccountStore alloc] init];
            ACAccountType *lFacebookAccountType = [lAcountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            
            // At first, we only ask for the basic read permission
            NSArray * lPermissions = @[@"email"];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:FACEBOOK_APPID, ACFacebookAppIdKey, lPermissions, ACFacebookPermissionsKey, ACFacebookAudienceEveryone, ACFacebookAudienceKey, nil];
            
            [lAcountStore requestAccessToAccountsWithType:lFacebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
                if (granted && error == nil) {
                    NSArray *lPublishPermissions = [[NSArray alloc] initWithObjects:@"publish_actions", nil];
                    NSString *key = [NSString stringWithFormat:@"%@", ACFacebookPermissionsKey];
                    [dict setValue:lPublishPermissions forKey:key];
                    
                    [lAcountStore requestAccessToAccountsWithType:lFacebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
                        if(granted && error == nil) {
                            [self performSelectorOnMainThread:@selector(openSessionWithAllowLoginUI:) withObject:nil waitUntilDone:NO];
                        } else if (!granted) {
                            [self performSelectorOnMainThread:@selector(showPermissionGrantedError) withObject:nil waitUntilDone:NO];
                        } else {
                            DLog(@"error is: %@",[error description]);
                            [MBBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    }];
                } else if (!granted) {
                    [self performSelectorOnMainThread:@selector(showPermissionGrantedError) withObject:nil waitUntilDone:NO];
                } else {
                    DLog(@"facebook error: %@", [error description]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                }
            }];
        } else {
            [self openSessionWithAllowLoginUI:YES];
            return;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There are no Facebook account configured." message:@"You can add or create a Facebook account in Settings -> Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            [MBBProgressHUD hideHUDForView:self.view animated:YES];
        }
    } else {
        [self openSessionWithAllowLoginUI:YES];
    }
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

    if (mIsBannerAppear) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [mAdView setCenter:CGPointMake(self.view.frame.size.width + MOPUB_BANNER_SIZE.height / 2.0, mAdView.center.y)];
            [mMainView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
            [mCollageController setFrame:CGRectMake(40.0f, 232.0f, self.view.frame.size.width - 40.0f, 80.0f)];
        } completion:^(BOOL finished) {
            [mAdView setHidden:YES];
            [mAdView removeFromSuperview];
            mAdView = nil;
        }];
    } else {
        [self stopAdTimer];
    }
}

#pragma mark - Facebook API
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    DLog(@"Error:%@",error.localizedDescription);
    
    DLog(@"FBSession.activeSession %@", FBSession.activeSession);
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                
                DLog(@"permissions :%@", FBSession.activeSession.permissions);
				if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions, user_photos"] == NSNotFound) {
					// No permissions found in session, ask for it
					[FBSession.activeSession requestNewPublishPermissions: [NSArray arrayWithObject:@"publish_actions, user_photos"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                        if (error) {
                            DLog(@"error - %@", error.localizedDescription);
                            [MBBProgressHUD hideHUDForView:self.view animated:YES];
                        }else{
                            if (mIsPublish) {
                                mIsPublish = NO;
                                [self publishImages];
                            } else {
                                //[self getUserId];
                            }
                        }
					}];
				} else {
                    if (mIsPublish) {
                        mIsPublish = NO;
                        [self publishImages];
                    } else {
                        //[self getUserId];
                    }
				}
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
            [MBBProgressHUD hideHUDForView:self.view animated:YES];
            break;
        }
        default:
            break;
    }
    
    if (error) {
        mIsPublish = NO;
        //        [mProgressView stopAnimating];
        [MBBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
}

//- (void)getUserId {
//    [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//
//
//        if (!error) {
//            NSString *lUserId = [(NSDictionary *)result objectForKey:@"id"];
//            mProfilePictureView.profileID = lUserId;
//        } else {
//            DLog(@"error occured %@", error);
//            [MBBProgressHUD hideHUDForView:self.view animated:YES];
//        }
//        [mProgressView stopAnimating];
//    }];
//}

- (void)publishImages {
    [FBRequestConnection startWithGraphPath:@"me/albums" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *resultData = [(NSDictionary *)result objectForKey:@"data"];
        
        
        
        if (resultData && resultData.count > 0 && !error) {
            if ([getVal(@"publicPostsEnabled") isEqualToString:@"NO"]) {
                NSString *lAlbumID = @"";
                for (NSDictionary *lAlbum in resultData) {
                    if ([[lAlbum objectForKey:@"name"] isEqualToString:PRIVATE_ALBUM_NAME]) {
                        lAlbumID = [lAlbum objectForKey:@"id"];
                    }
                }
                if ([lAlbumID isEqualToString:@""]) {
                    [self createFacebookAlbum:PRIVATE_ALBUM_NAME
                              completionBlock:^(NSDictionary *response, NSError *postError) {
                                  DLog(@"Facebook publishing response: %@", [response description]);
                                  
                                  UIImage *lImage = [mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeFacebookCollage];
                                  
                                  [self publishImageToFacebookAlbum:[response objectForKey:@"id"]
                                                              image:lImage
                                                    withDescription:SHARE_STRING
                                                        showMessage:YES
                                                    completionBlock:^(NSDictionary *response, NSError *postError) {
                                                        DLog(@"Facebook publishing response: %@", [response description]);
                                                        [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                                    }];
                                  
                              }];
                    
                }else{
                    UIImage *lImage = [mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeFacebookCollage];
                    
                    [self publishImageToFacebookAlbum:lAlbumID
                                                image:lImage
                                      withDescription:@""
                                          showMessage:YES
                                      completionBlock:^(NSDictionary *response, NSError *postError) {
                                          DLog(@"Facebook publishing response: %@", [response description]);
                                          [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                      }];
                    
                }
            }else{
                UIImage *lImage = [mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeFacebookCollage];
                [self publishImageToFacebookAlbum:@"photos"
                                            image:lImage
                                  withDescription:@""
                                      showMessage:YES
                                  completionBlock:^(NSDictionary *response, NSError *postError) {
                                      DLog(@"Facebook publishing response: %@", [response description]);
                                      [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                  }];
            }
        } else {
            DLog(@"error occured %@", error);
            [MBBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
//    [[FBSession activeSession] close];
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        [self sessionStateChanged:[FBSession activeSession] state:[FBSession activeSession].state error:nil];
        return YES;
    } else {
        return [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions, user_photos"] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [self sessionStateChanged:session state:status error:error];
        }];
    }
}

- (void)publishImageToFacebookAlbum:(NSString *)aAlbum image:(UIImage *)aImage withDescription:(NSString *)aDescription showMessage:(BOOL)aShow completionBlock:(void(^)(NSDictionary *response, NSError *postError))aBlock {
    NSData *imageData = UIImageJPEGRepresentation(aImage, 1.0);
    NSMutableDictionary *publishParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:aDescription, @"message", imageData, @"source", nil];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos", aAlbum]
                                 parameters:publishParameters HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (aShow) {
                                  if (error) {
                                      DLog(@"error: %@", error);
                                      UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"error: domain = %@, code = %d", error.domain, error.code] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
                                      lAlertView.tag = 8;
                                      [lAlertView show];

                                  } else {
                                      UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Your collage has been posted to Facebook" message:@"Now open Facebook and set it as your cover picture" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
                                      lAlertView.tag = 8;
                                      [lAlertView show];
                                  }
                                  
      
                                  
                                  [MBBProgressHUD hideHUDForView:self.view animated:YES];
                              }
                              aBlock(result, error);}];
    
}

- (void)createFacebookAlbum:(NSString *)aAlbum completionBlock:(void(^)(NSDictionary *response, NSError *postError))aBlock {
    
    NSMutableDictionary *publishParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"The Giant Square private photos", @"message", aAlbum, @"name", @"{\"value\":\"SELF\"}", @"privacy", nil];
    
    [FBRequestConnection startWithGraphPath:@"me/albums"
                                 parameters:publishParameters HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              DLog(@"error: %@", error);
                              aBlock(result, error);}];
    
}

- (void)showPermissionGrantedError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied" message:@"Check app permissions in Settings -> Facebook" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    //    [mProgressView stopAnimating];
    [MBBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
