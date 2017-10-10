//
//  GSCollageSwitcher.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSCollageSwitcher.h"
#import <QuartzCore/QuartzCore.h>

@interface GSCollageSwitcher()
- (void) panGestureRecognizer:(UIGestureRecognizer*)pGestureRecognizer;
- (void) tapGestureRecognizer:(UIGestureRecognizer*)pGestureRecognizer;
@end

@implementation GSCollageSwitcher

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        mSwitchView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 0.0, 40.0, 40.0)];
        [mSwitchView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:mSwitchView];
        
        mSwitchButton = [[UIImageView alloc] initWithFrame:CGRectMake(-14.0, 4.0, 28.0, 29.0)];//132
        [mSwitchButton setImage:[UIImage imageNamed:@"switcherButton.png"]];
        
        
        mWhiteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-12.0, 8.0, 24.0 + mSwitchButton.center.x, 24.0)];
        [mWhiteImageView setBackgroundColor:[UIColor clearColor]];
        [mWhiteImageView setImage:[[UIImage imageNamed:@"switcher_background_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)]];
        [mSwitchView addSubview:mWhiteImageView];
        
        mBlackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(mSwitchButton.center.x - 12.0, 8.0, 64.0 - mSwitchButton.center.x, 24.0)];
        [mBlackImageView setBackgroundColor:[UIColor clearColor]];
        [mBlackImageView setImage:[[UIImage imageNamed:@"switcher_background_black.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)]];
        [mSwitchView addSubview:mBlackImageView];
        
        [mSwitchView addSubview:mSwitchButton];
        
        
        mTouchView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
        [mTouchView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:mTouchView];
        
        UIPanGestureRecognizer *lPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [mTouchView addGestureRecognizer:lPanGesture];
        
        UITapGestureRecognizer *lTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        [lTapGesture setNumberOfTapsRequired:1];
        [mTouchView addGestureRecognizer:lTapGesture];

        mCurrentState = GSCollageSwitcherTypeBlack;
    }
    return self;
}

- (void) panGestureRecognizer:(UIGestureRecognizer*)pGestureRecognizer {
    UIPanGestureRecognizer *lPanGesture = (UIPanGestureRecognizer*)pGestureRecognizer;
    if (lPanGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint lTrasition = [lPanGesture translationInView:mSwitchView];
        CGFloat lNewCenterX = mSwitchButton.center.x + lTrasition.x;
        
        if (lNewCenterX < 0.0) {
            lNewCenterX = 0.0;
        }
        
        if (lNewCenterX > 40.0) {
            lNewCenterX = 40.0;
        }
        
        if (lNewCenterX >= 20.0) {
            [mBlackButton setSelected:NO];
            [mWhiteButton setSelected:YES];
        } else {
            [mBlackButton setSelected:YES];
            [mWhiteButton setSelected:NO];
        }
        
        [mSwitchButton setCenter:CGPointMake(lNewCenterX, mSwitchButton.center.y)];
        [mWhiteImageView setFrame:CGRectMake(-12.0, 8.0, 24.0 + mSwitchButton.center.x, 24.0)];
        [mBlackImageView setFrame:CGRectMake(mSwitchButton.center.x - 12.0, 8.0, 64.0 - mSwitchButton.center.x, 24.0)];
        
        [lPanGesture setTranslation:CGPointZero inView:mSwitchView];
    } else if (lPanGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint lTrasition = [lPanGesture translationInView:mSwitchView];
        CGFloat lNewCenterX = mSwitchButton.center.x + lTrasition.x;
        
        if (lNewCenterX < 20.0) {
            [self setState:GSCollageSwitcherTypeBlack];
        } else {
            [self setState:GSCollageSwitcherTypeWhite];
        }
        
        [lPanGesture setTranslation:CGPointZero inView:mSwitchView];
    }
}

- (void) tapGestureRecognizer:(UIGestureRecognizer*)pGestureRecognizer {
    UIPanGestureRecognizer *lPanGesture = (UIPanGestureRecognizer*)pGestureRecognizer;
    if (lPanGesture.state == UIGestureRecognizerStateChanged) {

    } else if (lPanGesture.state == UIGestureRecognizerStateEnded) {
        if (mCurrentState == GSCollageSwitcherTypeBlack) {
            [self setState:GSCollageSwitcherTypeWhite];
        } else {
            [self setState:GSCollageSwitcherTypeBlack];
        }
    }
}

- (void) setState:(GSCollageSwitcherType)pState {
    mCurrentState = pState;
    CGFloat lNewCenterX = 0.0;
    if (pState == GSCollageSwitcherTypeWhite) {
        lNewCenterX = 40.0;
    } else {
    }
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(GSCollageSwitcherDelegateSelectedType:)]) {
            [self.delegate GSCollageSwitcherDelegateSelectedType:mCurrentState];
        } else {
            NSLog(@"GSCollageSwitcher - not found selector");
        }
    } else {
        NSLog(@"GSCollageSwitcher - not found delegate");
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction  animations:^{
        [mSwitchButton setCenter:CGPointMake(lNewCenterX, mSwitchButton.center.y)];
        [mWhiteImageView setFrame:CGRectMake(-12.0, 8.0, 24.0 + mSwitchButton.center.x, 24.0)];
        [mBlackImageView setFrame:CGRectMake(mSwitchButton.center.x - 12.0, 8.0, 64.0 - mSwitchButton.center.x, 24.0)];
    } completion:^(BOOL finished) {
        
    }];
    
    
}


@end
