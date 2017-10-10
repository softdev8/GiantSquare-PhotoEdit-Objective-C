//
//  GSBuyPopupView.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/29/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSBuyPopupViewDelegate <NSObject>
- (void) GSBuyPopupViewDelegateAdsPressed;
- (void) GSBuyPopupViewDelegateWatermarkPressed;
- (void) GSBuyPopupViewDelegateFramesPressed;
- (void) GSBuyPopupViewDelegateBuyPressed;
- (void) GSBuypopupviewdelegateFontPressed;
- (void) GSBuyPopupViewDelegateCancelPressed;
@end

@interface GSBuyPopupView : UIView {
    IBOutlet UIView *mAlertView;
    IBOutlet UIButton *mAdsButton;
    IBOutlet UIButton *mFramesButton;
    IBOutlet UIButton *mWatermarkButton;
    IBOutlet UIButton *mFontButton;
}

@property (nonatomic, unsafe_unretained) id <GSBuyPopupViewDelegate> delegate;

- (void) hideMessage;
- (void)startDisplaying;

@end

