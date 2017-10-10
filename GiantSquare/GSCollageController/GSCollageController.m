//
//  GSCollageController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSCollageController.h"
#import <QuartzCore/QuartzCore.h>

@interface GSCollageController()
- (void) selectedCollage:(UIButton *)pSender;
@end

@implementation GSCollageController

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        mHasBackground = NO;
        
        // Initialization code
        mScrolView = [[UIScrollView alloc] initWithFrame:self.bounds];
        UIColor *backColor = [UIColor colorWithRed:191/255.f green:191/255.f blue:191/255.f alpha:1.f];
        [self setBackgroundColor:backColor];
        
        
        [mScrolView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        [mScrolView setBackgroundColor:[UIColor clearColor]];
        [mScrolView setShowsHorizontalScrollIndicator:NO];
        [mScrolView setShowsVerticalScrollIndicator:NO];
        [mScrolView setDelegate:self];
        [self addSubview:mScrolView];
        
        //init shadows
        mLeftShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, (frame.size.height - 80.0) / 2.0, 16.0f, 80.0)];
        [mLeftShadowImageView setImage:[UIImage imageNamed:@"facebook_shadow.png"]];
        [self addSubview:mLeftShadowImageView];
        
        mRightShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 16.0f, (frame.size.height - 80.0) / 2.0, 16.0f, 80.0)];
        [mRightShadowImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [mRightShadowImageView setImage:[UIImage imageNamed:@"facebook_shadow_right.png"]];
        [self addSubview:mRightShadowImageView];
    
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

- (void)loadTemplates {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(GSCollageControllerDelegateImageForTemplate:)] &&
            [self.delegate respondsToSelector:@selector(GSCollageControllerDelegateTemplateSize)]) {
            
            [mScrolView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            CGSize lTamplateSize = [self.delegate GSCollageControllerDelegateTemplateSize];
            NSUInteger lCountOfTamplates = [self.delegate GSCollageControllerDelegateCountOfTamplates];
            NSUInteger lCountOfFreeTamplates = [self.delegate GSCollageControllerDelegateCountOfFreeTamplates];
            
            CGFloat lLastX = 10;
            for(NSUInteger index = 0; index < lCountOfTamplates; index++) {
                UIButton * lCollageButton = [[UIButton alloc] initWithFrame:CGRectMake(lLastX, (self.frame.size.height - lTamplateSize.height) / 2.0, lTamplateSize.width, lTamplateSize.height)];
                [lCollageButton addTarget:self action:@selector(selectedCollage:) forControlEvents:UIControlEventTouchUpInside];
                lCollageButton.tag = index;
                
                [lCollageButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForTemplate:index] forState:UIControlStateNormal];
                [lCollageButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:index] forState:UIControlStateHighlighted];
                
                [mScrolView addSubview:lCollageButton];
                
                if (index >= lCountOfFreeTamplates) {
                    [lCollageButton setImage:[UIImage imageNamed:@"templates_lock_image.png"] forState:UIControlStateNormal];
                }
                
                if (index == 0) {
                    mSelectedFilterButton = lCollageButton;
                    [mSelectedFilterButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:index] forState:UIControlStateNormal];
                }
                
                lLastX += lTamplateSize.width + 10.0;
            }
            
            [mScrolView setContentSize:CGSizeMake(lLastX, mScrolView.frame.size.height)];
            [mLeftShadowImageView setAlpha:0.0f];
            [mRightShadowImageView setAlpha:1.0];
        }
    } else {
        NSLog(@"not found delegate");
    }
}

- (void) loadtemplates_Square
{
    if (self.delegate != nil) {
        [self setBackgroundColor:[UIColor clearColor]];
        if ([self.delegate respondsToSelector:@selector(GSCollageControllerDelegateImageForTemplate:)] &&
            [self.delegate respondsToSelector:@selector(GSCollageControllerDelegateTemplateSize)]) {
            
            [mScrolView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            CGSize lTamplateSize = [self.delegate GSCollageControllerDelegateTemplateSize];
            NSUInteger lCountOfTamplates = [self.delegate GSCollageControllerDelegateCountOfTamplates];
            NSUInteger lCountOfFreeTamplates = [self.delegate GSCollageControllerDelegateCountOfFreeTamplates];
            
            CGFloat lLastX = 10;
            for(NSUInteger index = 1; index < lCountOfTamplates+1; index++) {
                UIButton * lCollageButton = [[UIButton alloc] initWithFrame:CGRectMake(lLastX, (self.frame.size.height - lTamplateSize.height- 2.f) / 2.0, lTamplateSize.width, lTamplateSize.height)];
                [lCollageButton addTarget:self action:@selector(selectedSquarebackground:) forControlEvents:UIControlEventTouchUpInside];
                lCollageButton.tag = index;
                
                [lCollageButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForTemplate:index] forState:UIControlStateNormal];
                [lCollageButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:index] forState:UIControlStateHighlighted];
                
                [mScrolView addSubview:lCollageButton];
                
                if (index > lCountOfFreeTamplates) {
                    [lCollageButton setImage:[UIImage imageNamed:@"templates_lock_image.png"] forState:UIControlStateNormal];
                }
                
                if (index == 0) {
                    mSelectedFilterButton = lCollageButton;
                    [mSelectedFilterButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:index] forState:UIControlStateNormal];
                }
                
                lLastX += lTamplateSize.width + 10.0;
            }
            
            [mScrolView setContentSize:CGSizeMake(lLastX, mScrolView.frame.size.height-10.f)];
            [mLeftShadowImageView setAlpha:0.0f];
            [mRightShadowImageView setAlpha:1.0];
        }
    } else {
        NSLog(@"not found delegate");
    }

}

- (void) setBlackBackground:(BOOL)pHas {
    mHasBackground = pHas;
    if (pHas) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
}

- (void) selectedCollage:(UIButton *)pSender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(GSCollageControllerDelegateSelectedCollage:)]) {
            BOOL lIsFree = [self.delegate GSCollageControllerDelegateSelectedCollage:pSender.tag];
            if (lIsFree) {
                if (mHasBackground) {
                    if (mSelectedFilterButton != nil) {
                        [mSelectedFilterButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForTemplate:mSelectedFilterButton.tag] forState:UIControlStateNormal];
                        
                    }
                    
                    [pSender setImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:pSender.tag] forState:UIControlStateNormal];
                } else {
                    if (mSelectedFilterButton != nil) {
                        [mSelectedFilterButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForTemplate:mSelectedFilterButton.tag] forState:UIControlStateNormal];
                    }
                    
                    [pSender setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:pSender.tag] forState:UIControlStateNormal];

                }
                
                mSelectedFilterButton = pSender;
                
                CGFloat lNewX = pSender.center.x - mScrolView.frame.size.width / 2;
                if (lNewX < 0) {
                    lNewX = 0;
                } else if (lNewX > (mScrolView.contentSize.width - mScrolView.frame.size.width)) {
                    lNewX = mScrolView.contentSize.width - mScrolView.frame.size.width;
                }
                [mScrolView setContentOffset:CGPointMake(lNewX, 0.0f) animated:YES];
            }
        }
    }
}
- (void) selectedSquarebackground:(UIButton *)pSender {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(GSCollageControllerDelegateSelectedSquareBackground:)]) {
            [self.delegate GSCollageControllerDelegateSelectedSquareBackground:pSender.tag];
            if (YES) {
                if (mHasBackground) {
                    if (mSelectedFilterButton != nil) {
                        [mSelectedFilterButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForTemplate:mSelectedFilterButton.tag] forState:UIControlStateNormal];
                    }
                    
                    [pSender setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:pSender.tag] forState:UIControlStateNormal];
                } else {
                    if (mSelectedFilterButton != nil) {
                        [mSelectedFilterButton setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForTemplate:mSelectedFilterButton.tag] forState:UIControlStateNormal];
                    }
                    
                    [pSender setBackgroundImage:[self.delegate GSCollageControllerDelegateImageForActiveTemplate:pSender.tag] forState:UIControlStateNormal];
                    
                }
                
                mSelectedFilterButton = pSender;
                
                CGFloat lNewX = pSender.center.x - mScrolView.frame.size.width / 2;
                if (lNewX < 0) {
                    lNewX = 0;
                } else if (lNewX > (mScrolView.contentSize.width - mScrolView.frame.size.width)) {
                    lNewX = mScrolView.contentSize.width - mScrolView.frame.size.width;
                }
                [mScrolView setContentOffset:CGPointMake(lNewX, 0.0f) animated:YES];
            }
        }
    }
}


@end
