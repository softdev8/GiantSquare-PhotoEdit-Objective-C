//
//  GSTwitterCoosingViewController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 4/24/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSTwitterCoosingViewController.h"
#import "GSTwitterCameraViewController.h"
#import "GSTwitterCollageViewController.h"
#import "GSCustomNavigationController.h"
#import "Flurry.h"

@interface GSTwitterCoosingViewController ()
@end

@implementation GSTwitterCoosingViewController

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
            [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }
        mIsBannerAppear = NO;
        
    }
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundDark.png", @"backgroundDark_iPhone5.png")]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL lUseHasRemovedAds;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
        lUseHasRemovedAds = YES;
    } else {
        lUseHasRemovedAds = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED];
    };
    if (lUseHasRemovedAds) {
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

- (IBAction) backPressed {
    [self.navigationController popViewControllerAnimated:YES];
    [Flurry endTimedEvent:@"twitterPressed" withParameters:nil];
}

- (IBAction) collagePressed {
    GSTwitterCollageViewController *lViewController = [[GSTwitterCollageViewController alloc] initWithNibName:@"GSTwitterCollageViewController" bundle:nil];
    GSCustomNavigationController *lNavigationController = [[GSCustomNavigationController alloc] initWithRootViewController:lViewController];
    lNavigationController.navigationBar.hidden = YES;
    lNavigationController.navigationBarHidden = YES;
    lNavigationController.isPortrait = NO;
    [self presentModalViewController:lNavigationController animated:YES];

    [Flurry logEvent:@"twitterCollagePressed" timed:YES];
}

- (IBAction) giantPressed {
    GSTwitterCameraViewController *lViewController = [[GSTwitterCameraViewController alloc] initWithNibName:@"GSTwitterCameraViewController" bundle:nil];
    [self.navigationController pushViewController:lViewController animated:YES];
    [Flurry logEvent:@"twitterGiantPressed" timed:YES];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - MPAdViewDelegate methods
- (void) animationStart {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    mIsBannerAppear = YES;
    
    [mAdView setFrame:CGRectMake(0.0, self.view.frame.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    [UIView commitAnimations];
    
}

- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view {
    
    if (mIsBannerAppear == NO){
        [mAdView setFrame:CGRectMake(0.0, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        [self.view addSubview:mAdView];
        [self animationStart];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}

@end
