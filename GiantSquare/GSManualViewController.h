//
//  GSManualViewController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 2/6/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"

@interface GSManualViewController : GSAbstractViewController {
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UILabel *mHeaderLabel;
    IBOutlet UIButton *mFacebookButton;
    IBOutlet UIButton *mInstagramButton;
    IBOutlet UIButton *mTwitterButton;
    IBOutlet UIScrollView *mScrollView;
    IBOutlet UIImageView *mImageView;
    NSInteger mCurrentMode;
    
    UIImage *mFacebookImage;
    UIImage *mTwitterImage;
    UIImage *mInstagramImage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andMode:(NSInteger)pMode;
- (IBAction)backButtonPressed:(id)sender;


@property (nonatomic,strong) IBOutlet UIButton *backButton;
@property (nonatomic,strong) IBOutlet UIButton *closeButton;

@end
