//
//  GSCollageElementFrame.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/23/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSCollageElementFrame.h"
#import "GSCollageElement.h"

@implementation GSCollageElementFrame

@synthesize delegate;

- (void) reDraw {
    [self setNeedsDisplay];
}

- (CGPoint) checkPointPos:(CGPoint)pPoint forWidth:(CGFloat)pWidth {
    CGPoint lResult = pPoint;
    
    if (pPoint.x == 0) {
        lResult.x = pWidth / 2.0;
    }
    
    if (pPoint.y == 0) {
        lResult.y = pWidth / 2.0;
    }
    
    if (pPoint.x == self.frame.size.width) {
        lResult.x = self.frame.size.width - pWidth / 2.0;
    }
    
    if (pPoint.y == self.frame.size.height) {
        lResult.y = self.frame.size.height - pWidth / 2.0;
    }
    
    return lResult;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.delegate != nil) {
        NSArray *lArrayOfElements = nil;
        
        if ([self.delegate respondsToSelector:@selector(GSCollageElementFrameElemetasArray)]) {
            lArrayOfElements = [self.delegate GSCollageElementFrameElemetasArray];
        }
        
        if (lArrayOfElements != nil) {
            CGFloat lFrameWidth = 0.0;
            if ([self.delegate respondsToSelector:@selector(GSCollageElementFrameWidth)]) {
                lFrameWidth = [self.delegate GSCollageElementFrameWidth];
            }
            
            UIColor *lFrameColor = [UIColor blackColor];
            if ([self.delegate respondsToSelector:@selector(GSCollageElementFrameColor)]) {
                lFrameColor = [self.delegate GSCollageElementFrameColor];
            }
            
            UIBezierPath *lPath = [UIBezierPath bezierPath];
            
            for (GSCollageElement *lElement in lArrayOfElements) {
                CGPoint lPoint = CGPointFromString([lElement.arrayOfPoints objectAtIndex:0]);
                lPoint = [self checkPointPos:lPoint forWidth:lFrameWidth];
                [lPath moveToPoint:CGPointMake(lPoint.x, lPoint.y)];
                
                for (NSInteger i = 1; i < lElement.arrayOfPoints.count; i++) {
                    lPoint = CGPointFromString([lElement.arrayOfPoints objectAtIndex:i]);
                    lPoint = [self checkPointPos:lPoint forWidth:lFrameWidth];
                    [lPath addLineToPoint:CGPointMake(lPoint.x, lPoint.y)];
                }
                [lPath closePath];
            }
            
            [lFrameColor set];
            [lPath setLineWidth:lFrameWidth];
            [lPath stroke];
        }
    }
}


@end
