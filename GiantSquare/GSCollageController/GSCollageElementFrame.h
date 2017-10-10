//
//  GSCollageElementFrame.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/23/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSCollageElementFrameDelegate;
@interface GSCollageElementFrame : UIView {

}

@property (nonatomic, assign) id <GSCollageElementFrameDelegate> delegate;

- (void) reDraw;

@end

@protocol GSCollageElementFrameDelegate <NSObject>

- (NSArray*) GSCollageElementFrameElemetasArray;
- (UIColor*) GSCollageElementFrameColor;
- (CGFloat) GSCollageElementFrameWidth;

@end