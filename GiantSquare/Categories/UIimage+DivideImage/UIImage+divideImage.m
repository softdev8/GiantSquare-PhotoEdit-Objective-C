//
//  UIImage+divideImage.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 12/24/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#define INSTAGRAM_IMAGE_SIZE 612
#define INSTAGRAM_WHITE_FRAME_COEFICIENT 50.0f
#define FOLDER_NAME @"giant_square_temp_image_folder"

#import "UIImage+divideImage.h"

@implementation UIImage (divideImage)

- (NSArray*) divideImageAtCols:(NSUInteger)pCols rows:(NSUInteger)pRows {
    NSMutableArray *lResult = [[NSMutableArray alloc] init];

    CGSize lNewImageSize = CGSizeMake(roundf(self.size.width / pCols), roundf(self.size.height / pRows));

    for (NSUInteger row = 0; row < pRows; row++) {
        for (NSUInteger col = 0; col < pCols; col++) {
            CGRect lRect = CGRectMake(-(col*lNewImageSize.width), -(row*lNewImageSize.height), self.size.width, self.size.height);
            UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
            [self drawInRect:lRect];
            UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
            [lResult addObject:lNewImage];
            UIGraphicsEndImageContext();
        }
    }
    
    return lResult;
}

- (UIImage *)getTwitterCuttedImage{
    CGFloat lScale = self.size.width/320.0f;
    CGSize lNewImageSize = CGSizeMake(roundf(320*lScale), roundf(162*lScale));
    CGRect lRect = CGRectMake(-(0), -(140*lScale), self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
    [self drawInRect:lRect];
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

- (UIImage *)getTwitterCuttedImageForIhone5{
    CGFloat lScale = self.size.width/320.0f;
    CGSize lNewImageSize = CGSizeMake(roundf(320*lScale), roundf(162*lScale));
    CGRect lRect = CGRectMake(-(0), -(163*lScale), self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1);
    [self drawInRect:lRect];
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

- (UIImage *)addShadowImage {
    UIImage *lShadowImage = [[UIImage imageNamed:@"filert_shadow2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(100, 100, 100, 100)];
    CGRect lRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(lRect.size, NO, 1.0);
    [self drawInRect:lRect];
    [lShadowImage drawInRect:lRect];
    
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

- (UIImage *)addShadowEffectImage {
    UIImage *lShadowImage = [UIImage imageNamed:@"filert_shadow1.png"];
    CGRect lRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(lRect.size, NO, 1.0);
    [self drawInRect:lRect];
    [lShadowImage drawInRect:lRect];
    
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

- (UIImage *)addTextureImage {
    
    UIImage *lShadowImage = [UIImage imageNamed:@"filter_texture2.png"];
    CGRect lRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(lRect.size, NO, 1.0);
    [self drawInRect:lRect];
    [lShadowImage drawAsPatternInRect:lRect];
    
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *resultImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(mask);
    CGImageRelease(masked);
    return resultImage;
    
}

- (UIImage *)getRectangleImage{
    CGFloat lScale = self.size.width/320.0f;
    if (self.size.width > self.size.height) {
       lScale = self.size.height/320.0f;
    }
    CGSize lNewImageSize = CGSizeMake(roundf(310*lScale), roundf(310*lScale));
    CGPoint lPosition = CGPointMake((lNewImageSize.width - self.size.width) / 2, (lNewImageSize.height - self.size.height) / 2);
    CGRect lRect = CGRectMake(lPosition.x, lPosition.y, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(lNewImageSize, NO, 1.0);
    [self drawInRect:lRect];
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

+ (UIImage *)getScaledImage:(UIImage *)pImage{
    //UIGraphicsBeginImageContext(newSize);
    CGSize lNewSize = CGSizeMake(INSTAGRAM_IMAGE_SIZE, INSTAGRAM_IMAGE_SIZE);
    UIGraphicsBeginImageContextWithOptions(lNewSize, NO, 0.0f);
    [pImage drawInRect:CGRectMake(0, 0, lNewSize.width, lNewSize.height)];
    UIImage *lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}


+ (UIImage *)getFacebookScaledImage:(UIImage *)pImage{
    //UIGraphicsBeginImageContext(newSize);
    CGSize lNewSize = CGSizeMake(pImage.size.width/2, pImage.size.height/2);
    UIGraphicsBeginImageContextWithOptions(lNewSize, NO, 0.5f);
    [pImage drawInRect:CGRectMake(0, 0, lNewSize.width, lNewSize.height)];
    UIImage *lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lNewImage;
}

- (UIImage *) getScaledImageFromHQ {
    CGFloat lBigestSide = MAX(self.size.width, self.size.height);
    if (lBigestSide > 3000) {
        CGFloat lCoeffitient = 3000.0/lBigestSide;
        CGSize lNewSize = CGSizeMake(roundf(self.size.width*lCoeffitient), roundf(self.size.height*lCoeffitient));
        UIGraphicsBeginImageContextWithOptions(lNewSize, NO, 1.0);
        [self drawInRect:CGRectMake(0, 0, lNewSize.width, lNewSize.height)];
        UIImage *lNewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return lNewImage;
    }else{
        return self;
    }
}


- (UIImage *)getScaledImageForTwitter{
    CGFloat lBigestSide = MAX(self.size.width, self.size.height);
    if (lBigestSide > 2000) {
        CGFloat lCoeffitient = 2000.0/lBigestSide;
        CGSize lNewSize = CGSizeMake(roundf(self.size.width*lCoeffitient), roundf(self.size.height*lCoeffitient));
        UIGraphicsBeginImageContextWithOptions(lNewSize, NO, 1.0);
        [self drawInRect:CGRectMake(0, 0, lNewSize.width, lNewSize.height)];
        UIImage *lNewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return lNewImage;
    }else{
        return self;
    }
}

- (UIImage *)getImageWithWhiteFrameAndQuality:(CGFloat)pQuality{
    DLog(@"pQuality - %f", pQuality);
    
    CGSize lSize = CGSizeMake(self.size.width*pQuality, self.size.height*pQuality);
//    UIBezierPath *lWhiteeFrame = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, 0.0f, lSize.width, lSize.height)];
//    [lWhiteeFrame setLineWidth:lSize.width / INSTAGRAM_WHITE_FRAME_COEFICIENT];
    CGRect lRect = CGRectMake(0, 0, lSize.width, lSize.height);
    UIGraphicsBeginImageContextWithOptions(lSize, NO, pQuality);
    [self drawInRect:lRect];
//    [[UIColor whiteColor] set];
//    [lWhiteeFrame stroke];
    UIImage* lNewImage = UIGraphicsGetImageFromCurrentImageContext();
    return lNewImage;
}

- (UIImage *)rotateImageWitSidesReplacingToAngle:(float)pAngle {
    UIView* rotatedViewBox = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.size.height, self.size.width)];
    float angleRadians = pAngle * ((float)M_PI / 180.0f);
    CGAffineTransform t = CGAffineTransformMakeRotation(angleRadians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, angleRadians);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.height / 2, -self.size.width / 2, self.size.height, self.size.width), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *)rotateImageToAngle:(float)pAngle{
    UIView* rotatedViewBox = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.size.width, self.size.height)];
    float angleRadians = pAngle * ((float)M_PI / 180.0f);
    CGAffineTransform t = CGAffineTransformMakeRotation(angleRadians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, angleRadians);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}




@end
