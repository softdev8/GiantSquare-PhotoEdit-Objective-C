//
//  GSFacebookChoosingViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 1/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSFacebookChoosingViewController.h"
#import "GSFacebookCameraViewController.h"
#import "GSFacebookCollageViewController.h"

@interface GSFacebookChoosingViewController ()

@end

@implementation GSFacebookChoosingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set correct buttons
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [mGiantButton setImage:[UIImage imageNamed:@"giantCoverButton_iPhone5.png"] forState:UIControlStateNormal];
        [mCollageButton setImage:[UIImage imageNamed:@"collageCoverButton_iPhone5.png"] forState:UIControlStateNormal];
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar_iPhone5.png"]];
    }
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundDarkLandscape.png", @"backgroundDarkLandscape_iPhone5.png")]]];
    
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        BOOL lUseHasRemovedAds;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
            lUseHasRemovedAds = YES;
        } else {
            lUseHasRemovedAds = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED];
        }
        if (!lUseHasRemovedAds) {
            mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                    size:MOPUB_BANNER_SIZE];
            [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.origin.y - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }
        
        mIsBannerAppear = NO;
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] || [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {

        if (mIsBannerAppear) {
            [mAdView setHidden:YES];
            [mAdView removeFromSuperview];
            mAdView = nil;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - buttons Methods

-(IBAction)backPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
    [Flurry endTimedEvent:@"facebookPressed" withParameters:nil];
}

-(IBAction)collagePressed{
    GSFacebookCollageViewController *lViewController = [[GSFacebookCollageViewController alloc] initWithNibName:@"GSFacebookCollageViewController" bundle:nil];
    [self.navigationController pushViewController:lViewController animated:YES];
    
    [Flurry logEvent:@"facebookCollagePressed" timed:YES];
}

-(IBAction)giantPressed{
    GSFacebookCameraViewController *lViewController = [[GSFacebookCameraViewController alloc] initWithNibName:@"GSFacebookCameraViewController" bundle:nil];
    lViewController.timeLineIsNew = YES;
    [self.navigationController pushViewController:lViewController animated:YES];
    
    [Flurry logEvent:@"facebookGiantPressed" timed:YES];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
    }else{
        return NO;
    }
}


#pragma mark - MPAdViewDelegate methods
- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    
    if (mIsBannerAppear == NO) {
        mIsBannerAppear = YES;
        [mAdView setFrame:CGRectMake((self.view.frame.size.width  - mAdView.frame.size.width)/2, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        [self.view addSubview:mAdView];
    }
}
- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}

@end
