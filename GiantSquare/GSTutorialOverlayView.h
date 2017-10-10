//
//  GSTutorialOverlayView.h
//  GiantSquare
//
//  Created by roman.andruseiko on 4/13/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSTutorialOverlayViewDelegate <NSObject>
@optional;
- (void)viewExamplesPressed;
@end

@interface GSTutorialOverlayView : UIView<UIScrollViewDelegate>{
    NSInteger mCurrentType;
    UIScrollView *mScrollView;
    UIPageControl *mPageControl;
}

@property (nonatomic, assign) id <GSTutorialOverlayViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andType:(NSInteger)pType;
- (void)loadTutorial;

@end
