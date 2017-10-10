//
//  GSCollageElement.h
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define XSIZE 4.0

@interface GSCollageElement : UIView {
    NSMutableArray *mArrayOfPoints;
    
    UIImageView *mImageView;
    
    CGSize mImageSize;
    CGPoint mLastAnchorPoint;
    CGPoint mCenter;
    
    CGFloat mScale;
    CGFloat mMinScale;
    CGFloat mMaxScale;
    
    CGFloat mLeftOffset;
    CGFloat mTopOffset;
    CGFloat mFrameWidth;
    
    BOOL mFirstChange;
    BOOL mIsLabelState;
    BOOL mIsHighlighted;
}

@property (nonatomic, readonly) NSArray *arrayOfPoints;

- (id)initWithPoints:(NSArray*)pArrayOfPoints;
- (void) setImage:(UIImage*)pImage;

- (void) setTransition:(CGPoint)pPoint;
- (void) setPinchScale:(CGFloat)pPinchScale atPoint:(CGPoint)pAnchorPoint;
- (void) updatePositionsWithVelocity:(CGPoint)pVelocity;
- (BOOL) isElementContainPoint:(CGPoint)pPoint;
- (void) setFrameWidth:(CGFloat)pFrame;
- (BOOL) isEmpty;
//old methods
- (UIImage*) getImage;
- (UIImage *) image;
@end
