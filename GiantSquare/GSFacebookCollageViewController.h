//
//  GSFacebookCollageViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSCollageViewController.h"
#import "GSFacebookLoginView.h"

@interface GSFacebookCollageViewController : GSCollageViewController <GSFacebookLoginViewDelegate>{
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UIImageView *mBackgroundImageView;
    IBOutlet UIView *mMainView;
}

@end
