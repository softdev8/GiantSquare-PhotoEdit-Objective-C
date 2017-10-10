//
//  GSFacebookCameraViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 12/20/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import "GSFacebookCameraViewController.h"
#import "GSCustomNavigationController.h"
#import "MBBProgressHUD.h"
#import "GSManualViewController.h"
#import "GSInspirationViewController.h"
#import "Flurry.h"

@interface GSFacebookCameraViewController ()

@end

@implementation GSFacebookCameraViewController

@synthesize timeLineIsNew=mTimeLineIsNew;

#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      mTimeLineIsNew = NO;
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

#pragma mark - view life cycle
- (void)viewDidLoad{
    [super viewDidLoad];

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
    
    self.wantsFullScreenLayout = YES;
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"background.png", @"background_iPhone5.png")]]];
    
    mCameraType = UIImagePickerControllerCameraDeviceRear;
    
    CGFloat lScale = 1.035f;
    CGFloat lOffset = 284.0;
    if ([UIScreen mainScreen].bounds.size.height < 560.0) {
        lScale = 1.25;
        lOffset = 240.0;
    }
    
    mCameraViewController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] ||
        [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [mCameraViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
        [mTakePhotoView addSubview:mCameraViewController.view];
        [mCameraViewController.view setCenter:CGPointMake(lOffset, self.view.frame.size.height / 2)];
        [mCameraViewController setShowsCameraControls:NO];
        [mCameraViewController setCameraViewTransform:CGAffineTransformMakeScale(lScale, lScale)];
        [mCameraViewController.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        [mCameraViewController.cameraOverlayView setFrame:mTakePhotoView.frame];
        [mCameraViewController setDelegate:self];
        [mCameraViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
        
        if (![UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
            [mOnOffLightButton setEnabled:NO];
        }
    }
    
    //camera roll button
    [mCameraRollButton setClipsToBounds:YES];
    [mCameraRollButton.layer setCornerRadius:5.0f];
    [self setImageFromCameraRollButton];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //hide navigation bar
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    [mCameraViewController viewWillAppear:animated];
    
    // show tutorial at first start
    if (!getVal(@"firstStartFacebook")) {
        setVal(@"firstStartFacebook", @"NO");
        GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeFacebook];
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

#pragma mark - buttons methods
- (IBAction) cancelButtonPressed:(id)pSender {
    DLog(@"cancelButtonPressed");
    [self.navigationController popViewControllerAnimated:YES];
    [Flurry endTimedEvent:@"facebookGiantPressed" withParameters:nil];
}

- (IBAction) onOffLightButtonPressed:(id)pSender {
    DLog(@"onOffLightButtonPressed");
    if ([pSender isKindOfClass:[UIButton class]]) {
        UIButton *lButton = (UIButton*)pSender;
        [lButton setSelected:!lButton.selected];
        
        if (lButton.selected) {
            [mCameraViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
        } else {
            [mCameraViewController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
        }
    }
}

- (IBAction) flipButtonPressed:(id)pSender {
    DLog(@"flipButtonPressed");
    [mFlipButton setEnabled:NO];
    
    if (mCameraType == UIImagePickerControllerCameraDeviceRear) {
        mCameraType = UIImagePickerControllerCameraDeviceFront;
    } else {
        mCameraType = UIImagePickerControllerCameraDeviceRear;
    }
    
    [mCameraViewController setCameraDevice:mCameraType];
    [mFlipButton setEnabled:YES];
    if ([UIImagePickerController isFlashAvailableForCameraDevice:mCameraType]) {
        [mOnOffLightButton setEnabled:YES];
    } else {
        [mOnOffLightButton setEnabled:NO];
    }
    
}

- (IBAction) cameraRollButtonPressed:(id)pSender {
    if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
        PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
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

- (IBAction) takePhotoButtonPressed:(id)pSender {
   DLog(@"takePhotoButtonPressed");
    self.view.userInteractionEnabled = NO;
    [mCameraViewController takePicture];
}

- (IBAction)helpPressed:(id)sender{
    GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeFacebook];
    lHelp.delegate = self;
    [self.view addSubview:lHelp];
    [lHelp loadTutorial];
}

#pragma mark - iOS5 alert
- (void)showiOS5Alert{
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:IOS5_ALERT_TITLE_TEXT message:IOS5_ALERT_DESCRIPTION delegate:nil cancelButtonTitle:IOS5_ALERT_SUCCESS_BUTTON otherButtonTitles:IOS5_ALERT_DONT_REMIND_BUTTON, nil];
    lAlertView.delegate = self;
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
    if (buttonIndex == 1) {
        setVal(@"stopRepeatAlert", @"YES");
    }
    [self openCameraRoll];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        UIImage * image = [outputImage getScaledImageFromHQ];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            [picker dismissViewControllerAnimated:NO completion:nil];
            
            GSFacebookPreviewViewController *lPreviewViewController = [[GSFacebookPreviewViewController alloc] initWithImage:outputImage isCamera:YES];
            lPreviewViewController.timeLineIsNew = mTimeLineIsNew;
            [self.navigationController pushViewController:lPreviewViewController animated:YES];
//        });
//    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.view.userInteractionEnabled = YES;
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - PhotoPickerPlusDelegate
- (void)photoImagePickerControllerDidCancel:(PhotoPickerViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    GSFacebookPreviewViewController *lPreviewViewController = [[GSFacebookPreviewViewController alloc] initWithImage:outputImage isCamera:NO];
    lPreviewViewController.timeLineIsNew = mTimeLineIsNew;
    [self.navigationController pushViewController:lPreviewViewController animated:YES];

}

- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info{
    DLog(@"info count - %i", [info count]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -InterfaceOrientation methods-

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - GSTutorialOverlayView Delegate
- (void)viewExamplesPressed{
    GSInspirationViewController *lViewController = [[GSInspirationViewController alloc] initWithNibName:@"GSInspirationViewController" bundle:nil andMode:GSTutorialTypeFacebook];
    [lViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lViewController animated:YES];
    lViewController.backButton.hidden = YES;
}


@end
