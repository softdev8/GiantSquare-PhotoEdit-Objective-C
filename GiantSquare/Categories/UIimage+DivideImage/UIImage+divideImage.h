//
//  UIImage+divideImage.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 12/24/12.
//  Copyright (c) 2012 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (divideImage)

- (NSArray*)divideImageAtCols:(NSUInteger)pCols rows:(NSUInteger)pRows;
- (UIImage *)getImageWithWhiteFrameAndQuality:(CGFloat)pQuality;
+ (UIImage *)getScaledImage:(UIImage *)pImage;
- (UIImage *)getRectangleImage;
- (UIImage *)rotateImageToAngle:(float)pAngle;
- (UIImage *)rotateImageWitSidesReplacingToAngle:(float)pAngle;
+ (UIImage *)getFacebookScaledImage:(UIImage *)pImage;
- (UIImage *)getTwitterCuttedImage;
- (UIImage *)getTwitterCuttedImageForIhone5;
- (UIImage *)addShadowImage;
- (UIImage *)addShadowEffectImage;
- (UIImage *)addTextureImage;
- (UIImage *)getScaledImageFromHQ;
- (UIImage *)getScaledImageForTwitter;
@end
