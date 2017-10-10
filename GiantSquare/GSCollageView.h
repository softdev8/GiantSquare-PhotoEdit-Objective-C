//
//  GSCollageView.h
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSCollageElement.h"
#import "GSCollageElementFrame.h"

@protocol GSCollageViewDelegate <NSObject>
- (void) GSCollageViewDelegateDidSelectCollage;
//data sources
- (NSUInteger) GSCollageViewDelegateCountOfElemets;
- (NSArray*) GSCollageViewDelegateArraOfPointForElement:(NSUInteger)pElementIndex;
@end

@interface GSCollageView : UIView <GSCollageElementFrameDelegate> {
    UIView *mElementsView;
    UIView *mGesturesView;
    
    UIColor *mFrameColor;
    
    GSCollageElementFrame *mFrameView;
    
    NSMutableArray *mArrayOfElements;
    
    GSCollageElement *mSelectedElement;
    NSMutableDictionary *mPicturesDictionary;
    
    __unsafe_unretained id mDelegate;
    CGFloat mFrameWidth;
}

@property (nonatomic, assign) id delegate;


- (void) setImageForSelectedElement:(UIImage*)pImage;
- (UIImage*) getImageForPublishWithWatermarkType:(GSWatermarkType)pType;
- (BOOL) isViewEmpty;
- (BOOL) isViewFull;
- (void) setFrameWidth:(CGFloat)pFrame;
- (void) shuffleImage;
- (void) setImagesForFreePlaces:(NSArray *)pArray;
- (void) setFrameColor:(UIColor*)pColor;

//new methods
- (void) reloadElements;
@end
