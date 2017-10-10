//
//  GSMainManualViewController.h
//  GiantSquare
//
//  Created by Andriy Melnyk on 4/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

@interface GSMainManualViewController : GSAbstractViewController<MPAdViewDelegate>{
    
    MPAdView *mAdView;
    BOOL mIsBannerAppear;
}

- (IBAction)backPressed:(id)pSender;

@end
