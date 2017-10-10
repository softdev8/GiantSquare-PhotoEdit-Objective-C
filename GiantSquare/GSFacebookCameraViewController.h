//
//  GSFacebookCameraViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 12/20/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
#import "GSFacebookPreviewViewController.h"
#import "PhotoPickerViewController.h"
#import "GSTutorialOverlayView.h"
#import "GSMainManualViewController.h"

@interface GSFacebookCameraViewController : GSAbstractViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoPickerViewControllerDelegate, GSTutorialOverlayViewDelegate, UIAlertViewDelegate> {
    IBOutlet UIImageView *mBackgroundImageView;
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UIButton *mCancelButton;
    IBOutlet UIButton *mOnOffLightButton;
    IBOutlet UIButton *mFlipButton;
    IBOutlet UIButton *mCameraRollButton;
    IBOutlet UIButton *mTakePhotoButton;
    IBOutlet UIView *mTakePhotoView;
    UIImagePickerController *mCameraViewController;
    
    UIImagePickerControllerCameraDevice mCameraType;
    
    //alert view
    
    IBOutlet UIView *mAlertView;
    IBOutlet UIView *mAlertViewBAckground;
    IBOutlet UIButton *mOldAlertButton;
    IBOutlet UIButton *mNewAlertButton;
    IBOutlet UIButton *mHelpButton;
    IBOutlet UIView *mWhatsThisView;
    
    BOOL mTimeLineIsNew;
}

@property (nonatomic, readwrite) BOOL timeLineIsNew;

- (IBAction) cancelButtonPressed:(id)pSender;
- (IBAction) onOffLightButtonPressed:(id)pSender;
- (IBAction) flipButtonPressed:(id)pSender;
- (IBAction) cameraRollButtonPressed:(id)pSender;
- (IBAction) takePhotoButtonPressed:(id)pSender;
@end
