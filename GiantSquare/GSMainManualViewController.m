//
//  GSMainManualViewController.m
//  GiantSquare
//
//  Created by Andriy Melnyk on 4/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSMainManualViewController.h"
#import "GSManualViewController.h"
#import "GSInspirationViewController.h"
#import "GSAppDelegate.h"

@interface GSMainManualViewController ()

@end

@implementation GSMainManualViewController

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
    
    //set background image
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLight_iPhone5.png"]]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLight.png"]]];
    }
    
    
    // init advertisment
    
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
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }
        
        mIsBannerAppear = NO;
    }

   
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -public buttons methods-

- (IBAction)textManualPressed:(id)pSender{
    GSManualViewController *lViewController = [[GSManualViewController alloc] initWithNibName:@"GSManualViewController" bundle:nil andMode:0];
    [self.navigationController pushViewController:lViewController animated:YES];
    lViewController.closeButton.hidden = YES;
}

-(IBAction)inspiratioPressed:(id)pSender{
    DLog(@"inspirationPressed");
    GSInspirationViewController *lViewController = [[GSInspirationViewController alloc] initWithNibName:@"GSInspirationViewController" bundle:nil andMode:GSTutorialTypeFacebook];
    
    [self.navigationController pushViewController:lViewController animated:YES];
    lViewController.closeButton.hidden = YES;
}

- (IBAction)backPressed:(id)pSender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MPAdViewDelegate methods
- (UIViewController *) viewControllerForPresentingModalView {
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        [self.view addSubview:mAdView];
        mIsBannerAppear = YES;
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
}

@end
