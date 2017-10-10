//
//  GSInstagramEditViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 3/14/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerViewController.h"
#import "GSInstagramElement.h"
#import "GSInstagramBottomMenu.h"
#import "MPAdView.h"
#import "GSTutorialOverlayView.h"

typedef enum {
    GSButtonTypeMark,
    GSButtonTypeDelete,
    GSButtonTypeAdd,
    GSButtonTypeUsed
} GSButtonType;

@interface GSInstagramEditViewController : GSAbstractViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoPickerViewControllerDelegate, UIActionSheetDelegate, GSInstagramBottomMenuDelegate, MPAdViewDelegate, GSTutorialOverlayViewDelegate> {
    IBOutlet UIImageView *mGridView;
    IBOutlet UIView *mGesturesView;
    IBOutlet UIButton *mExportButton;
    IBOutlet UIButton *mChangeLabelButton;
    
    GSInstagramBottomMenu *mBottomMenu;
    GSInstagramElement *mCurrentElement;
    MPAdView *mAdView;
    
    NSMutableArray *mArrayOfMarkButtons;
    NSMutableArray *mArrayOfDeleteButtons;
    NSMutableArray *mArrayOfAddButtons;
    NSMutableArray *mArrayOfAddChanges;
    NSMutableArray *mArrayOfElements;
    NSMutableArray *mArrayOfCuttedImages;
    
    NSInteger mCountOfScrollViews;
    
    BOOL mIsBannerAppear;
    BOOL mIsAddState;
    BOOL mIsRemoveState;
    
    BOOL mIsChange;
    
}

- (IBAction) changeLabelStateButtonPressed:(UIButton*)pSender;
@end
