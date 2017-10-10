//
//  GSBuyPopupView.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/29/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSBuyPopupView.h"

#define MESSAGE_WIDTH 290.0
#define GO_PRO_MESSAGE_HEIGHT 203.0
#define BUY_MESSAGE_HEIGHT 241.0
#define BUTTON_WIDTH 127.0
#define BUTTON_HEIGHT 42.0

@interface GSBuyPopupView()

@end

@implementation GSBuyPopupView


- (void)awakeFromNib{
    [super awakeFromNib];

    //disable purchased items
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
        mAdsButton.enabled = NO;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_FRAMES]) {
        mFramesButton.enabled = NO;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
        mWatermarkButton.enabled = NO;
    }
    
    [mAlertView setTransform:CGAffineTransformMakeScale(0.05, 0.05)];
    [self setAlpha:0.2];
    
    [UIView animateWithDuration:0.16 delay:0.0 options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mAlertView setTransform:CGAffineTransformMakeScale(1.08, 1.08)];
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.01 options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [mAlertView setTransform:CGAffineTransformMakeScale(0.96, 0.96)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
                [mAlertView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            } completion:nil];
        }];
    }];
}

- (void)startDisplaying{
    [self setFrame:self.superview.frame];
}

- (void) hideMessage {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mAlertView setTransform:CGAffineTransformMakeScale(1.08, 1.08)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0.01 options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [mAlertView setTransform:CGAffineTransformMakeScale(0.05, 0.05)];
            [self setAlpha:0.2];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

#pragma mark - buttons methods
- (IBAction)adsButtonPressed:(id)pSender {
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(GSBuyPopupViewDelegateAdsPressed)]) {
            [_delegate GSBuyPopupViewDelegateAdsPressed];
        }
    }
}

- (IBAction)watermarkButtonPressed:(id)pSender {
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(GSBuyPopupViewDelegateWatermarkPressed)]) {
            [_delegate GSBuyPopupViewDelegateWatermarkPressed];
        }
    }
}

- (IBAction)fontButtonPressed:(id)sender
{
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(GSBuypopupviewdelegateFontPressed)]) {
            [_delegate GSBuypopupviewdelegateFontPressed];
        }
    }
}

- (IBAction)framesButtonPressed:(id)pSender {
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(GSBuyPopupViewDelegateFramesPressed)]) {
            [_delegate GSBuyPopupViewDelegateFramesPressed];
        }
    }
}

- (IBAction)buyAllButtonPressed:(id)pSender {
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(GSBuyPopupViewDelegateBuyPressed)]) {
            [_delegate GSBuyPopupViewDelegateBuyPressed];
        }
    }
}

- (IBAction)cancelButtonPressed:(id)pSender {
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(GSBuyPopupViewDelegateCancelPressed)]) {
            [_delegate GSBuyPopupViewDelegateCancelPressed];
        }
    }
}


@end
