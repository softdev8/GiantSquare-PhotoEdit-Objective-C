//
//  GSSlider.m
//  GiantSquare
//
//  Created by Lion on 3/2/14.
//  Copyright (c) 2014 Vakoms. All rights reserved.
//

#import "GSSlider.h"

@implementation GSSlider
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setMinimumValue:0];
        [self setMaximumValue:.99999];
        [self setContinuous:YES];
        [self setValue:.50];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setMinimumValue:.60000];
        [self setMaximumValue:.99999];
        [self setContinuous:YES];
        [self setValue:.99999];
        
        UIImage *thumbImage = [UIImage imageNamed:@"saturation-slider.png"];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        [self setThumbImage:thumbImage forState:UIControlStateHighlighted];

        
    }
    return self;
}
- (void)setValue:(float)value animated:(BOOL)animated
{
    [super setValue:value animated:animated];
    
    UIGraphicsBeginImageContext(CGSizeMake((self.frame.size.width * value),  self.frame.size.height/2));
    UIImage *colorSliderImg = [UIImage imageNamed:@"slider-button.png"];
    [colorSliderImg drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setMinimumTrackImage:colorSliderImg forState:UIControlStateNormal];
    
    UIGraphicsBeginImageContext(CGSizeMake((self.frame.size.width * (1 - value)),  self.frame.size.height/2));
    [colorSliderImg drawInRect:CGRectMake(-(self.frame.size.width * value), 0, self.frame.size.width, self.frame.size.height/2)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setMaximumTrackImage:colorSliderImg forState:UIControlStateNormal];
}


@end
