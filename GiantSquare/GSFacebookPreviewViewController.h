//
//  GSFacebookPreviewViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 12/26/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFiltersController.h"
#import "GSFacebookLoginView.h"
#import "GSTutorialOverlayView.h"

@interface GSFacebookPreviewViewController : GSAbstractViewController <UIScrollViewDelegate, GSFiltersControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, GSFacebookLoginViewDelegate, GSTutorialOverlayViewDelegate> {
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UIButton *mBackButton;
    IBOutlet UIButton *mPublishButton;
    IBOutlet UIScrollView *mScrollSizeView;
    IBOutlet UIButton *mContrastButton;
    UIScrollView *mScrollView;
    
    IBOutlet UIImageView *mBackgroundImageView;
    
    IBOutlet UIButton *mRotateButton;
    

    GSFiltersController *mFilterController;
    
    UIImageView *mImageView;
    
    UIImage *mOriginalImage;
    UIImage *mFilteredImage;
    
    UIButton *mSelectedButton;
    BOOL isCamera;
    
    NSInteger mSelectedFilter;
    CGFloat mAngle;
    BOOL isContrastActive;
    BOOL mTimeLineIsNew;
}

@property (nonatomic, readwrite) BOOL timeLineIsNew;

- (id)initWithImage:(UIImage*)pImage isCamera:(BOOL)pIsCamera;

@end
