//
//  GSInstagramBottomMenu.m
//  GiantSquare
//
//  Created by roman.andruseiko on 3/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSInstagramBottomMenu.h"

@implementation GSInstagramBottomMenu

@synthesize delegate = mDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        mState = 0;
    }
    return self;
}

- (void) setMenuState:(NSInteger)pState{
    mState = pState;
    switch (pState) {
        case 0:{//selected - none
            //showed elements
//            mHelpLabel.text = @"Select the squares you want to load\na picture in or tap a picture to edit";
            mHelpLabel.center = CGPointMake(self.frame.size.width / 2.0, mHelpLabel.center.y);
            mHelpLabel.hidden = YES;
            
            //hidden elements
            mCameraRollButton.hidden = NO;
            mCameraButton.hidden = NO;
            mCancelButton.hidden = YES;
            mDoneButton.hidden = YES;
            mRemoveButton.hidden = NO;
            mSeparator.hidden = NO;
            [mCameraRollButton setEnabled:NO];
            [mCameraButton setEnabled:NO];
            [mRemoveButton setEnabled:NO];
            break;
        }
        case 1:{//squares only is selected
            //showed elements
            mCameraRollButton.hidden = NO;
            [mCameraRollButton setEnabled:YES];
            mCameraButton.hidden = NO;
            [mCameraButton setEnabled:YES];
            mRemoveButton.hidden = NO;
            [mRemoveButton setEnabled:NO];
            mSeparator.hidden = NO;
            
            
            //hidden elements
            mDoneButton.hidden = YES;
            mHelpLabel.hidden = YES;
            mCancelButton.hidden = YES;
            break;
        }
        case 2:{//element is selected
            //showed elements
            mCameraRollButton.hidden = NO;
            [mCameraRollButton setEnabled:YES];
            mCameraButton.hidden = NO;
            [mCameraButton setEnabled:YES];
            mRemoveButton.hidden = NO;
            [mRemoveButton setEnabled:YES];
            mSeparator.hidden = NO;
            
            //hidden elements
            mDoneButton.hidden = YES;
            mHelpLabel.hidden = YES;
            mCancelButton.hidden = YES;
            break;
        }
        case 3:{//no FREE squares
            //showed elements
            mCameraRollButton.hidden = NO;
            [mCameraRollButton setEnabled:NO];
            mCameraButton.hidden = NO;
            [mCameraButton setEnabled:NO];
            mRemoveButton.hidden = NO;
            [mRemoveButton setEnabled:YES];
            mSeparator.hidden = NO;
            
            //hidden elements
            mDoneButton.hidden = YES;
            mHelpLabel.hidden = YES;
            mCancelButton.hidden = YES;
            break;
        }
        case 4:{//selected element is editing
            //showed elements
            mCancelButton.hidden = NO;
            mDoneButton.hidden = NO;
            
            //hidden elements
            mHelpLabel.hidden = YES;
            mCameraRollButton.hidden = YES;
            mCameraButton.hidden = YES;
            mRemoveButton.hidden = YES;
            mSeparator.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (NSInteger) state {
    return mState;
}

#pragma mark - buttons methods

- (IBAction) cameraRollPressed:(id)pSender {
    if ([mDelegate respondsToSelector:@selector(GSInstagramBottomMenuCameraRollPressed)]) {
        [mDelegate GSInstagramBottomMenuCameraRollPressed];
    }
}

- (IBAction) cameraPressed:(id)pSender {
    if ([mDelegate respondsToSelector:@selector(GSInstagramBottomMenuCameraPressed)]) {
        [mDelegate GSInstagramBottomMenuCameraPressed];
    }
}

- (IBAction) donePressed:(id)pSender {
    if ([mDelegate respondsToSelector:@selector(GSInstagramBottomMenuDonePressed)]) {
        [mDelegate GSInstagramBottomMenuDonePressed];
    }
}

- (IBAction) cancelPressed:(id)pSender {
    if ([mDelegate respondsToSelector:@selector(GSInstagramBottomMenuCancelPressed)]) {
        [mDelegate GSInstagramBottomMenuCancelPressed];
    }
}

- (IBAction) removePressed:(id)pSender {
    if ([mDelegate respondsToSelector:@selector(GSInstagramBottomMenuRemovePressed)]) {
        [mDelegate GSInstagramBottomMenuRemovePressed];
    }
}

@end
