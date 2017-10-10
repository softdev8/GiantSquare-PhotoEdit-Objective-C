//
//  GSInstagramCollageViewController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/15/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSCollageViewController.h"


@interface GSInstagramCollageViewController : GSCollageViewController  {
    IBOutlet UIView *mBottomView;
    IBOutlet UIImageView *mBottomHeader;
    IBOutlet UIButton *mShowHideCollagesButton;
    GSCollageSwitcher *mSwitcher;
    
    BOOL mIsCollageControllerShowed;
}

- (IBAction) showHideCollageControllerButtonPressed:(id)pSender;

@end

