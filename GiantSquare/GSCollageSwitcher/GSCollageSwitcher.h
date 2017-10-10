//
//  GSCollageSwitcher.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GSCollageSwitcherTypeWhite,
    GSCollageSwitcherTypeBlack
} GSCollageSwitcherType;

@protocol GSCollageSwitcherDelegate;
@interface GSCollageSwitcher : UIView <UIScrollViewDelegate> {
    UIView *mSwitchView;
    UIView *mTouchView;
    UIButton *mBlackButton;
    UIButton *mWhiteButton;
    UIImageView *mWhiteImageView;
    UIImageView *mBlackImageView;
    UIImageView *mSwitchButton;
    
    GSCollageSwitcherType mCurrentState;
}

@property (nonatomic, assign) id <GSCollageSwitcherDelegate> delegate;

- (void) setState:(GSCollageSwitcherType)pState;

@end

@protocol GSCollageSwitcherDelegate <NSObject>
- (void) GSCollageSwitcherDelegateSelectedType:(GSCollageSwitcherType)pType;
@end