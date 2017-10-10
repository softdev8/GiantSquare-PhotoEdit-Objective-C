//
//  GSFiltersController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 12/29/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import "GSFiltersController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GSFiltersController

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        mScrolView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [mScrolView setBackgroundColor:[UIColor clearColor]];
        [mScrolView setShowsHorizontalScrollIndicator:NO];
        [mScrolView setShowsVerticalScrollIndicator:NO];
        [mScrolView setDelegate:self];
        [self addSubview:mScrolView];
        
        //init shadows
        mLeftShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 80.0f)];
//        [mLeftShadowImageView setImage:[UIImage imageNamed:@"facebook_shadow.png"]];
        [self addSubview:mLeftShadowImageView];
        
        mRightShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 16.0f, 0.0f, 16.0f, 80.0f)];
//        [mRightShadowImageView setImage:[UIImage imageNamed:@"facebook_shadow_right.png"]];
        [self addSubview:mRightShadowImageView];
        
        //init normal filter
        UIButton *lNormalFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 15.0f, 50.0f, 50.0f)];
//        [lNormalFilterButton setBackgroundImage:[UIImage imageNamed:@"normal.png"] forState:UIControlStateNormal];
//        [lNormalFilterButton setImage:[UIImage imageNamed:@"filter_button_cover.png"] forState:UIControlStateNormal];
        lNormalFilterButton.layer.cornerRadius = 3.0f;
        [lNormalFilterButton.layer setMasksToBounds:YES];

        //title
        [lNormalFilterButton setTitle:@"Normal" forState:UIControlStateNormal];
        [lNormalFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lNormalFilterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [lNormalFilterButton.titleLabel setShadowColor:[UIColor blackColor]];
        [lNormalFilterButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [lNormalFilterButton setTitleEdgeInsets:UIEdgeInsetsMake(35.0, -50.0, 0.0, 0.0)];
        [lNormalFilterButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        
        [lNormalFilterButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
        lNormalFilterButton.tag = GSFilterTypeNormal;
        [lNormalFilterButton setSelected:YES];
        mSelectedFilterButton = lNormalFilterButton;
		[mScrolView addSubview:lNormalFilterButton];
        
        CGFloat lLastX = 70;
        for(NSUInteger index = 0; index < FILTERS_COUNT; index++) {
            NSString *lFilterNale = @"";//[NSString stringWithFormat:@"f%i.png", index];
            UIButton * lFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(lLastX, 15.0f, 50.0f, 50.0f)];
            [lFilterButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
            lFilterButton.tag = index;
//            [lFilterButton setImage:[UIImage imageNamed:@"filter_button_cover.png"] forState:UIControlStateNormal];
            [lFilterButton setBackgroundImage:[UIImage imageNamed:lFilterNale] forState:UIControlStateNormal];
            //[lFilterButton setImageEdgeInsets:UIEdgeInsetsMake(-10.0, 0.0f, 10.0, 0.0f)];
            
            lFilterButton.layer.cornerRadius = 3.0f;
            [lFilterButton.layer setMasksToBounds:YES];
            
            //title
            [lFilterButton setTitle:[NSString stringWithFormat:@"filter%i", index] forState:UIControlStateNormal];
            [lFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [lFilterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
            [lFilterButton.titleLabel setShadowColor:[UIColor blackColor]];
            [lFilterButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
            [lFilterButton setTitleEdgeInsets:UIEdgeInsetsMake(35.0, -50.0, 0.0, 0.0)];
            [lFilterButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
            
            [mScrolView addSubview:lFilterButton];
            
            lLastX+=60;
        }
        [mScrolView setContentSize:CGSizeMake(lLastX, 80.0)];
        [mLeftShadowImageView setAlpha:0.0f];
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat lLeftAlpha = scrollView.contentOffset.x / 16.0f;
    [mLeftShadowImageView setAlpha:lLeftAlpha];
    
    CGFloat lRightAlpha = (scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.size.width) / 16.0f;
    [mRightShadowImageView setAlpha:lRightAlpha];
}

-(void) filterClicked:(UIButton *)pSender {
    if (mSelectedFilterButton != nil) {
        [mSelectedFilterButton setSelected:NO];
    }
    [pSender setSelected:YES];
    mSelectedFilterButton = pSender;

    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(filterSetted:)]) {
                [self.delegate filterSetted:pSender.tag];
        }
    }
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(GSFiltersControllerDelegateOriginalImage)]) {
            UIImage *lOriginalImage = [self.delegate GSFiltersControllerDelegateOriginalImage];
            if ([self.delegate respondsToSelector:@selector(GSFiltersControllerDelegateFilteredImage:)]) {
                UIImage *lFilteredImage = [self makeFilter:pSender.tag toImage:lOriginalImage];
                [self.delegate GSFiltersControllerDelegateFilteredImage:lFilteredImage];
            }
        }
    }

    CGFloat lNewX = pSender.center.x - mScrolView.frame.size.width / 2;
    if (lNewX < 0) {
        lNewX = 0;
    } else if (lNewX > (mScrolView.contentSize.width - mScrolView.frame.size.width)) {
        lNewX = mScrolView.contentSize.width - mScrolView.frame.size.width;
    }
    [mScrolView setContentOffset:CGPointMake(lNewX, 0.0f) animated:YES];
}

- (UIImage*) makeFilter:(GSFilterType)pFilter toImage:(UIImage*)pOriginalImage {
    UIImage *lResult = nil;
    DLog(@"make filter %i", pFilter);
    switch (pFilter) {
        case GSFilterTypeNormal:{
            GPUImageFilter *lFilter = [[GPUImageFilter alloc] init];
            lResult = [lFilter imageByFilteringImage:pOriginalImage];
            break;
        }
        case GSFilterType5:{
            GrayscaleContrastFilter *lFilter = [[GrayscaleContrastFilter alloc] init];
            lResult = [[lFilter imageByFilteringImage:pOriginalImage] addTextureImage];
            break;
        }
        case GSFilterType18:{
            GrayscaleContrastFilter *lFilter = [[GrayscaleContrastFilter alloc] init];
            lResult = [lFilter imageByFilteringImage:pOriginalImage];
            break;
        }
        case GSFilterTypeContrast:{
            GPUImageContrastFilter *lFilter = [[GPUImageContrastFilter alloc] init];
            [lFilter setContrast:1.4];
            lResult = [lFilter imageByFilteringImage:pOriginalImage];
            break;
        }
        default: {
            //great overlay
            GPUImageToneCurveFilter *lFilter = [[GPUImageToneCurveFilter alloc] initWithACV:[NSString stringWithFormat:@"f%i", pFilter]];
            
            if (pFilter == GSFilterType0) {//done
                lResult = [[[lFilter imageByFilteringImage:pOriginalImage] addShadowEffectImage] addTextureImage];
            } else if (pFilter == GSFilterType1) {//done                
                lResult = [[lFilter imageByFilteringImage:pOriginalImage] addShadowImage];
            } else if (pFilter == GSFilterType2) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.4f andEnd:0.9f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType3) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.6f } andStart:0.45f andEnd:0.9f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType4) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.3f andEnd:0.9f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType6) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.15f andEnd:0.8f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            }  else if (pFilter == GSFilterType7) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.4f andEnd:0.8f];
                lResult = [[lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]] addTextureImage];
            } else if (pFilter == GSFilterType8) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.6f, 0.4f } andStart:0.4f andEnd:0.99f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType9) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.15f andEnd:1.0f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType10) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.2f andEnd:0.8f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType11) {//done
                lResult = [[[lFilter imageByFilteringImage:pOriginalImage] addTextureImage] addShadowImage];
            } else if (pFilter == GSFilterType12) {//done
                lResult = [[lFilter imageByFilteringImage:pOriginalImage] addTextureImage];
            } else if (pFilter == GSFilterType13) {//done
                lResult = [lFilter imageByFilteringImage:pOriginalImage];
            } else if (pFilter == GSFilterType14) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.5f, 0.5f } andStart:0.2f andEnd:1.0f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else if (pFilter == GSFilterType15) {//done
                GPUImageVignetteFilter * lVignetteFilter = [[GPUImageVignetteFilter alloc] initWithCenter:(CGPoint){ 0.6f, 0.4f } andStart:0.4f andEnd:1.0f];
                lResult = [lFilter imageByFilteringImage:[lVignetteFilter imageByFilteringImage:pOriginalImage]];
            } else {
                lResult = [lFilter imageByFilteringImage:pOriginalImage];
            }
            
            break;
        } 
    }
    return lResult;
}


@end
