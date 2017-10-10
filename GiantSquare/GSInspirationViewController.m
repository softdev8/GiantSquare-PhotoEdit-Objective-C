//
//  GSInspirationViewController.m
//  GiantSquare
//
//  Created by Andriy Melnyk on 4/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSInspirationViewController.h"
#import "Reachability.h"
@interface GSInspirationViewController ()

@end

@implementation GSInspirationViewController

@synthesize closeButton;
@synthesize backButton;
#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andMode:(GSTutorialType)pMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mCurrentMode = pMode;
    }
    return self;
}


#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //set background image
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDark_iPhone5.png"]]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDark.png"]]];
    }

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initHelp];
}

- (void)initHelp{
    __block UIImage *lCurrentImage = nil;
    NSString *lServiceType = @"";
    if ((mCurrentMode == GSTutorialTypeFacebook) || (mCurrentMode == GSTutorialTypeFacebookCollage)) {
        lServiceType = @"Facebook";
        lCurrentImage = mFacebookImage;
    }else if((mCurrentMode == GSTutorialTypeInstagram) || (mCurrentMode == GSTutorialTypeInstagramCollage)){
        lServiceType = @"Instagram";
        lCurrentImage = mInstagramImage;
    }else if((mCurrentMode == GSTutorialTypeTwitter) || (mCurrentMode == GSTutorialTypeTwitterCollage)){
        lServiceType = @"Twitter";
        lCurrentImage = mTwitterImage;
    }
    
    [mScrollView setHidden:YES];
    
    [mHeaderLabel setText:lServiceType];
    UIActivityIndicatorView * lActivityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [lActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [lActivityIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:lActivityIndicator];
    [lActivityIndicator setCenter:self.view.center];
    [lActivityIndicator startAnimating];
    mFacebookButton.enabled = NO;
    mInstagramButton.enabled = NO;
    mTwitterButton.enabled = NO;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        CGFloat lCoeficient = 0.5f;
        if (!lCurrentImage) {
//            if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
                lCurrentImage = [UIImage imageNamed:[NSString stringWithFormat:@"inspiration%@Help@2x.png", lServiceType]];
//            }else{
//                lCurrentImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.218.115.129/media/iOS/inspiration/inspiration%@Help@2x.png", lServiceType]]]];
//            }
            if ((mCurrentMode == GSTutorialTypeFacebook) || (mCurrentMode == GSTutorialTypeFacebookCollage)) {
                mFacebookImage = lCurrentImage;
            }else if((mCurrentMode == GSTutorialTypeInstagram) || (mCurrentMode == GSTutorialTypeInstagramCollage)){
                mInstagramImage = lCurrentImage;
            }else if((mCurrentMode == GSTutorialTypeTwitter) || (mCurrentMode == GSTutorialTypeTwitterCollage)){
                mTwitterImage = lCurrentImage;
            }
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deselectAllButtons];
            mFacebookButton.enabled = YES;
            mInstagramButton.enabled = YES;
            mTwitterButton.enabled = YES;
            [mImageView setFrame:CGRectMake(0, 0, lCurrentImage.size.width*lCoeficient, lCurrentImage.size.height*lCoeficient)];
            [mImageView setContentMode:UIViewContentModeScaleAspectFit];
            [mImageView setImage:lCurrentImage];
            [mScrollView setContentSize:CGSizeMake(lCurrentImage.size.width*lCoeficient, lCurrentImage.size.height*lCoeficient)];
            [lActivityIndicator stopAnimating];
            [lActivityIndicator removeFromSuperview];
            [mScrollView setHidden:NO];
            
            if ((mCurrentMode == GSTutorialTypeFacebook) || (mCurrentMode == GSTutorialTypeFacebookCollage)) {
                [mFacebookButton setSelected:YES];
            }else if((mCurrentMode == GSTutorialTypeInstagram) || (mCurrentMode == GSTutorialTypeInstagramCollage)){
                [mInstagramButton setSelected:YES];
            }else if((mCurrentMode == GSTutorialTypeTwitter) || (mCurrentMode == GSTutorialTypeTwitterCollage)){
                [mTwitterButton setSelected:YES];
            }
        });
    });
    
    
    [mScrollView setContentOffset:CGPointMake(0, 0)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - buttons methods

- (IBAction)closeButtonPressed:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sourceTypeButtonPressed:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *lButton = (UIButton*)sender;
        mCurrentMode = lButton.tag;
        [self initHelp];
    }
}

- (IBAction)backButtonPressed:(id)pSender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deselectAllButtons{
    [mFacebookButton setSelected:NO];
    [mInstagramButton setSelected:NO];
    [mTwitterButton setSelected:NO];
}

#pragma mark -InterfaceOrientation methods-

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

@end