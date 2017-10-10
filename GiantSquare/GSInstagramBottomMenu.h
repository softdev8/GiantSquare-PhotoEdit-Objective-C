//
//  GSInstagramBottomMenu.h
//  GiantSquare
//
//  Created by roman.andruseiko on 3/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSInstagramBottomMenuDelegate <NSObject>
- (void) GSInstagramBottomMenuDonePressed;
- (void) GSInstagramBottomMenuCancelPressed;

- (void) GSInstagramBottomMenuCameraPressed;
- (void) GSInstagramBottomMenuCameraRollPressed;
- (void) GSInstagramBottomMenuRemovePressed;
@end

@interface GSInstagramBottomMenu : UIView{
    IBOutlet UILabel *mHelpLabel;
    IBOutlet UIButton *mCameraRollButton;
    IBOutlet UIButton *mCameraButton;
    IBOutlet UIButton *mRemoveButton;
    IBOutlet UIButton *mCancelButton;
    IBOutlet UIButton *mDoneButton;
    IBOutlet UIView *mSeparator;

    __unsafe_unretained id <GSInstagramBottomMenuDelegate> mDelegate;
    
    NSInteger mState;
}

@property (nonatomic, assign) id delegate;

- (void)setMenuState:(NSInteger)pState;
- (NSInteger) state;
@end
