//
//  GSCollageController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSCollageControllerDelegate;
@interface GSCollageController : UIView <UIScrollViewDelegate> {
    UIImageView *mLeftShadowImageView;
    UIImageView *mRightShadowImageView;
    UIScrollView *mScrolView;
    UIButton *mSelectedFilterButton;
    
    BOOL mHasBackground;
}

@property (nonatomic, assign) id <GSCollageControllerDelegate> delegate;

- (void) loadTemplates;
#pragma mark GSInstagramTextSquare
- (void) loadtemplates_Square;
- (void) setBlackBackground:(BOOL)pHas;
@end

@protocol GSCollageControllerDelegate <NSObject>
- (BOOL) GSCollageControllerDelegateSelectedCollage:(NSUInteger)pIndex;
#pragma mark square selected==============//
- (void) GSCollageControllerDelegateSelectedSquareBackground:(NSInteger)pIndex;

- (CGSize) GSCollageControllerDelegateTemplateSize;
- (UIImage*) GSCollageControllerDelegateImageForTemplate:(NSUInteger)pIndex;
- (UIImage*) GSCollageControllerDelegateImageForActiveTemplate:(NSUInteger)pIndex;
- (NSUInteger) GSCollageControllerDelegateCountOfTamplates;
- (NSUInteger) GSCollageControllerDelegateCountOfFreeTamplates;
@end
