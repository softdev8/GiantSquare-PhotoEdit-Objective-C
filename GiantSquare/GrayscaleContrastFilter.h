#import "GPUImageFilter.h"

extern NSString *const kGrayscaleContrastFragmentShaderString;
extern NSString *const kRedscaleContrastFragmentShaderString;
extern NSString *const kGreenscaleContrastFragmentShaderString;
extern NSString *const kBluescaleContrastFragmentShaderString;

/** Converts an image to grayscale (a slightly faster implementation of the saturation filter, without the ability to vary the color contribution)
 */
@interface GrayscaleContrastFilter : GPUImageFilter
{
    GLint intensityUniform;
	GLint slopeUniform;
}

@property(readwrite, nonatomic) CGFloat intensity; 

- (id)initRed;
- (id)initGreen;
- (id)initBlue;
@end
