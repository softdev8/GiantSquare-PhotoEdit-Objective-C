//
//  GSInstagramElement.h
//  GiantSquare
//
//  Created by roman.andruseiko on 3/14/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSInstagramElement : UIView {
    UIImageView *mImageView;
    
    NSMutableArray *mArrayOfRects;
    NSMutableArray *mArrayOfLabels;
    
    CGSize mImageSize;
    CGPoint mLastAnchorPoint;
    
    CGFloat mScale;
    CGFloat mMinScale;
    CGFloat mMaxScale;
    
    BOOL mFirstChange;
    BOOL mIsLabelState;
    BOOL mIsHighlighted;
}

@property (nonatomic, readonly) NSMutableArray *arrayOfRects;

- (id)initWithFrame:(CGRect)frame andRects:(NSArray *)pRects;
- (void) setImage:(UIImage*)pImage;

- (void) setTransition:(CGPoint)pPoint;
- (void) setPinchScale:(CGFloat)pPinchScale atPoint:(CGPoint)pAnchorPoint;
- (void) updatePositionsWithVelocity:(CGPoint)pVelocity;

- (BOOL) isElementContainPoint:(CGPoint)pPoint;
- (BOOL) removeRectWithPoint:(CGPoint)pPoint;
- (void) addRect:(CGRect)pRect;
- (UIImage*) imageAtPoint:(CGPoint)pPoint withWatermark:(NSInteger)pWatermark;
- (void) setLabelState:(BOOL)pIsLabelState;
- (void) updateLabelsTitle;
- (void) setHighlighted:(BOOL)pHighLighted;
@end
