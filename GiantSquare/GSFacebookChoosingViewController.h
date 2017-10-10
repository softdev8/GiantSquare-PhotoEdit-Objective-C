//
//  GSFacebookChoosingViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "Flurry.h"

@interface GSFacebookChoosingViewController : GSAbstractViewController <MPAdViewDelegate>{
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UIButton *mCollageButton;
    IBOutlet UIButton *mGiantButton;
    
    Flurry *mFlurry;
    
    MPAdView *mAdView;
    BOOL mIsBannerAppear;

}

@end
