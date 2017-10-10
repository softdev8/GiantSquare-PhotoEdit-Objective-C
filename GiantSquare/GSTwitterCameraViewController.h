//
//  GSTwitterCameraViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 1/2/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerViewController.h"
#import "GADBannerView.h"
#import "MPAdView.h"
#import "GSTutorialOverlayView.h"

@interface GSTwitterCameraViewController : GSAbstractViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoPickerViewControllerDelegate , MPAdViewDelegate, GSTutorialOverlayViewDelegate,UIActionSheetDelegate>{
    IBOutlet UIView *mBottomView;
    IBOutlet UIButton *mTakePhotoButton;
    IBOutlet UIButton *mCameraRollButton;
    IBOutlet UIView *mTopView;
    IBOutlet UIButton *mFlashButton;
    IBOutlet UIButton *mCameraTypeButton;
    IBOutlet UIImageView *mShadowImageView;
    IBOutlet UIImageView *mImageView;
    IBOutlet UIView *mTakePhotoView;
    
    BOOL mIsBannerAppear;
    
    MPAdView *mAdView;

    UIImagePickerController *mCameraViewController;
    
    UIImagePickerControllerCameraDevice mCameraType;
}

@end
