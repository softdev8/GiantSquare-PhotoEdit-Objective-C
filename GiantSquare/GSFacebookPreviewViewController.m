//
//  GSFacebookPreviewViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 12/26/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//
#define WATERMARK_PROPORTION 0.3

#import "GSFacebookPreviewViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import "Social/Social.h"
#import "GrayscaleContrastFilter.h"
#import "GPUImage.h"
#import "MBBProgressHUD.h"
#import "Reachability.h"
#import "Flurry.h"
#import "GSFacebookSelectAccountViewController.h"
#import "SBJson.h"
#import <RevMobAds/RevMobAds.h>
#import "GSManualViewController.h"

@interface GSFacebookPreviewViewController ()
- (UIImage*) imageForFacebook;
- (UIImage*) imageForFacebookAvatar;
- (void) infoButtonPressed:(UIButton*)pInfoButton;
- (void) getPicture;
@end

@implementation GSFacebookPreviewViewController

@synthesize timeLineIsNew=mTimeLineIsNew;

#pragma mark - init
- (id)initWithImage:(UIImage*)pImage isCamera:(BOOL)pIsCamera{
    self = [super initWithNibName:@"GSFacebookPreviewViewController" bundle:nil];
    if (self) {
        mOriginalImage = pImage;
        mSelectedFilter = GSFilterTypeNormal;
        isCamera = pIsCamera;
        mAngle = 0;
        isContrastActive = NO;
        mTimeLineIsNew = NO;
    }
    return self;
}

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mFilteredImage = mOriginalImage;

    //set background
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar_iPhone5.png"]];
        
        if (mTimeLineIsNew) {
            [mBackgroundImageView setImage:[UIImage imageNamed:@"new_facebook_frame_iphone5.png"]];
            [mBackgroundImageView setFrame:CGRectMake(0.0, 143.5, self.view.frame.size.width, 176.5)];
        } else {
            [mBackgroundImageView setImage:[UIImage imageNamed:@"facebook_frame568.png"]];
            [mBackgroundImageView setFrame:CGRectMake(0.0, 155.0, self.view.frame.size.width, 165.0)];
        }
    } else {
        if (mTimeLineIsNew) {
            [mBackgroundImageView setImage:[UIImage imageNamed:@"new_facebook_frame.png"]];
            [mBackgroundImageView setFrame:CGRectMake(0.0, 143.5, self.view.frame.size.width, 176.5)];
        } else {
           [mBackgroundImageView setImage:[UIImage imageNamed:@"facebook_frame.png"]];
           [mBackgroundImageView setFrame:CGRectMake(0.0, 155.0, self.view.frame.size.width, 165.0)];
        }
    }
    
    //load bottom menu
    mFilterController = [[GSFiltersController alloc] initWithFrame:CGRectMake(130.0f, 232.0f, [UIScreen mainScreen].bounds.size.height - 130.0f, 80.0f)];
    [mFilterController setDelegate:self];

    // load help on first start
    if (!getVal(@"facebook_first_start")) {
        setVal(@"facebook_first_start", [NSNumber numberWithBool:YES]);
        
        UIButton *lInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 568.0, 320.0)];
        [lInfoButton setImage:[UIImage imageNamed:@"facebook_info.png"] forState:UIControlStateNormal];
        [lInfoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:lInfoButton];
    }

    //load scroll
    [self loadScrollView];
    if (isCamera) {
        if ([UIScreen mainScreen].bounds.size.height < 560) {
            [mScrollView setZoomScale:0.18];
            mScrollView.contentOffset = CGPointMake(65.0, 61.0);
        } else {
            [mScrollView setZoomScale:0.16];
            mScrollView.contentOffset = CGPointMake(15.0, 38.0);
        }
    }
    
    [mScrollView setNeedsDisplay];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload{
    [mFilterController setDelegate:nil];
    [super viewDidUnload];
}

#pragma mark - GSTutorialOverlayView Delegate
- (void)viewExamplesPressed{
    GSManualViewController *lViewController = [[GSManualViewController alloc] initWithNibName:@"GSManualViewController" bundle:nil andMode:0];
    [lViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lViewController animated:YES];
    lViewController.backButton.hidden = YES;
}


#pragma mark - GSFiltersController Delegate
- (void) GSFiltersControllerDelegateFilteredImage:(UIImage *)pFilteredImage {
    if (pFilteredImage != nil) {
        mFilteredImage = pFilteredImage;
        [self displayImage];
    }
}

- (UIImage *) GSFiltersControllerDelegateOriginalImage {
    return mFilteredImage;
}

-(void)filterSetted:(NSInteger)pIndex{
    mSelectedFilter = pIndex;
}


#pragma mark -UIScrollView

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
    
    mScrollView = [[UIScrollView alloc] initWithFrame:mScrollSizeView.frame];
    mScrollView.delegate = self;
    mScrollView.contentSize = mFilteredImage.size;
    
    mScrollView.clipsToBounds = YES;
    mScrollView.contentMode = UIViewContentModeScaleAspectFit;
    
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
    
    mScrollView.showsHorizontalScrollIndicator = NO;
    mScrollView.showsVerticalScrollIndicator = NO;
    [self.view insertSubview:mScrollView aboveSubview:mScrollSizeView];

}

- (void)setCorrectZoom:(UIScrollView*)pScroll{
    [pScroll setZoomScale:pScroll.minimumZoomScale];
    [pScroll setNeedsDisplay];
    [mScrollView setNeedsDisplay];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return mImageView;
}

#pragma mark - Facebook API
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    DLog(@"Error:%@",error.localizedDescription);
    
    
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                if (mSelectedFilter != GSFilterTypeNormal) {
                    mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
                }
                DLog(@"permissions :%@", FBSession.activeSession.permissions);
				if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions, user_photos"] == NSNotFound) {
					// No permissions found in session, ask for it
					[FBSession.activeSession requestNewPublishPermissions: [NSArray arrayWithObject:@"publish_actions, user_photos"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
						if (error) {
                            DLog(@"error - %@", error.localizedDescription);
                            [MBBProgressHUD hideHUDForView:self.view animated:YES];
                        }else{
                            [self publishImages];
                        }
					}];
				} else {
                    [self publishImages];
				}
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        [MBBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
}

- (void)publishImages {
    [FBRequestConnection startWithGraphPath:@"me/albums" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *resultData = [(NSDictionary *)result objectForKey:@"data"];
        
        if (resultData && resultData.count > 0 && !error) {
            if (![getVal(@"publicPostsEnabled") isEqualToString:@"YES"]) {
                NSString *lAlbumID = @"";
                for (NSDictionary *lAlbum in resultData) {
                    DLog(@"lAlbum  - %@", lAlbum);
                    if ([[lAlbum objectForKey:@"name"] isEqualToString:PRIVATE_ALBUM_NAME]) {
                        lAlbumID = [lAlbum objectForKey:@"id"];
                        DLog(@"yes album -  %@", lAlbum);
                    }
                }
                
                
                if ([lAlbumID isEqualToString:@""]) {
                    [self createFacebookAlbum:PRIVATE_ALBUM_NAME
                              completionBlock:^(NSDictionary *response, NSError *postError) {
                                  DLog(@"Facebook publishing response: %@", [response description]);
                                  setVal(@"albumID", [response objectForKey:@"id"]);
                                  [self publishImageToFacebookAlbum:getVal(@"albumID")
                                                              image:[self imageForFacebook]
                                                    withDescription:SHARE_STRING
                                                        showMessage:NO
                                                    completionBlock:^(NSDictionary *response, NSError *postError) {
                                                        DLog(@"Facebook publishing response background: %@", [response description]);
                                                        if (postError) {
                                                            [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                                        }else{
                                                            
                                                            [self publishImageToFacebookAlbum:getVal(@"albumID")
                                                                                        image:[self imageForFacebookAvatar]
                                                                              withDescription:SHARE_STRING
                                                                                  showMessage:YES
                                                                              completionBlock:^(NSDictionary *response, NSError *postError) {
                                                                                  DLog(@"Facebook publishing response avatar: %@", [response description]);
                                                                                  if (postError) {
                                                                                      [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                                                                  }
                                                                              }];
                                                            
                                                        }
                                                    }];
                                  
                              }];
                    
                } else {
                    [self publishImageToFacebookAlbum:lAlbumID
                                                image:[self imageForFacebook]
                                      withDescription:SHARE_STRING
                                          showMessage:NO
                                      completionBlock:^(NSDictionary *response, NSError *postError) {
                                          DLog(@"Facebook publishing response background: %@", [response description]);
                                          if (postError) {
                                              [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                          }else{
                                              
                                              [self publishImageToFacebookAlbum:lAlbumID
                                                                          image:[self imageForFacebookAvatar]
                                                                withDescription:SHARE_STRING
                                                                    showMessage:YES
                                                                completionBlock:^(NSDictionary *response, NSError *postError) {
                                                                    DLog(@"Facebook publishing response avatar: %@", [response description]);
                                                                    if (postError) {
                                                                        [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                                                    }
                                                                }];
                                              
                                          }
                                      }];
                    
                }
            } else {
                [self publishImageToFacebookAlbum:@"photos"
                                            image:[self imageForFacebook]
                                  withDescription:SHARE_STRING
                                      showMessage:NO
                                  completionBlock:^(NSDictionary *response, NSError *postError) {
                                      DLog(@"Facebook publishing response background: %@", [response description]);
                                      if (postError) {
                                          [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                      }else{
                                          
                                          [self publishImageToFacebookAlbum:@"photos"
                                                                      image:[self imageForFacebookAvatar]
                                                            withDescription:SHARE_STRING
                                                                showMessage:YES
                                                            completionBlock:^(NSDictionary *response, NSError *postError) {
                                                                DLog(@"Facebook publishing response avatar: %@", [response description]);
                                                                if (postError) {
                                                                    [MBBProgressHUD hideHUDForView:self.view animated:YES];
                                                                }
                                                            }];
                                          
                                      }
                                  }];
            }
        } else {
            DLog(@"error occured %@", error);
            [MBBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}
/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    [[FBSession activeSession] close];
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        [self sessionStateChanged:[FBSession activeSession] state:[FBSession activeSession].state error:nil];
        return YES;
    } else {
        //        return [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions, publish_stream, user_photos"] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        //            [self sessionStateChanged:session state:state error:error];
        //        }];
        //        return [FBSession openActiveSessionWithReadPermissions:NO
        //                                                  allowLoginUI:YES
        //                                             completionHandler:
        //                ^(FBSession *session, FBSessionState state, NSError *error) {
        //            [self sessionStateChanged:session state:state error:error];
        //        }];
        
        return [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObject:@"user_photos"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
        
    }
    
}



- (void)publishImageToFacebookAlbum:(NSString *)aAlbum image:(UIImage *)aImage withDescription:(NSString *)aDescription showMessage:(BOOL)aShow completionBlock:(void(^)(NSDictionary *response, NSError *postError))aBlock {
    DLog(@"album id  - %@", aAlbum);
    [self saveImage:aImage toAlbum:ALBUM_NAME];
    NSData *imageData = UIImageJPEGRepresentation(aImage, 1.0f);
    
    NSMutableDictionary *publishParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:aDescription, @"message", imageData, @"source", nil];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos", aAlbum]
                                 parameters:publishParameters HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (aShow) {
                                  NSString *alertText;
                                  if (error) {
                                      alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d", error.domain, error.code];
                                      DLog(@"error: %@", error);
                                  } else {
                                      alertText = @"Your message was posted on Facebook.";
                                  }
                                  [MBBProgressHUD hideHUDForView:self.view animated:YES];

                                  // Show the result in an alert
                                  UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
                                  lAlertView.tag = 8;
                                  [lAlertView show];
  
                                  GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeFacebookAfterPublish];
                                  lHelp.delegate = self;
                                  [self.view addSubview:lHelp];
                                  [lHelp loadTutorial];
                                  
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

#pragma mark - saving methods
- (void)saveImage:(UIImage*)pImage toAlbum:(NSString*)pName saveNext:(BOOL)pNeedToSave{
    ALAssetsLibrary *lLibrary = [[ALAssetsLibrary alloc] init];
    [lLibrary writeImageToSavedPhotosAlbum:pImage.CGImage orientation:pImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {        if (error == nil) {
        [lLibrary addAssetURL:assetURL toAlbum:pName withCompletionBlock:^(NSError *error) {
            NSLog(@"addAssetURL error: %@", error);
            if (error == nil){
                if (pNeedToSave) {
                    [self saveImage:[self imageForFacebookAvatar] toAlbum:ALBUM_NAME saveNext:NO];
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

- (void)saveImage:(UIImage*)pImage toAlbum:(NSString*)pName{
    ALAssetsLibrary *lLibrary = [[ALAssetsLibrary alloc] init];
    [lLibrary writeImageToSavedPhotosAlbum:pImage.CGImage orientation:pImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error == nil) {
            [lLibrary addAssetURL:assetURL toAlbum:pName withCompletionBlock:^(NSError *error) {
            NSLog(@"addAssetURL error: %@", error);
            }];
        }
    }];
    
}

- (void)showErrorMessage{
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please turn on location services." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [lAlert show];
}

- (void)showSuccessMessage{
    // Show the result in an alert
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Result" message:@"Image saved to album." delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
    lAlertView.tag = 8;
    [lAlertView show];
    
    GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeFacebookAfterPublish];
    lHelp.delegate = self;
    [self.view addSubview:lHelp];
    [lHelp loadTutorial];

}


#pragma mark - get images


- (void)showAds{
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
            [[RevMobAds session] showFullscreen];
        }
    }
}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    DLog(@"buttonIndex  - %i", buttonIndex);
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            mOriginalImage = [mOriginalImage getScaledImageFromHQ];

            if (mSelectedFilter != GSFilterTypeNormal) {
                mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
            }
            [self saveImage:[self imageForFacebook] toAlbum:ALBUM_NAME saveNext:YES];
        }
    }else if (alertView.tag == 8) {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:1.0f];
    }
}


#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        // save to camera roll
        [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
        mOriginalImage = [mOriginalImage getScaledImageFromHQ];
        if (mSelectedFilter != GSFilterTypeNormal) {
            mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
        }
        
        [self saveImage:[self imageForFacebook] toAlbum:ALBUM_NAME saveNext:YES];
        
    }else if (buttonIndex == 1){
        //publish to facebook
        Reachability *lReachebility = [Reachability reachabilityForInternetConnection];
        
        if ([lReachebility currentReachabilityStatus] != NotReachable) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            mOriginalImage = [mOriginalImage getScaledImageFromHQ];
            if (mSelectedFilter != GSFilterTypeNormal) {
                mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
            }
            
            mOriginalImage = [mOriginalImage getScaledImageFromHQ];
            if (mSelectedFilter != GSFilterTypeNormal) {
                mFilteredImage = [mFilterController makeFilter:mSelectedFilter toImage:mOriginalImage];
            }
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
                                }
                            }];
                        } else if (!granted) {
                            [self performSelectorOnMainThread:@selector(showPermissionGrantedError) withObject:nil waitUntilDone:NO];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                            });
                        } else {
                            DLog(@"facebook error: %@", [error description]);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                            });
                        }
                    }];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There are no Facebook account configured." message:@"You can add or create a Facebook account in Settings -> Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    
                    [MBBProgressHUD hideHUDForView:self.view animated:YES];
                }
            } else {
                [self openSessionWithAllowLoginUI:YES];
            }
    
        } else {
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No internet connection. Do you want to save image to Camera Roll?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
            lAlertView.tag = 2;
            [lAlertView show];
        }
    }
}

#pragma mark - buttons methods

- (IBAction)rotatePressed:(id)sender{
    if (mAngle < 270) {
        mAngle = mAngle + 90;
    }else{
        mAngle = 0;
    }
    mFilteredImage = [mFilteredImage rotateImageToAngle:90];
    mOriginalImage = [mOriginalImage rotateImageToAngle:90];
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

-(IBAction)backPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)publishPressed:(id)sender{
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Publish to Facebook", nil];
	lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[lActionSheet showInView:self.view];

    [Flurry logEvent:@"publishPressed"];
}


- (UIImage*) imageForFacebook {
    UIImage *lResult = nil;
    if (mFilteredImage != nil) {
		CGFloat lScaleX = 480 / mScrollView.contentSize.width;
		CGFloat lScaleY = 179 / mScrollView.contentSize.height;
		CGFloat lScaleOffsetX = mScrollView.contentOffset.x / mScrollView.contentSize.width;
		CGFloat lScaleOffsetY = mScrollView.contentOffset.y / mScrollView.contentSize.height;
		CGFloat lNewImageWidth = roundf(lScaleX * mFilteredImage.size.width);
		CGFloat lNewImageHeight = roundf(mFilteredImage.size.height * lScaleY);
		
		CGSize lNewImageSize = CGSizeMake(lNewImageWidth, lNewImageHeight);
		CGRect lRect = CGRectMake(-(mFilteredImage.size.width*lScaleOffsetX), -(mFilteredImage.size.height*lScaleOffsetY), mFilteredImage.size.width, mFilteredImage.size.height);
		
		UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
		[mFilteredImage drawInRect:lRect];
		
		lResult = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(1440.0, 533.0), NO, 1);
		[lResult drawInRect:CGRectMake(0.0, 0.0, 1440.0, 533.0)];
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
        
    }
    return lResult;
}

- (UIImage*) imageForFacebookAvatar {
    UIImage *lResult = nil;
    if (mFilteredImage != nil) {

        CGFloat lScaleX = 91.0f / mScrollView.contentSize.width;
        CGFloat lScaleY = 91.0f / mScrollView.contentSize.height;
        CGFloat lScaleOffsetX = (mScrollView.contentOffset.x + 11.0f) / mScrollView.contentSize.width;
        CGFloat lScaleOffsetY = (mScrollView.contentOffset.y + 101.0f) / mScrollView.contentSize.height;
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
        
        NSLog(@"lResult %@", NSStringFromCGSize(lResult.size));
    }
    return lResult;
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



#pragma mark - memory warnings
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - GSFacebookLoginViewDelegate
- (void)facebookAuthSucceeded:(NSString*)token{
    DLog(@"token  - %@", token);
    if (token && [token length] > 0) {
        NSArray* lParametersArray = [token componentsSeparatedByString: @"&"];
        NSString *lToken = [lParametersArray objectAtIndex:0];
        setVal(FACEBOOK_ACCES_TOKEN, lToken);
        
        [self getPicture];
        
        GSFacebookSelectAccountViewController *lViewController = [[GSFacebookSelectAccountViewController alloc] initWithNibName:@"GSFacebookSelectAccountViewController" bundle:nil andImage:[self imageForFacebook] andImage:[self imageForFacebookAvatar]];
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


@end
