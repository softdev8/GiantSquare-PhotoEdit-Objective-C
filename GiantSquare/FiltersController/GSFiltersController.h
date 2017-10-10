//
//  GSFiltersController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 12/29/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayscaleContrastFilter.h"
#import "GPUImage.h"

#define FILTERS_COUNT 19

typedef enum {
    GSFilterType0,
    GSFilterType1,
    GSFilterType2,
    GSFilterType3,
    GSFilterType4,
    GSFilterType5,
    GSFilterType6,
    GSFilterType7,
    GSFilterType8,
    GSFilterType9,
    GSFilterType10,
    GSFilterType11,
    GSFilterType12,
    GSFilterType13,
    GSFilterType14,
    GSFilterType15,
    GSFilterType16,
    GSFilterType17,
    GSFilterType18,
    GSFilterTypeNormal,
    GSFilterTypeContrast,
} GSFilterType;

@protocol GSFiltersControllerDelegate;
@interface GSFiltersController : UIView <UIScrollViewDelegate> {
    UIImageView *mLeftShadowImageView;
    UIImageView *mRightShadowImageView;
    UIScrollView *mScrolView;
    UIButton *mSelectedFilterButton;
}

@property (nonatomic, assign) id <GSFiltersControllerDelegate> delegate;

- (UIImage*) makeFilter:(GSFilterType)pFilter toImage:(UIImage*)pOriginalImage;

@end

@protocol GSFiltersControllerDelegate <NSObject>

- (UIImage*) GSFiltersControllerDelegateOriginalImage;
- (void) GSFiltersControllerDelegateFilteredImage:(UIImage*)pFilteredImage;
- (void) filterSetted:(NSInteger)pIndex;

@end