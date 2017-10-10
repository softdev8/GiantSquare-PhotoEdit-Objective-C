//
//  GSCollageElement.m
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//


#import <CoreImage/CoreImage.h>

#import "GSCollageElement.h"

@interface GSCollageElement()
- (UIImage *) image;
- (UIImage *) maskImage;
@end

@implementation GSCollageElement

@synthesize arrayOfPoints=mArrayOfPoints;

- (id)initWithPoints:(NSArray*)pArrayOfPoints {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:212.0/255.0 green:223/255.0 blue:231/255.0 alpha:1.0f]];
        
        mFrameWidth = 1.0;
        
        mArrayOfPoints = [[NSMutableArray alloc] initWithArray:pArrayOfPoints];
        
        if (mArrayOfPoints.count > 0) {
            CGPoint lMinPoint = CGPointFromString([mArrayOfPoints objectAtIndex:0]);
            CGPoint lMaxPoint = lMinPoint;
            CGFloat lXSum = 0.0;
            CGFloat lYSum = 0.0;
            
            for (NSUInteger index = 0; index < mArrayOfPoints.count; index++) {
                CGPoint lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:index]);
                lXSum += lPoint.x;
                lYSum += lPoint.y;
                
                //min
                if (lMinPoint.x > lPoint.x) {
                    lMinPoint.x = lPoint.x;
                }
                if (lMinPoint.y > lPoint.y) {
                    lMinPoint.y = lPoint.y;
                }
                //max
                if (lMaxPoint.x < lPoint.x) {
                    lMaxPoint.x = lPoint.x;
                }
                if (lMaxPoint.y < lPoint.y) {
                    lMaxPoint.y = lPoint.y;
                }
            }
            
            [self setFrame:CGRectMake(lMinPoint.x, lMinPoint.y, lMaxPoint.x - lMinPoint.x, lMaxPoint.y - lMinPoint.y)];
            
            mLeftOffset = lMinPoint.x;
            mTopOffset = lMinPoint.y;
            mCenter = CGPointMake(lXSum / mArrayOfPoints.count, lYSum / mArrayOfPoints.count);
            
            CAShapeLayer *lMaskLayer = [[CAShapeLayer alloc] init];
            CGMutablePathRef lPath = CGPathCreateMutable();
            
            CGPoint lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:0]);
            CGPathMoveToPoint(lPath, nil, lPoint.x - mLeftOffset, lPoint.y - mTopOffset);
            
            for (NSInteger i = 1; i < mArrayOfPoints.count; i++) {
                lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:i]);
                CGPathAddLineToPoint(lPath, nil, lPoint.x - mLeftOffset, lPoint.y - mTopOffset);
            }
            
            [lMaskLayer setPath:lPath];
            self.layer.mask = lMaskLayer;
            
            CGPathRelease(lPath);
        } else {
            mLeftOffset = 0.0;
            mTopOffset = 0.0;
        }
    }
    return self;
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

- (void) setImage:(UIImage*)pImage {
    if (pImage == nil) {
        if (mImageView != nil) {
            [mImageView removeFromSuperview];
            mImageView = nil;
        }
    } else {
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
}

- (void) setTransition:(CGPoint)pPoint
{
    
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
    NSInteger i;
    NSInteger j;
    NSInteger lResult = 0;
    CGPoint lPointI;
    CGPoint lPointJ;
    
    for (i = 0, j = mArrayOfPoints.count-1; i < mArrayOfPoints.count; j = i++) {
        lPointI = CGPointFromString([mArrayOfPoints objectAtIndex:i]);
        lPointJ = CGPointFromString([mArrayOfPoints objectAtIndex:j]);
        
        if (( (lPointI.y > pPoint.y) != (lPointJ.y > pPoint.y) ) &&
            ( pPoint.x < ( lPointJ.x - lPointI.x ) * ( pPoint.y - lPointI.y ) / ( lPointJ.y - lPointI.y ) + lPointI.x) ) {
            lResult = !lResult;
        }
    }
    
    return (lResult ? YES : NO);
}

- (void) setFrameWidth:(CGFloat)pFrame {
    mFrameWidth = pFrame;
    return;
    
    CGFloat lFrameDiff = pFrame - mFrameWidth;

    mFrameWidth = pFrame;
    CGPoint lPoint = CGPointZero;
    CGFloat lXSum = 0.0;
    CGFloat lYSum = 0.0;
    CGFloat lX = 0.0;
    CGFloat lY = 0.0;
    
    CAShapeLayer *lMaskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef lPath = CGPathCreateMutable();
    
    for (NSInteger index = 0; index < mArrayOfPoints.count; index++) {
        lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:index]);
        
        if (lPoint.x < mCenter.x) {
            lX = lPoint.x + lFrameDiff;
        }
        
        if (lPoint.x > mCenter.x) {
            lX = lPoint.x - lFrameDiff;
        }
        
        if (lPoint.y < mCenter.y) {
            lY = lPoint.y + lFrameDiff;
        } 
        
        if (lPoint.y > mCenter.y) {
            lY = lPoint.y - lFrameDiff;
        }
        
        lPoint = CGPointMake(lX, lY);
        
        lXSum += lPoint.x;
        lYSum += lPoint.y;
        
        if (index == 0) {
            CGPathMoveToPoint(lPath, nil, lPoint.x - mLeftOffset, lPoint.y - mTopOffset);
        } else {
            CGPathAddLineToPoint(lPath, nil, lPoint.x - mLeftOffset, lPoint.y - mTopOffset);
        }
        
        [mArrayOfPoints replaceObjectAtIndex:index withObject:NSStringFromCGPoint(lPoint)];
    }
    
    [lMaskLayer setPath:lPath];
    self.layer.mask = lMaskLayer;
    
    CGPoint lCenter = CGPointMake(lXSum / mArrayOfPoints.count, lYSum / mArrayOfPoints.count);
    NSLog(@"lCenter %@", NSStringFromCGPoint(lCenter));
    NSLog(@"mCenter %@", NSStringFromCGPoint(mCenter));
    
    [self setNeedsDisplay];
}

- (BOOL) isEmpty {
    if (mImageView) {
        return NO;
    } else {
        return YES;
    }
}

- (UIImage *) image {
    UIImage *lResult = nil;
    
    CGFloat lScale = mImageSize.width / mImageView.frame.size.width;
    CGSize lImageSize = CGSizeMake(self.frame.size.width * lScale, self.frame.size.height * lScale);
    
    UIGraphicsBeginImageContextWithOptions(lImageSize, NO, 1.0);
    [mImageView.image drawInRect:CGRectMake(mImageView.frame.origin.x * lScale, mImageView.frame.origin.y * lScale, mImageSize.width, mImageSize.height)];
    
    lResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return lResult;
}

- (UIImage *) maskImage {
    UIImage *lResult = nil;

    CGSize lImageSize = CGSizeMake(self.frame.size.width * XSIZE, self.frame.size.height * XSIZE);


    CGMutablePathRef lPath = CGPathCreateMutable();
    CGPoint lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:0]);
    CGPathMoveToPoint(lPath, nil, (lPoint.x - mLeftOffset) * XSIZE, (lPoint.y - mTopOffset) * XSIZE);
    
    for (NSInteger i = 1; i < mArrayOfPoints.count; i++) {
        lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:i]);
        CGPathAddLineToPoint(lPath, nil, (lPoint.x - mLeftOffset) * XSIZE, (lPoint.y - mTopOffset) * XSIZE);
    }
    
    UIGraphicsBeginImageContext(lImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, lPath);
    CGContextClip(context);
//    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brushSizeVal);
    
    [[self image] drawInRect:CGRectMake(0, 0, lImageSize.width, lImageSize.height)];
    lResult = UIGraphicsGetImageFromCurrentImageContext();    //drawImage is the UIImageView that I am drawing to
    UIGraphicsEndImageContext();
    CGPathRelease(lPath);
    
    [self saveImage:lResult toAlbum:@"testGS"];
    return lResult;
}

- (UIImage*) getImage {
//    UIImage *lResult = [self maskImage];
//    UIImageWriteToSavedPhotosAlbum(lResult, nil, nil, NULL);
//    return lResult;
    
//    CGSize lImageSize = CGSizeMake(self.frame.size.width * XSIZE, self.frame.size.height * XSIZE);
//    UIGraphicsBeginImageContextWithOptions(lImageSize, NO, 1.0);
//
//    [[self image] drawAtPoint:CGPointZero];
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
//    [[self maskImage] drawAtPoint:CGPointZero];
//    
//    lResult = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return lResult;
    CGImageRef lMaskRef = [self maskImage].CGImage;
    CGImageRef lMask = CGImageMaskCreate(CGImageGetWidth(lMaskRef),
                                        CGImageGetHeight(lMaskRef),
                                        CGImageGetBitsPerComponent(lMaskRef),
                                        CGImageGetBitsPerPixel(lMaskRef),
                                        CGImageGetBytesPerRow(lMaskRef),
                                        CGImageGetDataProvider(lMaskRef), NULL, false);
    
    CGImageRef lMaskedImageRef = CGImageCreateWithMask([self image].CGImage, lMask);
    UIImage *lResult = [UIImage imageWithCGImage:lMaskedImageRef];
    
    CGImageRelease(lMask);
    CGImageRelease(lMaskedImageRef);
    
    // returns new image with mask applied
    return lResult;
}

- (void)saveImage:(UIImage*)pImage toAlbum:(NSString*)pName {
    ALAssetsLibrary *lLibrary = [[ALAssetsLibrary alloc] init];
    [lLibrary writeImageToSavedPhotosAlbum:pImage.CGImage orientation:pImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error == nil) {
        [lLibrary addAssetURL:assetURL toAlbum:pName withCompletionBlock:^(NSError *error) {
            
        }];
        } else {
            
        }
    }];
}

//-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//    UIBezierPath *lPath = [UIBezierPath bezierPath];
//    
//    CGPoint lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:0]);
//    [lPath moveToPoint:CGPointMake(lPoint.x - mLeftOffset, lPoint.y - mTopOffset)];
//    
//    for (NSInteger i = 1; i < mArrayOfPoints.count; i++) {
//        lPoint = CGPointFromString([mArrayOfPoints objectAtIndex:i]);
//        [lPath addLineToPoint:CGPointMake(lPoint.x - mLeftOffset, lPoint.y - mTopOffset)];
//    }
//    [lPath closePath];
//    [[UIColor blackColor] set];
//    [lPath setLineWidth:2.0];
//    [lPath stroke];
//}


@end
