//
//  GSCollageView.m
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GSCollageView.h"

#define TWITTER_WATERMARK_WIDTH 185
#define TWITTER_WATERMARK_HEIGHT 30
#define TWITTER_WATERMARK_MARGIN 5
@interface GSCollageView()

//gesture methods
- (void) tapGestureRecognizer:(UITapGestureRecognizer*)pTapGesureRecognizer;
- (void) panGestureRecognizer:(UIPanGestureRecognizer*)pPanGesureRecognizer;
- (void) pinchGestureRecognizer:(UIPinchGestureRecognizer*)pPinchGesureRecognizer;
- (void) longPressGestureRecognizer:(UILongPressGestureRecognizer*)pLongPressGestureRecognizer;
@end

@implementation GSCollageView

@synthesize delegate=mDelegate;

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.layer setBorderColor:[UIColor colorWithWhite:0.78 alpha:1.0].CGColor];
    [self.layer setBorderWidth:1.0];
    
    mSelectedElement = nil;
    mPicturesDictionary = [NSMutableDictionary new];
    mFrameWidth = 1.0;
    
    mElementsView = [[UIView alloc] initWithFrame:self.bounds];
    [mElementsView setBackgroundColor:[UIColor yellowColor]];
    [self addSubview:mElementsView];
    
    mGesturesView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:mGesturesView];
    
    //add gestures
    UITapGestureRecognizer *lTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [lTapRecognizer setNumberOfTapsRequired:1];
    [mGesturesView addGestureRecognizer:lTapRecognizer];
    
    UIPanGestureRecognizer *lPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
	[lPanRecognizer setMinimumNumberOfTouches:1];
	[lPanRecognizer setMaximumNumberOfTouches:1];
	[mGesturesView addGestureRecognizer:lPanRecognizer];
    
    UIPinchGestureRecognizer *lPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
	[mGesturesView addGestureRecognizer:lPinchRecognizer];
    
    UILongPressGestureRecognizer *lLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    lLongPressRecognizer.minimumPressDuration = 0.5;
    [mGesturesView addGestureRecognizer:lLongPressRecognizer];
    
    mFrameView = [[GSCollageElementFrame alloc] initWithFrame:self.bounds];
    [mFrameView setBackgroundColor:[UIColor clearColor]];
    [mFrameView setDelegate:self];
    [self insertSubview:mFrameView aboveSubview:mElementsView];
}

//new methods
- (void) reloadElements {
    if (mArrayOfElements == nil) {
        mArrayOfElements = [[NSMutableArray alloc] init];
    }
    
    [mArrayOfElements makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [mArrayOfElements removeAllObjects];
    
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(GSCollageViewDelegateCountOfElemets)]) {
            NSUInteger lCountOfElements = [self.delegate GSCollageViewDelegateCountOfElemets];
            NSLog(@"----------------college Element count---------%d-----------",lCountOfElements);
            
            for (NSUInteger index = 0; index < lCountOfElements; index++) {
                NSArray *lPoints = [self.delegate GSCollageViewDelegateArraOfPointForElement:index];
                
                GSCollageElement *lElement = [[GSCollageElement alloc] initWithPoints:lPoints];
                lElement.tag = index;
                [mElementsView addSubview:lElement];
                [mArrayOfElements addObject:lElement];
            }
        }
        
        [self setImagesForCollages];
    } else {
        NSLog(@"not found delegate");
    }
    
    [mFrameView reDraw];
}

- (void)setImageForSelectedElement:(UIImage*)pImage{
    [mSelectedElement setImage:pImage];
    [self saveImage:pImage andName:[NSString stringWithFormat:@"temp_%i", mSelectedElement.tag]];
        DLog(@"count  - %i", [[mPicturesDictionary allKeys] count]);
}

- (void)setImagesForFreePlaces:(NSArray *)pArray{
    NSInteger lStartPoint = 1;
    UIImage *outputImage = [[pArray objectAtIndex:0] objectForKey:UIImagePickerControllerOriginalImage];
//    //set correct image orientation
    UIImage *lImage;
    DLog(@"outputImage.imageOrientation - %i", outputImage.imageOrientation);
    if (outputImage.imageOrientation == UIImageOrientationRight) {
        lImage = [outputImage rotateImageWitSidesReplacingToAngle:360];
    }else if (outputImage.imageOrientation == UIImageOrientationDown){
        lImage = [outputImage rotateImageWitSidesReplacingToAngle:360];
    }else{
        lImage = outputImage;
    }
    
    
    [self setImageForSelectedElement:lImage];
    
    for (NSInteger i = 0; i < [mArrayOfElements count]; i++) {
        if (![mPicturesDictionary objectForKey:[NSString stringWithFormat:@"temp_%i", i]]) {
            if (lStartPoint < [pArray count]) {
                
                outputImage = [[pArray objectAtIndex:lStartPoint] objectForKey:UIImagePickerControllerOriginalImage];

                if (outputImage.imageOrientation == UIImageOrientationRight) {
                    lImage = [outputImage rotateImageWitSidesReplacingToAngle:360];
                }else if (outputImage.imageOrientation == UIImageOrientationDown){
                    lImage = [outputImage rotateImageWitSidesReplacingToAngle:360];
                }else{
                    lImage = outputImage;
                }
                
                [self saveImage:lImage andName:[NSString stringWithFormat:@"temp_%i", i]];
                [self setImageForCollageElement:(GSCollageElement *)[mArrayOfElements objectAtIndex:i]];

                lStartPoint++;
            }
        }
    }
}

- (void) setFrameColor:(UIColor*)pColor {
    mFrameColor = pColor;
    [mFrameView reDraw];
}

- (void)setImagesForCollages{//change image between collages
    // move all images to the start of dictionary
    NSInteger lCounter = 0;
    for (NSInteger i = 0; i < [[mPicturesDictionary allKeys] count]; i++) {
        UIImage *lNewImage = [self readImageFromFile:[NSString stringWithFormat:@"temp_%i", i]];
        if (lNewImage) {
            if (lCounter != i) {
                [self saveImage:lNewImage andName:[NSString stringWithFormat:@"temp_%i", lCounter]];
                [self saveImage:nil andName:[NSString stringWithFormat:@"temp_%i", i]];
            }
            lCounter ++;
        }
    }
    
    for (GSCollageElement *lElement in mArrayOfElements) {
        [self setImageForCollageElement:lElement];
    }

}

- (CGPoint) checkPointPos:(CGPoint)pPoint forWidth:(CGFloat)pWidth frame:(CGRect)pFrame {
    CGPoint lResult = pPoint;
    
    if (pPoint.x == 0) {
        lResult.x = pWidth / 2.0;
    }
    
    if (pPoint.y == 0) {
        lResult.y = pWidth / 2.0;
    }
    
    if (pPoint.x == pFrame.size.width) {
        lResult.x = pFrame.size.width - pWidth / 2.0;
    }
    
    if (pPoint.y == pFrame.size.height) {
        lResult.y = pFrame.size.height - pWidth / 2.0;
    }
    
    return lResult;
}

- (UIImage*) getImageForPublishWithWatermarkType:(GSWatermarkType)pType {
    UIImage *lResult = nil;
    
    CGRect lNewImageRect = CGRectMake(0.0, 0.0, self.frame.size.width * XSIZE, self.frame.size.height * XSIZE);
    CGFloat lFrameWidth = mFrameWidth * XSIZE;
    
    UIGraphicsBeginImageContextWithOptions(lNewImageRect.size, NO, 1.0);
    [mFrameColor setFill];
    UIRectFill(lNewImageRect);
    
    UIBezierPath *lBezierPath = [UIBezierPath bezierPath];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (NSUInteger index = 0; index < mArrayOfElements.count; index++) {
        GSCollageElement *lElement = [mArrayOfElements objectAtIndex:index];
        UIImage *lImage = [lElement image];
        
        CGContextSaveGState(context);
        
        CGMutablePathRef lPath = CGPathCreateMutable();
        
        CGPoint lPoint = CGPointFromString([lElement.arrayOfPoints objectAtIndex:0]);
        lPoint.x = lPoint.x * XSIZE;
        lPoint.y = lPoint.y * XSIZE;
        lPoint = [self checkPointPos:lPoint forWidth:lFrameWidth frame:lNewImageRect];
        CGPathMoveToPoint(lPath, nil, lPoint.x, lPoint.y);
        [lBezierPath moveToPoint:CGPointMake(lPoint.x, lPoint.y)];
        
        for (NSInteger i = 1; i < lElement.arrayOfPoints.count; i++) {
            lPoint = CGPointFromString([lElement.arrayOfPoints objectAtIndex:i]);
            lPoint.x = lPoint.x * XSIZE;
            lPoint.y = lPoint.y * XSIZE;
            lPoint = [self checkPointPos:lPoint forWidth:lFrameWidth  frame:lNewImageRect];
            CGPathAddLineToPoint(lPath, nil, lPoint.x, lPoint.y);
            [lBezierPath addLineToPoint:CGPointMake(lPoint.x, lPoint.y)];
        }
    
        CGContextAddPath(context, lPath);
        CGContextClip(context);
        
        [lImage drawInRect:CGRectMake(lElement.frame.origin.x * XSIZE, lElement.frame.origin.y * XSIZE, lElement.frame.size.width * XSIZE, lElement.frame.size.height * XSIZE)];
        
        CGPathRelease(lPath);
        CGContextRestoreGState(context);
        
        [lBezierPath closePath];
    }
    [mFrameColor set];
    [lBezierPath setLineWidth:lFrameWidth];
    [lBezierPath stroke];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_WATERMARK]) {
        CGRect lWatermarkRect;
        UIImage *lWatermarkImage = nil;
        UIImage *lTemplateImage = [UIImage imageNamed:@"instagram_collage_watermark.png"];
        switch (pType) {
            case GSWatermarkTypeTwitterCollage:
                lWatermarkImage = [UIImage imageNamed:@"cover_collage_watermark.png"];
                lWatermarkRect = CGRectMake(CGRectGetMaxX(lNewImageRect) - lTemplateImage.size.width, CGRectGetMinY(lNewImageRect) , lTemplateImage.size.width, lTemplateImage.size.height);
                break;
            case GSWatermarkTypeFacebookCollage:
                lWatermarkImage = [UIImage imageNamed:@"cover_collage_watermark.png"];
                lWatermarkRect = CGRectMake(CGRectGetMaxX(lNewImageRect) - lTemplateImage.size.width*2, CGRectGetMinY(lNewImageRect) , lTemplateImage.size.width*2, lTemplateImage.size.height*2);
                break;
            case GSWatermarkTypeInstagramCollage:
                lWatermarkImage = [UIImage imageNamed:@"cover_collage_watermark.png"];
                lWatermarkRect = CGRectMake(CGRectGetMaxX(lNewImageRect) - lTemplateImage.size.width, CGRectGetMaxY(lNewImageRect) - lTemplateImage.size.height, lTemplateImage.size.width, lTemplateImage.size.height);
                break;
            default:
                break;
        }
        [lWatermarkImage drawInRect:lWatermarkRect];
    }
    lResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    return lResult;
}

- (void)setImageForCollageElement:(GSCollageElement*)pElement{
    UIImage *lImage = [self readImageFromFile:[NSString stringWithFormat:@"temp_%i", pElement.tag]];
    if (lImage) {
        [pElement setImage:lImage];
    }else{
        [pElement setImage:nil];
    }
}


- (BOOL) isViewEmpty {
    for (GSCollageElement *lElement in mArrayOfElements) {
        if (![lElement isEmpty]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) isViewFull {
    for (GSCollageElement *lElement in mArrayOfElements) {
        if ([lElement isEmpty]) {
            return NO;
        }
    }
    return YES;
}

- (void) setFrameWidth:(CGFloat)pFrame {
    mFrameWidth = pFrame;
    [mFrameView reDraw];
    NSLog(@"cv setFrameWidth %f", mFrameWidth);
    for (GSCollageElement *lCollageElement in mArrayOfElements) {
        [lCollageElement setFrameWidth:mFrameWidth];
    }
}

- (void) shuffleImage {
    
    for (NSUInteger index = 0; index < mArrayOfElements.count; index++) {
        NSUInteger lRandIndex = arc4random() % mArrayOfElements.count;
        if (lRandIndex != index) {
            NSString *lNewKey = [NSString stringWithFormat:@"temp_%i", lRandIndex];
            NSString *lCurrentKey = [NSString stringWithFormat:@"temp_%i", index];
            UIImage *lNewImage = [self readImageFromFile:lNewKey];
            UIImage *lCurrentImage = [self readImageFromFile:lCurrentKey];
            
            
            
            [self saveImage:lNewImage andName:lCurrentKey];
            [self saveImage:lCurrentImage andName:lNewKey];
        }
    }
    
    for (GSCollageElement *lElement in mArrayOfElements) {
        [self setImageForCollageElement:lElement];
    }
}

- (void) tapGestureRecognizer:(UITapGestureRecognizer*)pTapGesureRecognizer {
    NSLog(@"===================tap gesture recognizer==================");
    CGPoint lLocationInView = [pTapGesureRecognizer locationInView:mGesturesView];
    for (NSInteger index = mArrayOfElements.count-1; index >=0; index--) {
        GSCollageElement *lCollageElement = [mArrayOfElements objectAtIndex:index];
        if ([lCollageElement isElementContainPoint:lLocationInView]) {
            mSelectedElement = lCollageElement;
            if ([mDelegate respondsToSelector:@selector(GSCollageViewDelegateDidSelectCollage)]) {
                [mDelegate performSelector:@selector(GSCollageViewDelegateDidSelectCollage) withObject:self];
            }
            break;
        }
    }
}

- (void) panGestureRecognizer:(UIPanGestureRecognizer*)pPanGesureRecognizer {
    
        static GSCollageElement *sCollageElement = nil;
        CGPoint lLocationInView = [pPanGesureRecognizer locationInView:mGesturesView];
        CGPoint lTransitionInView = [pPanGesureRecognizer translationInView:mGesturesView];
        
        if ([pPanGesureRecognizer state] == UIGestureRecognizerStateBegan){
            for (NSInteger index = mArrayOfElements.count-1; index >=0; index--) {
                GSCollageElement *lCollageElement = [mArrayOfElements objectAtIndex:index];
                if ([lCollageElement isElementContainPoint:lLocationInView]) {
                    sCollageElement = lCollageElement;
                    break;
                }
            }
            [sCollageElement setTransition:lTransitionInView];
        } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateChanged){
            [sCollageElement setTransition:lTransitionInView];
        } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateEnded){
            CGPoint lVelocity = [pPanGesureRecognizer velocityInView:mGesturesView];
            [sCollageElement setTransition:lTransitionInView];
            [sCollageElement updatePositionsWithVelocity:lVelocity];
            sCollageElement = nil;
        }

        
        [pPanGesureRecognizer setTranslation:CGPointZero inView:mGesturesView];
}
- (void) pinchGestureRecognizer:(UIPinchGestureRecognizer*)pPinchGesureRecognizer {
    static GSCollageElement *sCollageElement = nil;
    
    if (pPinchGesureRecognizer.numberOfTouches != 2) {
        [pPinchGesureRecognizer setEnabled:NO];
        [sCollageElement updatePositionsWithVelocity:CGPointMake(0.0, 0.0)];
        sCollageElement = nil;
        [pPinchGesureRecognizer setEnabled:YES];
    }
    
    CGPoint lLocationInView = [pPinchGesureRecognizer locationInView:mGesturesView];
    
    if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint lTouchLocation = [pPinchGesureRecognizer locationOfTouch:0 inView:mGesturesView];
        for (NSInteger index = mArrayOfElements.count-1; index >=0; index--) {
            GSCollageElement *lCollageElement = [mArrayOfElements objectAtIndex:index];
            if ([lCollageElement isElementContainPoint:lTouchLocation]) {
                sCollageElement = lCollageElement;
                break;
            }
        }
        
        [sCollageElement setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
    } else if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateChanged){
        [sCollageElement setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
    } else if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateEnded) {
        [sCollageElement updatePositionsWithVelocity:CGPointMake(0.0, 0.0)];
        sCollageElement = nil;
    }
    
}

- (void) longPressGestureRecognizer:(UILongPressGestureRecognizer*)pLongPressGestureRecognizer {
    
    //detect touch location
    CGPoint lLocationInView = [pLongPressGestureRecognizer locationInView:mGesturesView];
    if (pLongPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //search tapped element
        for (NSInteger index = mArrayOfElements.count-1; index >=0; index--) {
            GSCollageElement *lCollageElement = [mArrayOfElements objectAtIndex:index];
            //if user tap element we show action sheet
            if ([lCollageElement isElementContainPoint:lLocationInView]) {
//                mCurrentElement = lCollageElement;
//                
//                UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Instagram",@"Camera", @"Camera Roll", nil];
//                lActionSheet.tag = 2;
//                lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//                [lActionSheet showInView:self.view];
//                
                break;
            }
        }
    }
}

#pragma mark - GSCollageElementFrame delegate
- (NSArray *)GSCollageElementFrameElemetasArray {
    return mArrayOfElements;
}

- (UIColor*) GSCollageElementFrameColor {
    return  mFrameColor;
}

- (CGFloat)GSCollageElementFrameWidth {
    return mFrameWidth;
}

#pragma mark - save/read image methods

- (void)saveImage:(UIImage *)pImage andName:(NSString *)pName{
    if (pImage) {
        [mPicturesDictionary setObject:pImage forKey:pName];    
    }else{
        [mPicturesDictionary removeObjectForKey:pName];
    }

}

- (UIImage *)readImageFromFile:(NSString *)pName{
    if ([mPicturesDictionary objectForKey:pName]) {
        return [mPicturesDictionary objectForKey:pName];
    }else{
        return nil;
    }
}


@end
