//
//  GSManualViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 2/6/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSManualViewController.h"
#import "Reachability.h"

@interface GSManualViewController ()

@end

@implementation GSManualViewController

@synthesize closeButton;
@synthesize backButton;

#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andMode:(NSInteger)pMode
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
    if (mCurrentMode == 0) {
        lServiceType = @"Facebook";
        lCurrentImage = mFacebookImage;
    }else if(mCurrentMode == 1){
        lServiceType = @"Instagram";
        lCurrentImage = mInstagramImage;
    }else if(mCurrentMode == 2){
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
                lCurrentImage = [UIImage imageNamed:[NSString stringWithFormat:@"helpManual%@@2x.png", lServiceType]];
//            }else{
//                lCurrentImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://54.218.115.129/media/iOS/manual/helpManual%@@2x.png", lServiceType]]]];
//            }
            if (mCurrentMode == 0) {
                mFacebookImage = lCurrentImage;
            }else if(mCurrentMode == 1){
                mInstagramImage = lCurrentImage;
            }else if(mCurrentMode == 2){
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
            
            if (mCurrentMode == 0) {
                [mFacebookButton setSelected:YES];
            }else if(mCurrentMode == 1){
                [mInstagramButton setSelected:YES];
            }else if(mCurrentMode == 2){
                [mTwitterButton setSelected:YES];
            }
        });
    });
    
    
    [mScrollView setContentOffset:CGPointMake(0, 0)];
    
}

- (IBAction)closeButtonPressed:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - buttons methods

- (IBAction)backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sourceTypeButtonPressed:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *lButton = (UIButton*)sender;
        mCurrentMode = lButton.tag;
        [self initHelp];        
    }
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
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }else{
        return NO;
    }
}


@end
