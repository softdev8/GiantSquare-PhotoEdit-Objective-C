//
//  GSInstagramCollageViewController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/15/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSInstagramCollageViewController.h"
#import "Flurry.h"
#import "MBBProgressHUD.h"

#define SHADOW_WIDTH 6
#define COLLAGE_CONTROLLER_HEIGHT 76

@interface GSInstagramCollageViewController ()

@end

@implementation GSInstagramCollageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mIsPortraite = YES;
        mIsCollageControllerShowed = YES;
        mTutorialType = GSTutorialTypeInstagramCollage;
        mWatermarkType = GSWatermarkTypeInstagramCollage;
        mCountOfFreeCollages = 10;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    mBottomHeader.transform = CGAffineTransformMakeScale(1.0f, -1.0f);
    [mBottomView setAutoresizingMask:0];
    
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        if (!mUseHasBoughtCollages) {
            [mShowHideCollagesButton setSelected:YES];
            [mShowHideCollagesButton setHidden:NO];
            [mCollageController setBlackBackground:YES];
        }
    } else {
        [mShowHideCollagesButton setHidden:YES];
    }
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundLight.png", @"backgroundLight_iPhone5.png")]]];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    
    [mBottomView setFrame:CGRectMake(0.0, self.view.frame.size.height - mBottomView.frame.size.height, mBottomView.frame.size.width, mBottomView.frame.size.height)];
    
    CGFloat lCollageY = (mBottomView.frame.origin.y + CGRectGetMaxY(mCollageView.frame) - 3.0 - COLLAGE_CONTROLLER_HEIGHT) / 2.0;
    if (([UIScreen mainScreen].bounds.size.height < 500) || !mUseHasBoughtCollages) {
        lCollageY = mBottomView.frame.origin.y - mCollageController.frame.size.height + SHADOW_WIDTH;
    }
    [mCollageController setFrame:CGRectMake(0.0,lCollageY, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];

}

- (void) initAds {
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {

            mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                    size:MOPUB_BANNER_SIZE];
            [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height + MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
            mIsBannerAppear = NO;
        }
    }
}

- (void) initCollagesArray {
    mArrayOfColages = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"instagram_collages" ofType:@"plist"]];
}

- (void) initSwitcher {
    CGFloat lX = 110.0;
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        lX = 152.0;
    }
    mSwitcher = [[GSCollageSwitcher alloc] initWithFrame:CGRectMake(lX, mBottomView.frame.size.height - 41.0, 100.0, 40.0)];
    [mSwitcher setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [mSwitcher setDelegate:self];
    [mBottomView addSubview:mSwitcher];
}

- (void) initCollageController {
    CGFloat lCollageY = (mBottomView.frame.origin.y + CGRectGetMaxY(mCollageView.frame) - 3.0 - COLLAGE_CONTROLLER_HEIGHT) / 2.0;
    mCollageController = [[GSCollageController alloc] initWithFrame:CGRectMake(0.0,lCollageY, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
    [mCollageController setAutoresizingMask:0];
    [mCollageController setDelegate:self];
    [mCollageController loadTemplates];
    [self.view insertSubview:mCollageController belowSubview:mBottomView];
}

#pragma mark - GSCollageController delegate
- (CGSize) GSCollageControllerDelegateTemplateSize {
    return CGSizeMake(52.0f, 52.0f);
}

- (UIImage*) GSCollageControllerDelegateImageForTemplate:(NSUInteger)pIndex {
    return [UIImage imageNamed:[NSString stringWithFormat:@"instagram_collage_%i.png", pIndex]];
}

- (UIImage*) GSCollageControllerDelegateImageForActiveTemplate:(NSUInteger)pIndex {
    return [UIImage imageNamed:[NSString stringWithFormat:@"instagram_collage_%i_active.png", pIndex]];
}

#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == LOAD_ACTION_SHEET_TAG) {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    } else {
        if (buttonIndex == 0) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self saveImage:[mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeInstagramCollage] toAlbum:ALBUM_NAME];
        } else if (buttonIndex == 1){
            NSURL *lInstagramURL = [NSURL URLWithString:@"instagram://app"];
            
            if ([[UIApplication sharedApplication] canOpenURL:lInstagramURL]) {
                [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                NSString *lImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempImage.igo"];
                [UIImageJPEGRepresentation([mCollageView getImageForPublishWithWatermarkType:GSWatermarkTypeInstagramCollage], 1.0) writeToFile:lImagePath atomically:YES];
                
                self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"file://%@", lImagePath]]];
                self.documentController.UTI = @"com.instagram.photo";
                self.documentController.delegate = self;
                self.documentController.annotation = [NSDictionary dictionaryWithObject:@"#giantcollage" forKey:@"InstagramCaption"];
                [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
                
                [MBBProgressHUD hideHUDForView:self.view animated:YES];
            } else {
                UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You need to have Instagram installed on your phone for this option to work." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [lAlertView show];
            }
        }
    }
}

#pragma mark - documentInteractionController delegate
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    [self showAds];
}


#pragma mark - buttons Methods
- (IBAction) backPressed {
    [super backPressed];
    [Flurry endTimedEvent:@"instagramCollagePressed" withParameters:nil];
}

- (IBAction) donePressed {
    [self.navigationController popViewControllerAnimated:YES];
    [Flurry endTimedEvent:@"instagramCollagePressed" withParameters:nil];
}


- (IBAction) publishPressed {    
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Open in Instagram", nil];
	lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[lActionSheet showInView:self.view];
    [Flurry logEvent:@"exportPressed"];
}

- (IBAction) helpPressed:(id)pSender {
    [super helpPressed:pSender];
}

- (IBAction) showHideCollageControllerButtonPressed:(id)pSender {
    if (mIsCollageControllerShowed) {
        [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                      
            [mCollageController setFrame:CGRectMake(0.0, mBottomView.frame.origin.y + SHADOW_WIDTH, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
        } completion:^(BOOL finished) {
            [mCollageController setHidden:YES];
        }];
    } else {
        [mCollageController setHidden:NO];
        [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [mCollageController setFrame:CGRectMake(0.0, mBottomView.frame.origin.y - mCollageController.frame.size.height + SHADOW_WIDTH, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
        } completion:^(BOOL finished) {
            
        }];
    }
    
    mIsCollageControllerShowed = !mIsCollageControllerShowed;
    [mShowHideCollagesButton setSelected:mIsCollageControllerShowed];
}

#pragma mark -InterfaceOrientation methods-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }else{
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MPAdViewDelegate methods
- (void) animationStart {
    mIsBannerAppear = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    [mBottomView setFrame:CGRectMake(0.0, self.view.frame.size.height - mBottomView.frame.size.height - MOPUB_BANNER_SIZE.height, mBottomView.frame.size.width, mBottomView.frame.size.height)];
    
    CGFloat lCollageY = (mBottomView.frame.origin.y + CGRectGetMaxY(mCollageView.frame) - 3.0) / 2.0 - 33.0;
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        if (mIsCollageControllerShowed) {
            lCollageY = mBottomView.frame.origin.y - mCollageController.frame.size.height + SHADOW_WIDTH;
        } else {
            lCollageY = mBottomView.frame.origin.y + SHADOW_WIDTH;
        }
    }

    [mCollageController setFrame:CGRectMake(0.0, lCollageY, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
    [UIView commitAnimations];
    
}
- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        [self.view insertSubview:mAdView aboveSubview:mBottomView];
        [self animationStart];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}

- (void) removeAds {
    [super removeAds];
    [mShowHideCollagesButton setEnabled:NO];
    
    [mCollageController setBlackBackground:NO];
    [mCollageController setHidden:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mShowHideCollagesButton setAlpha:0.0];
        [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        
        [mBottomView setFrame:CGRectMake(0.0, self.view.frame.size.height - mBottomView.frame.size.height, mBottomView.frame.size.width, mBottomView.frame.size.height)];
        
        [mSwitcher setCenter:CGPointMake(160.0, mSwitcher.center.y)];
        CGFloat lCollageY = (mBottomView.frame.origin.y + CGRectGetMaxY(mCollageView.frame) - 3.0 - COLLAGE_CONTROLLER_HEIGHT) / 2.0;
        
        [mCollageController setAlpha:1.0];
        [mCollageController setFrame:CGRectMake(0.0, lCollageY, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
    } completion:^(BOOL finished) {
        [mShowHideCollagesButton setHidden:YES];
        [mAdView setHidden:YES];
        [mAdView removeFromSuperview];
        mAdView = nil;
    }];
}

@end
