//
//  GSInstagramElement.m
//  GiantSquare
//
//  Created by roman.andruseiko on 3/14/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GSInstagramElement.h"

@interface GSInstagramElement()
- (void) removeLabelAtIndex:(NSUInteger)pIndex;
- (void) addLabelAtIndex:(NSUInteger)pIndex;
@end

@implementation GSInstagramElement

@synthesize arrayOfRects=mArrayOfRects;

- (id)initWithFrame:(CGRect)frame andRects:(NSArray *)pRects{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        mArrayOfRects = [[NSMutableArray alloc] initWithArray:pRects];
        
        mImageSize = CGSizeMake(1.0, 1.0);
        
        mScale = 1.0;
        mMinScale = 1.0;
        mMaxScale = 1.0;
        
        mFirstChange = YES;
        mIsLabelState = NO;
        mIsHighlighted = NO;
    }
    return self;
}

- (void) removeLabelAtIndex:(NSUInteger)pIndex {
    if (pIndex < mArrayOfLabels.count) {
        [(UILabel*)[mArrayOfLabels objectAtIndex:pIndex] removeFromSuperview];
        [mArrayOfLabels removeObjectAtIndex:pIndex];
    }
}

- (void) addLabelAtIndex:(NSUInteger)pIndex {
    CGRect lRect = [[mArrayOfRects objectAtIndex:pIndex] CGRectValue];
    lRect = CGRectOffset(lRect, -START_POINT_X, -START_POINT_Y);
    
    UILabel *lLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lRect) - 29.0, CGRectGetMaxY(lRect) - 15, 24.0, 10.0)];
    [lLabel setTextAlignment:UITextAlignmentCenter];
    [lLabel setFont:[UIFont systemFontOfSize:8.0]];
    [lLabel setBackgroundColor:[UIColor colorWithRed:0.215 green:0.407 blue:0.5960 alpha:1.0]];
    [lLabel setTextColor:[UIColor whiteColor]];
    [lLabel setText:[NSString stringWithFormat:@"%i of %i", mArrayOfRects.count - pIndex, mArrayOfRects.count]];
    [self insertSubview:lLabel aboveSubview:mImageView];
    [mArrayOfLabels insertObject:lLabel atIndex:pIndex];
}

- (void) updateLabelsTitle {
    for (NSUInteger index = 0; index < mArrayOfLabels.count; index++) {
        UILabel *lLabel = [mArrayOfLabels objectAtIndex:index];
        CGRect lRect = [[mArrayOfRects objectAtIndex:index] CGRectValue];
        lRect = CGRectOffset(lRect, -START_POINT_X, -START_POINT_Y);
        
        [lLabel setFrame:CGRectMake(CGRectGetMaxX(lRect) - 29.0, CGRectGetMaxY(lRect) - 15, 24.0, 10.0)];
        [lLabel setText:[NSString stringWithFormat:@"%i of %i", mArrayOfRects.count-index, mArrayOfRects.count]];
    }
}

- (void) setHighlighted:(BOOL)pHighLighted {
    mIsHighlighted = pHighLighted;
    [self setNeedsDisplay];
}

- (void) setImage:(UIImage*)pImage {
    if (mImageView == nil) {
        mImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [mImageView setBackgroundColor:[UIColor clearColor]];
        [self insertSubview:mImageView atIndex:0];
    }
    mImageSize = pImage.size;
    [mImageView setImage:pImage];
    
    mScale = 1.0;
    
    CGFloat lKoeficientScaleImage = pImage.size.width/pImage.size.height;
    CGFloat lKoeficientScaleFrame = self.frame.size.width/self.frame.size.height;
    
    if (lKoeficientScaleImage > lKoeficientScaleFrame){
        mScale = self.frame.size.height/pImage.size.height;
    } else if (lKoeficientScaleImage <= lKoeficientScaleFrame){
        mScale = self.frame.size.width/pImage.size.width;
    }
    
    mMinScale = mScale;
    
    if (mMinScale >= 1.0) {
        mMaxScale = mMinScale*3.0;
    } else {
        mMaxScale = 1.0;
    }
    
    mImageView.frame = CGRectMake(0, 0, pImage.size.width*mScale, pImage.size.height*mScale);

}

- (void) setTransition:(CGPoint)pPoint {
    
    CGFloat lXScale = 1.0;
    CGFloat lNewX = mImageView.frame.origin.x + pPoint.x;
    if (lNewX > 0) {
        lXScale = (self.frame.size.width - lNewX*2.0) / self.frame.size.width;
    } else {
        CGFloat lMinX = lNewX + mImageView.frame.size.width;
        if (lMinX < self.frame.size.width) {
            lXScale = ABS(self.frame.size.width - ABS(self.frame.size.width - lMinX)*2.0) / self.frame.size.width;
        }
    }
    
    CGFloat lYScale = 1.0;
    CGFloat lNewY = mImageView.frame.origin.y + pPoint.y;
    if (lNewY > 0) {
        lYScale = (self.frame.size.width - lNewY*2.0) / self.frame.size.width;
    } else {
        CGFloat lMinY = lNewY + mImageView.frame.size.height;
        if (lMinY < self.frame.size.height) {
            lYScale = ABS(self.frame.size.height - ABS(self.frame.size.height - lMinY)*2.0) / self.frame.size.height;
        }
    }
    
    CGPoint lNewCenter = CGPointMake(mImageView.center.x + pPoint.x*lXScale, mImageView.center.y + pPoint.y*lYScale);
    [mImageView setCenter:lNewCenter];
}

- (void) setPinchScale:(CGFloat)pPinchScale atPoint:(CGPoint)pAnchorPoint {
    
    if (mFirstChange) {
        mLastAnchorPoint = pAnchorPoint;
        mFirstChange = NO;
    }
    
    CGFloat lNewScale = mScale * pPinchScale;
    
    CGSize lNewImageSize = CGSizeMake(mImageSize.width * lNewScale, mImageSize.height * lNewScale);
    CGPoint lImageSizeDiff = CGPointMake(pAnchorPoint.x - mImageView.frame.origin.x, pAnchorPoint.y - mImageView.frame.origin.y);
    CGPoint lAnchorOffset = CGPointMake(pAnchorPoint.x - mLastAnchorPoint.x, pAnchorPoint.y - mLastAnchorPoint.y);
    
    CGFloat lXKoeficient = (mImageView.frame.size.width - lNewImageSize.width) / mImageView.frame.size.width;
    CGFloat lYKoeficient = (mImageView.frame.size.height - lNewImageSize.height) / mImageView.frame.size.height;
    
    [mImageView setFrame:CGRectMake(mImageView.frame.origin.x + lImageSizeDiff.x * lXKoeficient + lAnchorOffset.x, mImageView.frame.origin.y + lImageSizeDiff.y * lYKoeficient + lAnchorOffset.y, lNewImageSize.width, lNewImageSize.height)];
    
    mLastAnchorPoint = pAnchorPoint;
}

- (void) updatePositionsWithVelocity:(CGPoint)pVelocity {
    mFirstChange = YES;
    
    mScale = mImageView.frame.size.width/mImageSize.width;
    
    //calc scale
    if (mScale < mMinScale) {
        mScale = mMinScale;
    } else if (mScale > mMaxScale) {
        mScale = mMaxScale;
    }
    
    CGSize lNewImageSize = CGSizeMake(mImageSize.width * mScale, mImageSize.height * mScale);
    CGPoint lImageSizeDiff = CGPointMake(mLastAnchorPoint.x - mImageView.frame.origin.x, mLastAnchorPoint.y - mImageView.frame.origin.y);
    
    CGFloat lXKoeficient = (mImageView.frame.size.width - lNewImageSize.width) / mImageView.frame.size.width;
    CGFloat lYKoeficient = (mImageView.frame.size.height - lNewImageSize.height) / mImageView.frame.size.height;
    
    CGRect lImageFrame = CGRectMake(mImageView.frame.origin.x + lImageSizeDiff.x * lXKoeficient + pVelocity.x / 8.0, mImageView.frame.origin.y + lImageSizeDiff.y * lYKoeficient + pVelocity.y / 8.0, lNewImageSize.width, lNewImageSize.height);
    
    //calc position
    CGFloat lNewX = lImageFrame.origin.x;
    CGFloat lNewY = lImageFrame.origin.y;
    
    if (lImageFrame.origin.x > 0) {
        lNewX = 0.0;
    } else {
        CGFloat lMinX = self.frame.size.width - lImageFrame.size.width;
        if (lImageFrame.origin.x < lMinX) {
            lNewX = lMinX;
        }
    }
    
    if (lImageFrame.origin.y > 0) {
        lNewY = 0.0;
    } else {
        CGFloat lMinY = self.frame.size.height - lImageFrame.size.height;
        if (lImageFrame.origin.y < lMinY) {
            lNewY = lMinY;
        }
    }
    
    lImageFrame = CGRectMake(lNewX, lNewY, lImageFrame.size.width, lImageFrame.size.height);
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        [mImageView setFrame:lImageFrame];
    } completion:nil];
}

- (BOOL) isElementContainPoint:(CGPoint)pPoint {
    BOOL lResult = NO;
    CGPoint lPoint = CGPointMake(pPoint.x - self.frame.origin.x, pPoint.y - self.frame.origin.y + 44.0);
    
    for (NSInteger i = 0; i < mArrayOfRects.count; i++) {
        CGRect lSquareRect = [[mArrayOfRects objectAtIndex:i] CGRectValue];
        lSquareRect = CGRectMake(lSquareRect.origin.x - 12.0, lSquareRect.origin.y - 56.0, lSquareRect.size.width + 4.0, lSquareRect.size.height + 4.0);
        if (CGRectContainsPoint(lSquareRect, lPoint)) {
            lResult = YES;
            break;
        }
    }
    return lResult;
}

- (BOOL) removeRectWithPoint:(CGPoint)pPoint {
    BOOL lResult = NO;
    
    CGPoint lPoint = CGPointMake(pPoint.x - self.frame.origin.x, pPoint.y - self.frame.origin.y);

    for (NSInteger i = 0; i < mArrayOfRects.count; i++) {
        CGRect lSquareRect = [[mArrayOfRects objectAtIndex:i] CGRectValue];
        lSquareRect = CGRectOffset(lSquareRect, -START_POINT_X, -START_POINT_Y);

        if (CGRectContainsPoint(lSquareRect, lPoint)) {
            [self removeLabelAtIndex:i];
            [mArrayOfRects removeObjectAtIndex:i];
            lResult = YES;
            break;
        }
    }
    
    return lResult;
}

- (void) addRect:(CGRect)pRect {
    NSUInteger lIndex = 0;
    for (NSUInteger index = 0; index < mArrayOfRects.count; index++) {
        NSValue *lRectValueB = [mArrayOfRects objectAtIndex:index];
        CGRect lRectB = [lRectValueB CGRectValue];
        if (lRectB.origin.y == pRect.origin.y) {
            if (lRectB.origin.x > pRect.origin.x) {
                break;
            }
        } else if (lRectB.origin.y > pRect.origin.y) {
            break;
        }
        
        lIndex++;
    }
    if (lIndex < mArrayOfRects.count) {
       [mArrayOfRects insertObject:[NSValue valueWithCGRect:pRect] atIndex:lIndex]; 
    } else {
        [mArrayOfRects addObject:[NSValue valueWithCGRect:pRect]];
    }
    
    if (mIsLabelState) {
        [self addLabelAtIndex:lIndex];
    }
}

- (UIImage*) imageAtPoint:(CGPoint)pPoint withWatermark:(NSInteger) pWatermark {
    UIImage *lResult = nil;
    CGFloat lScale = mImageSize.width / mImageView.frame.size.width;
    NSLog(@"Watermark: %i", pWatermark);
    CGSize lImageSize = CGSizeMake(SQUARE_SIZE * lScale - 3, SQUARE_SIZE * lScale - 3);
    CGPoint lPoint = CGPointMake(pPoint.x - self.frame.origin.x, pPoint.y - self.frame.origin.y);
    
    NSUInteger lIndex = mArrayOfRects.count;
    for (NSValue *lRectValue in mArrayOfRects) {
        CGRect lImageRect = [lRectValue CGRectValue];
        lImageRect = CGRectOffset(lImageRect, -START_POINT_X, -START_POINT_Y);
        
        if (CGRectContainsPoint(lImageRect, lPoint)) {
            UIGraphicsBeginImageContextWithOptions(lImageSize, NO, 1.0);
			CGRect lImageFrame = CGRectMake((mImageView.frame.origin.x - lImageRect.origin.x) * lScale, (mImageView.frame.origin.y - lImageRect.origin.y) * lScale, mImageSize.width, mImageSize.height);
            [mImageView.image drawInRect:lImageFrame];
            

            
            UIImage *lImage = UIGraphicsGetImageFromCurrentImageContext();
            if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
                if (pWatermark != 0) {
                    //draw watermark
                    UIImage *lWatermarkImage;
                    if (pWatermark == 1) {
                        lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_1.png"];
                    } else {
                        lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_2.png"];
                    }
                    [lWatermarkImage drawInRect:CGRectMake(0 , lImageSize.height - 236, 612, 236)];
                }
            }


            UIGraphicsEndImageContext();
            
            if (mIsLabelState) {
                lImageSize = CGSizeMake(612.0, 612.0);
                
                UIGraphicsBeginImageContextWithOptions(lImageSize, NO, 1.0);
                [lImage drawInRect:CGRectMake(0.0, 0.0, lImageSize.width, lImageSize.height)];
                
                CGFloat lFontScale = lImageSize.width / 600.0;
                CGSize lLabelSize = CGSizeMake(lImageSize.width * 0.11, lImageSize.height * 0.052);
                CGRect lFrame = CGRectMake(lImageSize.width - lLabelSize.width - 10.0, lImageSize.height - lLabelSize.height - 10.0, lLabelSize.width, lLabelSize.height);
                
                            
                NSString *lTitle = [NSString stringWithFormat:@"%i of %i", lIndex, mArrayOfRects.count];
                [[UIColor colorWithRed:0.215 green:0.407 blue:0.5960 alpha:1.0] setFill];
                UIRectFill(lFrame);
                [[UIColor whiteColor] set];
                if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
                    if (pWatermark != 0) {
                        //draw watermark
                        UIImage *lWatermarkImage;
                        if (pWatermark == 1) {
                            lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_1.png"];
                        } else {
                            lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_2.png"];
                        }
                        NSLog(@"Size: %f", lImageSize.width);
                        [lWatermarkImage drawInRect:CGRectMake(0 , lImageSize.height - 236, 612, 236)];
                    }
                }

                [lTitle drawInRect:lFrame withFont:[UIFont systemFontOfSize:22.0*lFontScale] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
				lResult = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                            
            } else {
                if (lImage.size.width < 612.0f) {
                    lImageSize = CGSizeMake(612.0, 612.0);
                    
                    UIGraphicsBeginImageContextWithOptions(lImageSize, NO, 1.0);
                    [lImage drawInRect:CGRectMake(0.0, 0.0, lImageSize.width, lImageSize.height)];
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
                        if (pWatermark != 0) {
                            //draw watermark
                            UIImage *lWatermarkImage;
                            if (pWatermark == 1) {
                                lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_1.png"];
                            } else {
                                lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_2.png"];
                            }
                            NSLog(@"Size: %f", lImageSize.width);
                            [lWatermarkImage drawInRect:CGRectMake(0 , lImageSize.height - 236, 612, 236)];
                        }
                    }

                    lResult = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                } else {
                    lImageSize = CGSizeMake(612.0, 612.0);
                    UIGraphicsBeginImageContextWithOptions(lImageSize, NO, 1.0);
                    [lImage drawInRect:CGRectMake(0.0, 0.0, lImageSize.width, lImageSize.height)];
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
                        if (pWatermark != 0) {
                            //draw watermark
                            UIImage *lWatermarkImage;
                            if (pWatermark == 1) {
                                lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_1.png"];
                            } else {
                                lWatermarkImage = [UIImage imageNamed:@"giant_square_watermark_2.png"];
                            }
                            NSLog(@"Size: %f", lImageSize.width);
                            [lWatermarkImage drawInRect:CGRectMake(0 , lImageSize.height - 236, 612, 236)];
                        }
                    }
                    
                    lResult = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
            }
            
            break;
        }
        
        lIndex--;
    }
    
    return lResult;
}

- (void) setLabelState:(BOOL)pIsLabelState {
    mIsLabelState = pIsLabelState;
    
    if (mIsLabelState) {
        
        mArrayOfLabels = [[NSMutableArray alloc] init];
        
        NSUInteger lIndex = mArrayOfRects.count;
        for (NSValue *lRectValue in mArrayOfRects) {
            CGRect lRect = [lRectValue CGRectValue];
            lRect = CGRectOffset(lRect, -START_POINT_X, -START_POINT_Y);
            
            UILabel *lLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lRect) - 29.0, CGRectGetMaxY(lRect) - 15, 24.0, 10.0)];
            [lLabel setTextAlignment:UITextAlignmentCenter];
            [lLabel setFont:[UIFont systemFontOfSize:8.0]];
            [lLabel setBackgroundColor:[UIColor colorWithRed:0.215 green:0.407 blue:0.5960 alpha:1.0]];
            [lLabel setTextColor:[UIColor whiteColor]];
            [lLabel setText:[NSString stringWithFormat:@"%i of %i", lIndex, mArrayOfRects.count]];
            [self insertSubview:lLabel aboveSubview:mImageView];
            [mArrayOfLabels addObject:lLabel];
            
            lIndex--;
        }
    } else {
        [mArrayOfLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [mArrayOfLabels removeAllObjects];
        mArrayOfLabels = nil;
    }
}

- (void)setFrame:(CGRect)frame {
    if (mImageView != nil) {
        CGPoint lOffset = CGPointMake(frame.origin.x - self.frame.origin.x, frame.origin.y - self.frame.origin.y);
        
        [mImageView setCenter:CGPointMake(mImageView.center.x - lOffset.x, mImageView.center.y - lOffset.y)];
        
        CGFloat lKoeficientScaleImage = mImageSize.width/mImageSize.height;
        CGFloat lKoeficientScaleFrame = frame.size.width/frame.size.height;
        
        if (lKoeficientScaleImage > lKoeficientScaleFrame){
            mMinScale = frame.size.height/mImageSize.height;
        } else if (lKoeficientScaleImage <= lKoeficientScaleFrame){
            mMinScale = frame.size.width/mImageSize.width;
        }
        
        if (mMinScale >= 1.0) {
            mMaxScale = mMinScale*3.0;
        } else {
            mMaxScale = 1.0;
        }
    
        
    }
    
    [super setFrame:frame];
    [self updatePositionsWithVelocity:CGPointMake(0.0, 0.0)];
}

- (void)drawRect:(CGRect)rect {
    CAShapeLayer *lMaskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef lPath = CGPathCreateMutable();
    for (NSInteger i = 0; i < mArrayOfRects.count; i++) {
        CGRect lSquareRect = [[mArrayOfRects objectAtIndex:i] CGRectValue];
        lSquareRect = CGRectOffset(lSquareRect, -START_POINT_X, -START_POINT_Y);
        CGPathAddRect(lPath, nil, lSquareRect);
    }
    
    [lMaskLayer setPath:lPath];
    CGPathRelease(lPath);
    
    self.layer.mask = lMaskLayer;
}

@end
