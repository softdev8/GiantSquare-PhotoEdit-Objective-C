//
//  GSInspirationViewController.h
//  GiantSquare
//
//  Created by Andriy Melnyk on 4/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSInspirationViewController : GSAbstractViewController{
    
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UILabel *mHeaderLabel;
    IBOutlet UIButton *mFacebookButton;
    IBOutlet UIButton *mInstagramButton;
    IBOutlet UIButton *mTwitterButton;
    IBOutlet UIScrollView *mScrollView;
    IBOutlet UIImageView *mImageView;
   
    GSTutorialType mCurrentMode;

    UIImage *mFacebookImage;
    UIImage *mTwitterImage;
    UIImage *mInstagramImage;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andMode:(GSTutorialType)pMode;
- (IBAction)backButtonPressed:(id)pSender;

@property (nonatomic,strong) IBOutlet UIButton *backButton;
@property (nonatomic,strong) IBOutlet UIButton *closeButton;
@end
