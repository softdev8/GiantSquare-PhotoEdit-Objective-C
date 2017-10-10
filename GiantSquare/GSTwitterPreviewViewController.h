//
//  GSTwitterPreviewViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 1/2/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import "MPAdView.h"
#import "GSFiltersController.h"
#import "GSTwitterLoginView.h"

@interface GSTwitterPreviewViewController : GSAbstractViewController<UIAlertViewDelegate, GSFiltersControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MPAdViewDelegate, GSTwitterLoginViewDelegate>{
    UIImage *mOriginalImage;
    UIImage *mFilteredImage;
    UIImage *mScaledImage;
    IBOutlet UIButton *mPublishButton;
    IBOutlet UIButton *mContrastButton;
    IBOutlet UIButton *mRotateButton;
    IBOutlet UIView *mBottomMenu;
    IBOutlet UIImageView *mShadowImageView;
    UIScrollView *mScrollView;
    
    MPAdView *mAdView;
    BOOL mIsBannerAppear;
    
    NSInteger mSelectedFilter;
    CGFloat mAngle;
    UIImageView *mImageView;
    GSFiltersController *mFilterController;
    BOOL isContrastActive;
    
    GSTwitterLoginView *mTwitterLogin;
}

- (id)initWithImage:(UIImage*)pImage isFromCamera:(BOOL)pFromCamera;

@end
