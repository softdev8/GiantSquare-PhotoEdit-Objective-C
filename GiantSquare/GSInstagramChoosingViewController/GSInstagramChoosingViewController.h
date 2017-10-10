//
//  GSInstagramChoosingViewController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 4/24/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

@interface GSInstagramChoosingViewController : GSAbstractViewController <MPAdViewDelegate> {
    MPAdView *mAdView;
    
    BOOL mIsBannerAppear;
}

- (IBAction) backPressed;
- (IBAction) collagePressed;
- (IBAction) giantPressed;
- (IBAction) squarePressed;

@end
