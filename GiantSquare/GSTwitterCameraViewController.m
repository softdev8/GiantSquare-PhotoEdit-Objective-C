//
//  GSTwitterCameraViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 1/2/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSTwitterCameraViewController.h"
#import "GrayscaleContrastFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "GSTwitterPreviewViewController.h"
#import "MBBProgressHUD.h"
#import "GSManualViewController.h"
#import "GSInspirationViewController.h"
#import "Flurry.h"
#import "GSCustomNavigationController.h"

@interface GSTwitterCameraViewController ()

@end

@implementation GSTwitterCameraViewController

#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - Get last photo from Camera Roll -
- (void)setImageFromCameraRollButton {
    __block NSInteger lIndex = 0;
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    
                                    if (lIndex == 0) {
                                        UIImage *lLastImage = [UIImage imageWithCGImage:group.posterImage];
                                        if (lLastImage) {
                                            [mCameraRollButton setImage:lLastImage forState:UIControlStateNormal];
                                        }
                                    }
                                    lIndex++;
                                } failureBlock:^(NSError *error) {
                                    // User did not allow access to library
                                    // .. handle error
                                }
     ];
    
}

#pragma mark - Alert View -
- (void)showErrorAlerWithMessage:(NSString *)pMessage {
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:pMessage
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [lAlertView show];
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wantsFullScreenLayout = YES;
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundLight.png", @"backgroundLight_iPhone5.png")]]];
    
    
    mCameraType = UIImagePickerControllerCameraDeviceRear;
    
    mCameraViewController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] ||
        [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        
        [mCameraViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
        [mTakePhotoView insertSubview:mCameraViewController.view belowSubview:mTakePhotoButton];
        [mCameraViewController.view setCenter:CGPointMake( mTakePhotoView.frame.size.width / 2, self.view.frame.size.height/2 - mTakePhotoView.frame.origin.y)];
        [mCameraViewController setShowsCameraControls:NO];
        [mCameraViewController.cameraOverlayView setFrame:mTakePhotoView.bounds];
        [mCameraViewController setDelegate:self];
        [mCameraViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
    } else {
        [self showErrorAlerWithMessage:@"Camera is unavailable"];
    }
    
    if (![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
        [mFlashButton setEnabled:NO];
    }
    
    [mCameraRollButton setClipsToBounds:YES];
    [mCameraRollButton.layer setCornerRadius:5.0f];
    [self setImageFromCameraRollButton];
    [self adjustElements];
    
    
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
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }

        mIsBannerAppear = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [mCameraViewController viewWillAppear:animated];
    
    // show tutorial at first start
    if (!getVal(@"firstStartTwitter")) {
        setVal(@"firstStartTwitter", @"NO");
        GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeTwitter];
        lHelp.delegate = self;
        [self.view addSubview:lHelp];
        [lHelp loadTutorial];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [mCameraViewController viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustElements {
    if ([[UIScreen mainScreen] bounds].size.height > 480) {
        CGFloat lOffsetY = mBottomView.frame.size.height / 2.0f;
        [self makeOffsetForView:mBottomView withOffset:lOffsetY];
        [self makeOffsetForView:mTakePhotoView withOffset:20.0f];
        [self makeOffsetForView:mShadowImageView withOffset:20.0f];
    }
}

- (void)makeOffsetForView:(UIView *)pView withOffset:(CGFloat)pOffset {
    pView.frame = CGRectOffset(pView.frame, 0, pOffset);
}
#pragma mark - buttons methods

- (IBAction)backPressed:(id)sender{
    DLog(@"backPressed");
    [self.navigationController popViewControllerAnimated:YES];
    
    [Flurry endTimedEvent:@"twitterGiantPressed" withParameters:nil];
}

- (IBAction)helpPressed:(id)sender{
    GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeTwitter];
    lHelp.delegate = self;
    [self.view addSubview:lHelp];
    [lHelp loadTutorial];    
    [Flurry logEvent:@"tutorial pressed !!!"];
}

- (IBAction)cameraRollButtonPressed:(id)sender{
    if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
        PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] init];
        [lPhotoController setDelegate:self];
        [lPhotoController setIsMultipleSelectionEnabled:NO];
        [self presentModalViewController:lPhotoController animated:YES];
    }else{
        if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
            [self openCameraRoll];
        }else{
            [self showiOS5Alert];
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 4) {
        if (buttonIndex == 1) {
            setVal(@"stopRepeatAlert", @"YES");
        }
        [self openCameraRoll];
    }
}

- (IBAction)takePhotoButtonPressed:(id)sender{
    self.view.userInteractionEnabled = NO;
    [mCameraViewController takePicture];
}

- (IBAction)flashButtonPressed:(id)sender{
    DLog(@"onOffLightButtonPressed");
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *lButton = (UIButton*)sender;
        [lButton setSelected:!lButton.selected];
        
        if (lButton.selected) {
            [mCameraViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
        } else {
            [mCameraViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
        }
    }
}

- (IBAction)cameraTypeButtonPressed:(id)sender{
    DLog(@"flipButtonPressed");
    [mCameraTypeButton setEnabled:NO];
    
    if (mCameraType == UIImagePickerControllerCameraDeviceRear) {
        mCameraType = UIImagePickerControllerCameraDeviceFront;
    } else {
        mCameraType = UIImagePickerControllerCameraDeviceRear;
    }
    
    [mCameraViewController setCameraDevice:mCameraType];
    [mCameraTypeButton setEnabled:YES];
    if ([UIImagePickerController isFlashAvailableForCameraDevice:mCameraType]) {
        [mFlashButton setEnabled:YES];
    } else {
        [mFlashButton setEnabled:NO];
    }
    
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
        //set correct image orientation
        UIImage *lImage;
//        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && (outputImage.imageOrientation == UIImageOrientationUp || outputImage.imageOrientation == UIImageOrientationDown)){
//            lImage = [outputImage rotateImageToAngle:90];
//        }else{
            lImage = outputImage;
//        }
    
//        UIImage * image = [lImage getScaledImageForTwitter];
    
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            
            self.view.userInteractionEnabled = YES;
            
            GSTwitterPreviewViewController *lPreviewViewController = [[GSTwitterPreviewViewController alloc] initWithImage:lImage isFromCamera:NO];
            [self.navigationController pushViewController:lPreviewViewController animated:YES];
//        });
//    });

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.view.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    
    
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage); //when I use instruments it shows that My VM is because of this
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);//also this line in Instruments
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    
    return img;
    
    
}

#pragma mark - PhotoPickerPlusDelegate
- (void)photoImagePickerControllerDidCancel:(PhotoPickerViewController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    outputImage = [outputImage getScaledImageFromHQ];
    [self dismissViewControllerAnimated:NO completion:nil];
    GSTwitterPreviewViewController *lPreviewViewController = [[GSTwitterPreviewViewController alloc] initWithImage:outputImage isFromCamera:NO];
    [self.navigationController pushViewController:lPreviewViewController animated:YES];
}

- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info{
    DLog(@"info count - %i", [info count]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) animationStart {
    mIsBannerAppear = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
    [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - mBottomView.frame.size.height, mBottomView.frame.size.width, mBottomView.frame.size.height)];
    [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    
    [UIView commitAnimations];

}

#pragma mark - MPAdViewDelegate methods
- (UIViewController *) viewControllerForPresentingModalView{
       return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        NSLog(@"self frame %@", NSStringFromCGRect(self.view.frame));
        [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
      
        [self.view insertSubview:mAdView aboveSubview:mBottomView];
        
        [self animationStart];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
  
}

#pragma mark - GSTutorialOverlayView Delegate
- (void)viewExamplesPressed{
    GSInspirationViewController *lViewController = [[GSInspirationViewController alloc] initWithNibName:@"GSInspirationViewController" bundle:nil andMode:GSTutorialTypeTwitter];
    [lViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lViewController animated:YES];
    lViewController.backButton.hidden = YES;

}


#pragma mark - UIAction shits delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0){
            [Flurry logEvent:@"Twitter screen facebook pressed"];
            PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] initWithService:1];
            [lPhotoController setDelegate:self];
            [lPhotoController setIsMultipleSelectionEnabled:YES];
            [self presentModalViewController:lPhotoController animated:YES];
        } else if (buttonIndex == 1) {
            [Flurry logEvent:@"Twitter screen Instagram pressed"];
            PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] initWithService:3];
            [lPhotoController setDelegate:self];
            [lPhotoController setIsMultipleSelectionEnabled:YES];
            [self presentModalViewController:lPhotoController animated:YES];
        } else if (buttonIndex == 2){
            PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
            [lPhotoController setDelegate:self];
            [lPhotoController setIsMultipleSelectionEnabled:NO];
            [self presentModalViewController:lPhotoController animated:YES];
        }
    }
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

