//
//  GSInstagramCollageViewController.m
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/15/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSInstagramTextSquareViewController.h"
#import "Flurry.h"
#import "MBBProgressHUD.h"
#import "Global.h"
#import "PhotoPickerViewController.h"
#import "GSSlider.h"
#import "GSCustomCell.h"

#define SHADOW_WIDTH 6
#define COLLAGE_CONTROLLER_HEIGHT 66

@interface GSInstagramTextSquareViewController ()

@end

@implementation GSInstagramTextSquareViewController
@synthesize m_cmImage;
@synthesize m_workView;
@synthesize m_cmRect;
@synthesize mBottomView;
@synthesize m_squareColorArray;
@synthesize cmBgColor;
@synthesize m_nRotateCnt;
@synthesize m_originalRect;
@synthesize m_originalImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        global_GSCategory = GS_INSTAGRAM_SQUARE;
        
    }
    return self;
}

- (void)viewDidLoad
{
    m_workView.layer.zPosition = 0;
     m_squareColorArray = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"instagram_square" ofType:@"plist"]];
    [super viewDidLoad];
    [self.m_workView.layer setBorderColor:[UIColor colorWithWhite:0.78 alpha:1.0].CGColor];
    [self.m_workView.layer setBorderWidth:0.0f];
    [m_bgColor setImage:[UIImage imageNamed:@"square_active_0.png"] forState:UIControlStateNormal];
    m_curTextView = [[UIImageView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        CGRect workViewRect = CGRectMake(self.m_workView.frame.origin.x, self.m_workView.frame.origin.y, self.m_workView.frame.size.width, self.m_workView.frame.size.height + OFFSET_DEVICE);
        self.m_workView.frame = workViewRect;
        [m_workView setImage:[UIImage imageNamed:@"guide_iPhone5.png"]];

        [backgroundView setFrame:CGRectMake(0, 45, 320, 369)];
        [backgroundView setImage:[UIImage imageNamed:@"background_blue5.png"]];
        [overideView setFrame:CGRectMake(0, 414, 320, 111)];
        [overideView setImage:[UIImage imageNamed:@"overide_iPhone5.png"]];
        [bottomView setImage:[UIImage imageNamed:@"bottom_Blur5.png"]];
        
        [bottomView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - mBottomView.frame.size.height, 320, mBottomView.frame.size.height)];
        m_originalPortraitRect = CGRectMake(23, 0, 274, 367);
        m_originalLandscapeRect = CGRectMake(0, 64, 320, 239);
        m_cmRect = m_originalPortraitRect;
        [m_fontPanel setFrame:FONTVIEW_FRAME_HIDE5];
        [fontViewIamge setFrame:FONTVIEW_FRAME_HIDE5];
    }
    else
    {
        [m_workView setImage:[UIImage imageNamed:@"guide_iPhone4.png"]];
        m_originalPortraitRect = CGRectMake(56, 0, 208, 279);
        m_originalLandscapeRect = CGRectMake(0, 20, 320, 239);
        
        [backgroundView setFrame:CGRectMake(0, 45, 320, 281)];
        [backgroundView setImage:[UIImage imageNamed:@"background_blur4.png"]];
        [overideView setFrame:CGRectMake(0, 326, 320, 111)];
        [overideView setImage:[UIImage imageNamed:@"overide_iPhone4.png"]];
        [bottomView setImage:[UIImage imageNamed:@"bottom_Blur4.png"]];
        m_cmRect = m_originalPortraitRect;
        [m_fontPanel setFrame:FONTVIEW_FRAME_HIDE4];
        [fontViewIamge setFrame:FONTVIEW_FRAME_HIDE4];
    }
    m_originalRect = m_cmRect;
    m_cmImage = [[UIImageView alloc] initWithFrame:m_cmRect];
    [m_textControlPanel setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - m_textControlPanel.frame.size.height, 320, m_textControlPanel.frame.size.height)];
    [m_workView setUserInteractionEnabled:YES];
    m_txtView = [[UITextView alloc] init];
    m_textView.layer.borderWidth = 2.f;
    m_textView.layer.borderColor = [[UIColor orangeColor] CGColor];

#pragma test
    
    [self.m_workView addSubview:m_cmImage];
    UITapGestureRecognizer *lTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [lTapRecognizer setNumberOfTapsRequired:1];
    [self.m_workView addGestureRecognizer:lTapRecognizer];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.m_workView addGestureRecognizer:doubleTap];
    
    
    UIPanGestureRecognizer *lPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
	[lPanRecognizer setMinimumNumberOfTouches:1];
	[self.m_workView addGestureRecognizer:lPanRecognizer];
    
    UIPinchGestureRecognizer *lPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
	[self.m_workView addGestureRecognizer:lPinchRecognizer];
    
    UILongPressGestureRecognizer *lLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    lLongPressRecognizer.minimumPressDuration = 0.5;
    [self.m_workView addGestureRecognizer:lLongPressRecognizer];
    [self initVariables];
    
    m_txtDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_txtDeleteBtn addTarget:self action:@selector(deleteText:) forControlEvents:UIControlEventTouchUpInside];
    [m_txtDeleteBtn setImage:[UIImage imageNamed:@"delete-text.png"] forState:UIControlStateNormal];
    m_txtDeleteBtn.frame = CGRectMake(0,0, 11.f, 10.f);
    [m_workView addSubview:m_txtDeleteBtn];
    m_txtDeleteBtn.hidden = YES;
    [m_txtDeleteBtn bringSubviewToFront:m_workView];
}

- (void) doubleTapGesture:(UIGestureRecognizer*)pGestureRecognizer
{
    //[self resetImage:nil];
    if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
        PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] init];
        [lPhotoController setDelegate:self];
        [lPhotoController setIsMultipleSelectionEnabled:YES];
        [self presentModalViewController:lPhotoController animated:YES];
    }else{
        if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
            [self openCameraRoll];
        }else{
            [self showiOS5Alert];
            
        }
        
    }
}

- (void) initVariables
{
    isPhoto = YES;
    isShowColorPicker = NO;
    isFirst = YES;
    isFixed = NO;
    m_freeCountFont = 6;
    m_nRotateCnt = 0;
    mMaxScale = 2.0f;
    mMinScale = 1.0f;
    mScale = 1.f;
    m_fsize = @"15";

    r = 1.f; g = 1.f; b = 1.f;
    cmBgColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    
    [m_slTextTransparency._trackImageViewHighlighted.layer setCornerRadius:8.f];
    [m_slTextTransparency._trackImageViewHighlighted.layer setMasksToBounds:YES];
    
    [m_slTextTransparency._trackImageViewNormal.layer setCornerRadius:8.f];
    [m_slTextTransparency._trackImageViewNormal.layer setMasksToBounds:YES];
    
    [m_slTextTransparency._thumbImageView setImage:[UIImage imageNamed:@"slider-handle.png"]];
    
    m_slBrightness.labelAboveThumb.font = [UIFont boldSystemFontOfSize:25.f];
    m_slBrightness.minimumValue = 0.6000f;
    m_slBrightness.maximumValue = 1.f;
    m_slBrightness.value = 1.f;
    [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:1.f]]];
    [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:0.6f]]];
    
    m_slTextTransparency.labelAboveThumb.font = [UIFont boldSystemFontOfSize:25.f];
    m_slTextTransparency.minimumValue = 0.0000f;
    m_slTextTransparency.maximumValue = 1.f;
    m_slTextTransparency.value = 1.f;
    
    mImageSize = m_cmImage.frame.size;
    m_pScaleLvlActive = [UIImage imageNamed:@"1-active.png"];
    m_pScaleLvlInactive = [UIImage imageNamed:@"2.png"];
    [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch_active.png"] forState:UIControlStateNormal];
    [m_btnShare setUserInteractionEnabled:NO];
    [m_btnShare setHighlighted:YES];
    fontArray = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fontList" ofType:@"plist"]];
    m_textArray = [[NSMutableArray alloc] init];
    m_curTextDic = [[NSDictionary alloc] init];
    m_textControlPanel.hidden = YES;
    m_textView.hidden = YES;
    m_cmImage.userInteractionEnabled = YES;
    m_oldFontIndexPath = [[NSIndexPath alloc] init];
    [m_txtDeleteBtn setHidden:YES];
    
     [m_indiFont setHidden:YES];
     [m_indiRotate setHidden:YES];
     [m_indiBrightness setHidden:YES];
     [m_indiColorPicker setHidden:YES];
     [m_indiDone setHidden:YES];
    
}

#pragma mark inherits methods

- (void) initCollageController {
    mCollageController = [[GSCollageController alloc] initWithFrame:CGRectMake(0.0,[[UIScreen mainScreen] bounds].size.height, self.view.frame.size.width, 66)];
    m_colorPickerBack.frame = mCollageController.frame;
    [m_sliderView setFrame:CGRectMake(0, mBottomView.frame.origin.y, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
    [m_txtSliderView setFrame:CGRectMake(0, mBottomView.frame.origin.y, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
    [mCollageController setAutoresizingMask:0];
    [mCollageController setDelegate:self];
    [mCollageController loadtemplates_Square];
    [self.view insertSubview:mCollageController belowSubview:bottomView];
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
    
}

#pragma mark - GSCollageController delegate
- (CGSize) GSCollageControllerDelegateTemplateSize {
    return CGSizeMake(52.0f, 52.0f);
}

- (UIImage*) GSCollageControllerDelegateImageForTemplate:(NSUInteger)pIndex {

        return [UIImage imageNamed:[NSString stringWithFormat:@"square_%i.png", pIndex]];
}

- (UIImage*) GSCollageControllerDelegateImageForActiveTemplate:(NSUInteger)pIndex {

    [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch.png"] forState:UIControlStateNormal];
    [blackSwatchButton setImage:[UIImage imageNamed:@"black-swatch.png"] forState:UIControlStateNormal];
    if(isPhoto)
    {
        [m_bgColor setImage:[UIImage imageNamed:[NSString stringWithFormat:@"square_active_%i.png", pIndex]] forState:UIControlStateNormal];
    }
    else
    {
        [m_textColorBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"square_active_%i.png", pIndex]] forState:UIControlStateNormal];
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"square_active_%i.png", pIndex]];
    
    
}

- (void) GSCollageControllerDelegateSelectedSquareBackground:(NSInteger)pIndex
{
    if(isPhoto)
    {
            [m_slBrightness setValue:1.f];
            NSString *one = [m_squareColorArray objectAtIndex:pIndex-1];
            NSArray *color = [one componentsSeparatedByString:@","];
            r = ((NSString *)[color objectAtIndex:0]).floatValue/255.f;
            g = ((NSString *)[color objectAtIndex:1]).floatValue/255.f;
            b = ((NSString *)[color objectAtIndex:2]).floatValue/255.f;
        
            cmBgColor = [UIColor colorWithRed:r green:g blue:b alpha:m_slBrightness.value];
        
        [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:1.f]]];
        [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:0.6f]]];
        
        if(!isFirst)
        {
            [self.m_workView setBackgroundColor:cmBgColor];
        }
    }
    else
    {
        [m_slTextTransparency setValue:1.f];
        NSString *one = [m_squareColorArray objectAtIndex:pIndex-1];
        NSArray *color = [one componentsSeparatedByString:@","];
        tr = ((NSString *)[color objectAtIndex:0]).floatValue/255.f;
        tg = ((NSString *)[color objectAtIndex:1]).floatValue/255.f;
        tb = ((NSString *)[color objectAtIndex:2]).floatValue/255.f;
        
        //[m_slTextTransparency._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f]]];
        [m_slTextTransparency._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:1.f]]];
        textColor = [UIColor colorWithRed:tr green:tg blue:tb alpha:m_slBrightness.value];
        if(isFixText)[self createTextView:m_textView.text:m_currentFont:textColor:m_fsize:nTextRotateCnt];
        [m_transparencyBtn setTitle:@"100%" forState:UIControlStateNormal];
    }
}

- (UIImage *) getImageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark gesture recognizer collback
- (void) tapGestureRecognizer:(UITapGestureRecognizer*)pTapGesureRecognizer {
    if(isFirst)
    {
        if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
            PhotoPickerViewController *lPhotoController = [[PhotoPickerViewController alloc] init];
            [lPhotoController setDelegate:self];
            [lPhotoController setIsMultipleSelectionEnabled:YES];
            [self presentModalViewController:lPhotoController animated:YES];
        }else{
            if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
                [self openCameraRoll];
            }else{
                [self showiOS5Alert];
            }
            
        }
    }
    if(isText)
    {
        [m_textView resignFirstResponder];
        [self slideWithKeyboard];
    }
}

- (void) panGestureRecognizer:(UIPanGestureRecognizer*)pPanGesureRecognizer {
    if(isPhoto)
    {
        if(!isFixed)
        {
            CGPoint lTransitionInView = [pPanGesureRecognizer translationInView:m_workView];
            
            if ([pPanGesureRecognizer state] == UIGestureRecognizerStateBegan){
                [self setTransition:lTransitionInView];
            } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateChanged){
                [self setTransition:lTransitionInView];
            } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateEnded){
                [self setTransition:lTransitionInView];
            }
            
            [pPanGesureRecognizer setTranslation:CGPointZero inView:m_workView];
        }
    }
    
}

- (void) pinchGestureRecognizer:(UIPinchGestureRecognizer*)pPinchGesureRecognizer
{
    if(isPhoto)
    {
        if(!isFixed)
        {
            if (pPinchGesureRecognizer.numberOfTouches != 2) {
                [pPinchGesureRecognizer setEnabled:NO];
                [self updatePositionsWithVelocity:CGPointMake(0.0, 0.0)];
                [pPinchGesureRecognizer setEnabled:YES];
            }
            
            CGPoint lLocationInView = [pPinchGesureRecognizer locationInView:m_cmImage];
            
            if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateBegan)
            {
                [self setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
            } else if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateChanged){
                [self setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
            } else if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateEnded) {
                [self setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
                 mImageSize = m_cmImage.frame.size;
            }
        }
    }
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer*)pLongPressGestureRecognizer{
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];

}


#pragma mark - documentInteractionController delegate
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
//    [self showAds];
}


#pragma mark - buttons Methods

- (IBAction) donePressed {
    [self.navigationController popViewControllerAnimated:YES];
    [Flurry endTimedEvent:@"instagramCollagePressed" withParameters:nil];
}

- (void) shareImage:(id)sender
{
    if(isText)[m_textView resignFirstResponder];
    UIActionSheet *lActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Open in Instagram", nil];
	lActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[lActionSheet showInView:self.view];
    [Flurry logEvent:@"exportPressed"];
    
}

- (IBAction) helpPressed:(id)pSender {
//    [super helpPressed:pSender];
}


- (IBAction)showHideColorPicker:(id)sender
{
        if (isShowColorPicker) {
            [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [mCollageController setFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
                [m_colorPickerBack setFrame:mCollageController.frame];
                [m_sliderView setFrame:CGRectMake(0.0f, mBottomView.frame.origin.y, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
                
            } completion:^(BOOL finished) {
                [mCollageController setHidden:YES];
            }];
        } else {
            [mCollageController setHidden:NO];
            [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [mCollageController setFrame:CGRectMake(0.0, mBottomView.frame.origin.y - mCollageController.frame.size.height, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
                [m_colorPickerBack setFrame:mCollageController.frame];
                [m_sliderView setFrame:CGRectMake(0.0f, mBottomView.frame.origin.y - COLLAGE_CONTROLLER_HEIGHT - SLIDERVIEW_HEIGHT, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
            } completion:^(BOOL finished) {
                
            }];
        }
        
        isShowColorPicker = !isShowColorPicker;
        [m_bgColor setSelected:isShowColorPicker];
    
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

    
}
- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{


}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}

- (void)openCameraRoll{
    UIImagePickerController *lPicker = [[UIImagePickerController alloc] init];
    lPicker.delegate = self;
    lPicker.allowsEditing = YES;
    lPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:lPicker animated:YES];
}

#pragma mark - iOS5 alert
- (void)showiOS5Alert{
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:IOS5_ALERT_TITLE_TEXT message:IOS5_ALERT_DESCRIPTION delegate:nil cancelButtonTitle:IOS5_ALERT_SUCCESS_BUTTON otherButtonTitles:IOS5_ALERT_DONT_REMIND_BUTTON, nil];
    lAlertView.delegate = self;
    lAlertView.tag = 4;
    [lAlertView show];
}
#pragma mark - PhotoPickerPlusDelegate
- (void)photoImagePickerControllerDidCancel:(PhotoPickerViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self checkCollageIsEmpty];
}

- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    outputImage = [outputImage getScaledImageFromHQ];
    
    m_cmRect = [self getImageRect:outputImage.size.width height:outputImage.size.height];
    m_originalRect = m_cmRect;
    m_cmImage.frame = m_cmRect;
    mImageSize = m_cmRect.size;


    isFirst = NO;
    [m_btnShare setHighlighted:NO];
    [m_workView setImage:nil];
    [backgroundView setHidden:YES];
    [m_workView setBackgroundColor:cmBgColor];
    [m_cmImage setImage:outputImage];
    [m_btnShare setUserInteractionEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

- (CGRect) getImageRect:(float)w height:(float) h
{
    float ratio = w/h;
    float real_ratio;
    float height;
    float width;
    float orign_x;
    float orign_y;
    CGRect imgRect;
    
    if([UIScreen mainScreen].bounds.size.height == 568)
    {
        if(ratio >= RATIO_IPHONE5)
        {
            real_ratio = PHOTO_WIDTH / w;
            height = h *real_ratio;
            orign_x = 0;
            orign_y = (PHOTO_HEIGHT_IPHONE5 - height) / 2.f;
            imgRect = CGRectMake(orign_x, orign_y, 320, height);
            return imgRect;
        }
        else
        {
            real_ratio = PHOTO_HEIGHT_IPHONE5 / h;
            width = w *real_ratio;
            height = PHOTO_HEIGHT_IPHONE5;
            orign_x = (PHOTO_WIDTH - width) / 2.f;
            orign_y = 0.f;
            imgRect = CGRectMake(orign_x, orign_y, width, height);
            return imgRect;
        }
    }
    else
    {
        if(ratio >= RATIO_IPHONE4)
        {
            real_ratio = PHOTO_WIDTH / w;
            height = h *real_ratio;
            orign_x = 0;
            orign_y = (PHOTO_HEIGHT_IPHONE4 - height) / 2.f;
            imgRect = CGRectMake(orign_x, orign_y, 320, height);
            return imgRect;
        }
        else
        {
            real_ratio = PHOTO_HEIGHT_IPHONE4 / h;
            width = w *real_ratio;
            height = PHOTO_HEIGHT_IPHONE4;
            orign_x = (PHOTO_WIDTH - width) / 2.f;
            orign_y = 0.f;
            imgRect = CGRectMake(orign_x, orign_y, width, height);
            return imgRect;
        }
    }
 
}

-  (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info {
    DLog(@"info count - %i", [info count]);
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([info count] > 0) {
       [self setImageWithArrayInfo:info];
    }
}

- (void)setImageWithArrayInfo:(NSArray *)pArray{
    outputImage = [[pArray objectAtIndex:0] objectForKey:UIImagePickerControllerOriginalImage];
    DLog(@"outputImage.imageOrientation - %i", outputImage.imageOrientation);
    m_cmRect = [self getImageRect:outputImage.size.width height:outputImage.size.height];
    m_originalRect = m_cmRect;
    m_cmImage.frame = m_cmRect;
    mImageSize = m_cmRect.size;
    
    isFirst = NO;
    [m_btnShare setHighlighted:NO];
    [m_workView setImage:nil];
    [backgroundView setHidden:YES];
    [m_workView setBackgroundColor:cmBgColor];
    [m_cmImage setImage:outputImage];
    [m_btnShare setUserInteractionEnabled:YES];
}

- (IBAction)rotatePicture:(id)sender
{
        m_nRotateCnt ++;
        m_cmImage.transform = CGAffineTransformMakeRotation(90*m_nRotateCnt*M_PI/180);
        if(m_nRotateCnt == 4)m_nRotateCnt = 0;
        m_cmRect = m_cmImage.frame;
        mImageSize = m_cmImage.frame.size;
}

- (IBAction)showHelp:(id)sender
{
    NSLog(@"------------show help---------");
    
}

- (IBAction)blackSwatch:(id)sender
{
   
     [mCollageController loadtemplates_Square];
    if(isPhoto)
    {
            r = 0.f; g = 0.f; b = 0.f;
             [m_bgColor setImage:[UIImage imageNamed:@"square_active_20.png"] forState:UIControlStateNormal];
            
            [blackSwatchButton setImage:[UIImage imageNamed:@"black-swatch_active.png"] forState:UIControlStateNormal];
            [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch.png"] forState:UIControlStateNormal];
            [m_slBrightness setValue:1.f];
            [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:1.f]]];
            [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:0.6f]]];
        cmBgColor = [UIColor colorWithRed:r green:g blue:b alpha:1.f];
        if(!isFirst)
        {
            [m_workView setBackgroundColor:cmBgColor];
        }
    }
    else
    {
        [m_textColorBtn setImage:[UIImage imageNamed:@"square_active_20.png"] forState:UIControlStateNormal];
        [blackSwatchButton setImage:[UIImage imageNamed:@"black-swatch_active.png"] forState:UIControlStateNormal];
        [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch.png"] forState:UIControlStateNormal];
        [m_slBrightness setValue:1.f];
        tr=0.f; tg = 0.f; tb = 0.f;
        [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:1.f]]];
        [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:0.6f]]];
        textColor = [UIColor colorWithRed:tr green:tg blue:tb alpha:m_slBrightness.value];
    }
    
}
- (IBAction)whiteSwatch:(id)sender
{
    
    [mCollageController loadtemplates_Square];
    if(isPhoto)
    {
            r=1.f; g = 1.f; b = 1.f;
            [m_bgColor setImage:[UIImage imageNamed:@"square_active_0.png"] forState:UIControlStateNormal];
            [blackSwatchButton setImage:[UIImage imageNamed:@"black-swatch.png"] forState:UIControlStateNormal];
            [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch_active.png"] forState:UIControlStateNormal];
            [m_slBrightness setValue:1.f];
            [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:1.f]]];
            [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:0.6f]]];
        cmBgColor = [UIColor colorWithRed:r green:g blue:b alpha:1.f];
        
        if(!isFirst)
        {
            [m_workView setBackgroundColor:cmBgColor];

        }
    }
    else
    {
        tr=1.f; tg = 1.f; tb = 1.f;
        [m_textColorBtn setImage:[UIImage imageNamed:@"square_active_0.png"] forState:UIControlStateNormal];
        [blackSwatchButton setImage:[UIImage imageNamed:@"black-swatch.png"] forState:UIControlStateNormal];
        [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch_active.png"] forState:UIControlStateNormal];
        [m_slBrightness setValue:1.f];
        [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:1.f]]];
        [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:tr green:tg blue:tb alpha:0.6f]]];
        textColor = [UIColor colorWithRed:tr green:tg blue:tb alpha:m_slBrightness.value];
        //[m_textView setTextColor:textColor];
    }
}

- (CGRect) scaleRect:(int) scaleLvl
{
    float origin_x, origin_y, width, height;
    float scale_ratio;
    CGRect scaleRect;
    origin_x = m_originalRect.origin.x + OFFSET_SCALE_LVL*scaleLvl / 2.f;
    width = m_originalRect.size.width -OFFSET_SCALE_LVL * scaleLvl;
    scale_ratio = width / m_originalRect.size.width;
    height = m_originalRect.size.height * scale_ratio;
    origin_y = m_originalRect.origin.y + (m_originalRect.size.height - height) / 2.f;
    scaleRect = CGRectMake(origin_x, origin_y, width, height);
    return scaleRect;
}

-(IBAction)fixScaling:(id)sender
{
    m_nScaleLvl++;
    if(m_nScaleLvl == 1) [m_btnScaleLvl1 setImage:m_pScaleLvlActive];
    if(m_nScaleLvl == 2) [m_btnScaleLvl2 setImage:m_pScaleLvlActive];
    if(m_nScaleLvl == 3) [m_btnScaleLvl3 setImage:m_pScaleLvlActive];
    if(m_nScaleLvl == 4)
    {
        m_nScaleLvl = 0;
        m_cmImage.frame = m_originalRect;
      [m_btnScaleLvl1 setImage:m_pScaleLvlInactive];
      [m_btnScaleLvl2 setImage:m_pScaleLvlInactive];
      [m_btnScaleLvl3 setImage:m_pScaleLvlInactive];
        
    }
    
//    CGRect newFrame = CGRectInset(m_originalRect, OFFSET_SCALE_LVL*m_nScaleLvl, OFFSET_SCALE_LVL*m_nScaleLvl);
    CGRect newFrame = [self scaleRect:m_nScaleLvl];
    switch(m_nRotateCnt)
    {
        case 0:
            break;
        case 1:
            m_cmImage.transform = CGAffineTransformMakeRotation(90*4*M_PI/180);
            m_nRotateCnt = 0;
            break;
        case 2:
            m_cmImage.transform = CGAffineTransformMakeRotation(90*4*M_PI/180);
            m_nRotateCnt = 0;
            break;
        case 3:
            m_cmImage.transform = CGAffineTransformMakeRotation(90*4*M_PI/180);
            m_nRotateCnt = 0;
            break;
    }
    m_cmImage.frame = newFrame;
    mImageSize = newFrame.size;
}

- (IBAction)FixImage:(id)sender
{
    isFixed = !isFixed;
    if(isFixed)
    {
       [m_btnFixed setBackgroundImage:[UIImage imageNamed:@"fix_active.png"] forState:UIControlStateNormal];
    }
    else
    {
        [m_btnFixed setBackgroundImage:[UIImage imageNamed:@"fix_inactive.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)changedSlider:(CHYSlider *)slider
{
    if(isPhoto)
    {
        cmBgColor = [UIColor colorWithRed:r green:g blue:b alpha:m_slBrightness.value];
        if(!isFirst)
        {
          [m_workView setBackgroundColor:cmBgColor];
        }
    }
   
}

- (IBAction)changeTextSlider:(id)sender
{
    if(isFixText)
    {
        ((UIImageView *)[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW]).alpha = m_slTextTransparency.value;
    }
    textColor = [UIColor colorWithRed:tr green:tg blue:tb alpha:m_slTextTransparency.value];
    [m_transparencyBtn setTitle:[NSString stringWithFormat:@"%d %%",(int)(m_slTextTransparency.value * 100)] forState:UIControlStateNormal];
}
#pragma mark cmImage transitions========//
- (void) setTransition:(CGPoint)pPoint
{
    
    CGFloat newOrign_x = m_cmImage.frame.origin.x + pPoint.x;
    CGFloat newOrign_y = m_cmImage.frame.origin.y + pPoint.y;
    m_cmImage.frame = CGRectMake(newOrign_x, newOrign_y, m_cmImage.frame.size.width, m_cmImage.frame.size.height);
}

- (IBAction) backPressed {
    [super backPressed];
    [Flurry endTimedEvent:@"instagramCollagePressed" withParameters:nil];
}



- (IBAction)resetImage:(id)sender
{
    [mCollageController loadtemplates_Square];
    m_cmImage.frame = m_originalPortraitRect;
    m_cmImage.image = nil;
    isFirst = YES;
    [m_bgColor setImage:[UIImage imageNamed:@"square_active_0.png"] forState:UIControlStateNormal];
    [blackSwatchButton setImage:[UIImage imageNamed:@"black-swatch.png"] forState:UIControlStateNormal];
    [whiteSwatchButton setImage:[UIImage imageNamed:@"white-swatch_active.png"] forState:UIControlStateNormal];
    [m_slBrightness setValue:1.f];
    r = 1.f; g = 1.f; b = 1.f;
    [m_slBrightness._trackImageViewNormal setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:1.f]]];
    [m_slBrightness._trackImageViewHighlighted setImage:[self getImageFromColor:[UIColor colorWithRed:r green:g blue:b alpha:0.6f]]];
    cmBgColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    [backgroundView setHidden:NO];
    [m_textView setText:@""];
    [m_slTextTransparency setValue:1.f];
    isPhoto = YES;
    isFixText = NO;
    isText = NO;
    
    m_nScaleLvl = 0;
    [m_btnScaleLvl1 setImage:m_pScaleLvlInactive];
    [m_btnScaleLvl2 setImage:m_pScaleLvlInactive];
    [m_btnScaleLvl3 setImage:m_pScaleLvlInactive];
    
    for(int i = 0; i<m_textArray.count; i++)
    {
        [[[m_textArray objectAtIndex:i] objectForKey:KEY_VIEW] removeFromSuperview];
    }
    [m_textArray removeAllObjects];
    
    isFixed = NO;
    [m_btnFixed setBackgroundImage:[UIImage imageNamed:@"fix_inactive.png"] forState:UIControlStateNormal];

    [m_workView setBackgroundColor:[UIColor clearColor]];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        [m_workView setImage:[UIImage imageNamed:@"guide_iPhone5.png"]];
    }
    else
    {
        [m_workView setImage:[UIImage imageNamed:@"guide_iPhone4.png"]];
    }
}



- (void) updatePositionsWithVelocity:(CGPoint)pVelocity {
    
    mScale = m_cmImage.frame.size.width/mImageSize.width;
    
    if (mScale < mMinScale) {
        mScale = mMinScale;
        
    } else if (mScale > mMaxScale) {
        mScale = mMaxScale;
    }
    
    
    CGSize lNewImageSize = CGSizeMake(mImageSize.width * mScale, mImageSize.height * mScale);
    CGPoint lImageSizeDiff = CGPointMake(mLastAnchorPoint.x - m_cmImage.frame.origin.x, mLastAnchorPoint.y - m_cmImage.frame.origin.y);
    
    CGFloat lXKoeficient = (m_cmImage.frame.size.width - lNewImageSize.width) / m_cmImage.frame.size.width;
    CGFloat lYKoeficient = (m_cmImage.frame.size.height - lNewImageSize.height) / m_cmImage.frame.size.height;
    
    CGRect lImageFrame = CGRectMake(m_cmImage.frame.origin.x + lImageSizeDiff.x * lXKoeficient + pVelocity.x / 8.0, m_cmImage.frame.origin.y + lImageSizeDiff.y * lYKoeficient + pVelocity.y / 8.0, lNewImageSize.width, lNewImageSize.height);
    
    //calc position
    CGFloat lNewX = lImageFrame.origin.x;
    CGFloat lNewY = lImageFrame.origin.y;
    
    
    if (lImageFrame.origin.x > 0) {
        lNewX = m_cmRect.origin.x;
    } else {
        CGFloat lMinX = m_cmRect.size.width - lImageFrame.size.width + m_cmRect.origin.x;
        if (lImageFrame.origin.x < lMinX) {
            lNewX = lMinX;
        }
    }
    
    if (lImageFrame.origin.y > 0) {
        lNewY = m_cmRect.origin.y;

        
    } else {
        CGFloat lMinY = m_cmRect.size.height - lImageFrame.size.height + m_cmRect.origin.y;
        if (lImageFrame.origin.y < lMinY) {
            lNewY = lMinY;
        }
    }
    
    lImageFrame = CGRectMake(lNewX, lNewY, lImageFrame.size.width, lImageFrame.size.height);
    
}

#pragma mark pinch scale=============//
- (void) setPinchScale:(CGFloat)pPinchScale atPoint:(CGPoint)pAnchorPoint {
        mLastAnchorPoint = pAnchorPoint;
    
    float new_width = mImageSize.width * pPinchScale;
    float new_height = mImageSize.height * pPinchScale;

    CGPoint lImageSizeDiff = CGPointMake(pAnchorPoint.x - m_cmImage.frame.origin.x, pAnchorPoint.y - m_cmImage.frame.origin.y);
    CGPoint lAnchorOffset = CGPointMake(pAnchorPoint.x - mLastAnchorPoint.x, pAnchorPoint.y - mLastAnchorPoint.y);
    
    CGFloat lXKoeficient = (m_cmImage.frame.size.width - new_width) / m_cmImage.frame.size.width;
    CGFloat lYKoeficient = (m_cmImage.frame.size.height - new_height) / m_cmImage.frame.size.height;
    
    CGRect rt = CGRectMake(m_cmImage.frame.origin.x + lImageSizeDiff.x * lXKoeficient + lAnchorOffset.x, m_cmImage.frame.origin.y + lImageSizeDiff.y * lYKoeficient + lAnchorOffset.y, new_width, new_height);
    m_cmImage.frame = rt;
}

#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == LOAD_ACTION_SHEET_TAG) {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    } else {
        if (buttonIndex == 0) {
            [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self saveImage:[self getImageFromWorkView] toAlbum:ALBUM_NAME];
        } else if (buttonIndex == 1){
            NSURL *lInstagramURL = [NSURL URLWithString:@"instagram://app"];
            
            if ([[UIApplication sharedApplication] canOpenURL:lInstagramURL]) {
                [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                NSString *lImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempImage.igo"];
                [UIImageJPEGRepresentation([self getImageFromWorkView], 1.0) writeToFile:lImagePath atomically:YES];
                
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

- (UIImage *) getImageFromWorkView
{
    UIGraphicsBeginImageContext(self.m_workView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [m_workView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
#pragma ADD TEXT--------------------//
- (IBAction)addText:(id)sender
{
    if(!isFirst)
    {
        [self initializeTextView];
        if(isText)
        {
             [m_textView resignFirstResponder];
        }
        else
        {
            [m_textView becomeFirstResponder];
        }
        m_textView.editable = YES;
    }
}


- (void) initializeTextView
{
    isPhoto = NO;
    if(!isFixText)
    {
        [self blackSwatch:nil];
        [m_slTextTransparency setValue:1.f];
        [m_transparencyBtn setTitle:@"100%" forState:UIControlStateNormal];
        nTextRotateCnt = 0;
    }
}
- (IBAction)fontBtnClicked:(id)sender
{
    [self setActiveIndicator:1];
    if(isTransparency) [self txtBrightnessSlideDown];
    if(isColorPicker)  [self txtColorPickerSlideDown];
    if(isFont)//hide
    {
        [self txtFontPanelSlideRight];
    }

    else
    {
        [self txtFontPanelSlideLeft];
    }

}
- (IBAction)transparencyBtnClicked:(id)sender
{
    if(isFont) [self txtFontPanelSlideRight];
    [self setActiveIndicator:3];
    if (isTransparency)
    {
        [self txtBrightnessSlideDown];
    }
    else
    {
        [self txtBrightnessSlideUp];
    }
}

- (void) txtColorPickerSlideUp
{
    [mCollageController setHidden:NO];
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if(isTransparency) [self txtBrightnessSlideDown];

            [mCollageController setFrame:CGRectMake(0.0, mBottomView.frame.origin.y - HEIGHT_TEXTVIEW - COLLAGE_CONTROLLER_HEIGHT, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
            [m_colorPickerBack setFrame:mCollageController.frame];

    } completion:^(BOOL finished) {
        
    }];
    isColorPicker = YES;
}

- (void) txtColorPickerSlideDown
{
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [mCollageController setFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
        [m_colorPickerBack setFrame:mCollageController.frame];
        
    } completion:^(BOOL finished) {
        [mCollageController setHidden:YES];
    }];
    isColorPicker = NO;
}

- (void) txtBrightnessSlideUp
{
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        if(isColorPicker) [self txtColorPickerSlideDown];
        [m_txtSliderView setFrame:CGRectMake(0.0f, mBottomView.frame.origin.y - HEIGHT_TEXTVIEW - SLIDERVIEW_HEIGHT, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
    } completion:^(BOOL finished) {
        
    }];
    isTransparency = YES;
}

- (void) txtBrightnessSlideDown
{
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [m_txtSliderView setFrame:CGRectMake(0.0f, mBottomView.frame.origin.y, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
        
    } completion:^(BOOL finished) {
    }];
    
    isTransparency = NO;
}


- (void) txtFontPanelSlideRight
{
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if(isPhone5)
        {
            [fontViewIamge setFrame:FONTVIEW_FRAME_HIDE5];
            [m_fontPanel setFrame:FONTVIEW_FRAME_HIDE5];
        }
        else
        {
            [fontViewIamge setFrame:FONTVIEW_FRAME_HIDE4];
            [m_fontPanel setFrame:FONTVIEW_FRAME_HIDE4];
        }
    } completion:^(BOOL finished) {
        
    }];
    
    isFont = NO;
}

- (void) txtFontPanelSlideLeft
{
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        if(isPhone5)
        {
            [fontViewIamge setFrame:FONTVIEW_FRAME_SHOW5];
            [m_fontPanel setFrame:FONTVIEW_FRAME_SHOW5];
        }
        else
        {
            [fontViewIamge setFrame:FONTVIEW_FRAME_SHOW4];
            [m_fontPanel setFrame:FONTVIEW_FRAME_SHOW4];
        }
    } completion:^(BOOL finished) {
        
    }];
    isFont = YES;
}

- (IBAction)colorPickerBtnClicked:(id)sender
{
    if(isFont) [self txtFontPanelSlideRight];
    [self setActiveIndicator:4];
    if (isColorPicker)
    {
        [self txtColorPickerSlideDown];
    }
    else
    {
        [self txtColorPickerSlideUp];
    }
    
}

- (void) setActiveIndicator:(int) tag
{
    switch(tag)
    {
        case 1:
            [m_indiFont setHidden:NO];
            [m_indiRotate setHidden:YES];
            [m_indiBrightness setHidden:YES];
            [m_indiColorPicker setHidden:YES];
            break;
        case 2:
            [m_indiFont setHidden:YES];
            [m_indiRotate setHidden:NO];
            [m_indiBrightness setHidden:YES];
            [m_indiColorPicker setHidden:YES];
            break;
        case 3:
            [m_indiFont setHidden:YES];
            [m_indiRotate setHidden:YES];
            [m_indiBrightness setHidden:NO];
            [m_indiColorPicker setHidden:YES];
            break;
        case 4:
            [m_indiFont setHidden:YES];
            [m_indiRotate setHidden:YES];
            [m_indiBrightness setHidden:YES];
            [m_indiColorPicker setHidden:NO];
            break;
    }
}
- (IBAction)doneBtnClicked:(id)sender
{
    if(isFixText)
    {
        [self createTextView:m_textView.text:m_currentFont:textColor:m_fsize:nTextRotateCnt];
    }
    else
    {
        [self createTextView:m_textView.text:m_currentFont:textColor:m_fsize:0];
    }
    if(isFixText) isFixText = NO;
    [m_txtDeleteBtn setHidden:YES];
    [self endAddText];
}
- (void) createTextView:(NSString *)str : (NSString *)fontName : (UIColor *) tColor : (NSString *) fSize : (int) nRotateCnt;
{
    if(![str isEqualToString:@""])
    {
        NSString *currentText = str;
        UIImageView *tview = [[UIImageView alloc] init];
        [tview setBackgroundColor:[UIColor clearColor]];
        UILabel *tv = [[UILabel alloc] init];
        CGSize  tsize = [str sizeWithFont:[UIFont fontWithName:fontName size:20]];
        if(isFixText)
            
        {
            [tview setFrame:CGRectMake(m_tmpFrame.origin.x, m_tmpFrame.origin.y, tsize.width, tsize.height)];
        }
        else
        {
            
            [tview setFrame:CGRectMake(0.f, 0.f, tsize.width, tsize.height)];
        }
        
        [tv setFrame:CGRectMake(0.f, 0.f, tsize.width, tsize.height)];
        [tv setBackgroundColor:[UIColor clearColor]];
        [tv setTextAlignment:NSTextAlignmentLeft];
        
        [tv setUserInteractionEnabled:NO];
        [tv setFont:[UIFont fontWithName:fontName size:20]];
        [tv setTextColor:tColor];
        [tv setText:currentText];
        [tv setTag:[m_textArray count]];
        
        UIGraphicsBeginImageContext(tv.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [tv.layer renderInContext: context];
        UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [tview setImage:textImage];
        //[tview addSubview:tv];
        [tview setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [tview addGestureRecognizer:doubleTap];
        if(isFixText)
        {
            tview.tag = tmpTag;
        }
        else
        {
            tview.tag = vTag;
        }
         NSString *rotateStr = [NSString stringWithFormat:@"%d",nRotateCnt];
        
        UIPanGestureRecognizer *lPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textPanGesture:)];
        [lPanRecognizer setMinimumNumberOfTouches:1];
        [tview addGestureRecognizer:lPanRecognizer];
        
        UILongPressGestureRecognizer *lLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textLongPressGesture:)];
        lLongPressRecognizer.minimumPressDuration = 3.0;
        lLongPressRecognizer.delaysTouchesEnded = YES;
        lLongPressRecognizer.delegate = self;
        [tview addGestureRecognizer:lLongPressRecognizer];
      
        UIPinchGestureRecognizer *textPinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(textPinchGesture:)];
        [tview addGestureRecognizer:textPinchGesture];
        NSDictionary *td = [[NSDictionary alloc] initWithObjectsAndKeys:tv,KEY_TEXT, tview, KEY_VIEW, str, KEY_STR, fontName, KEY_FONT, tColor, KEY_COLOR, fSize, KEY_FSIZE, rotateStr, KEY_ROTATE, nil];
       
        
        if(isFixText)
        {
            [[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW] removeFromSuperview];
            [m_textArray replaceObjectAtIndex:tmpTag withObject:td];

            [m_workView addSubview:tview];
            tview.transform = CGAffineTransformMakeRotation(90*nTextRotateCnt*M_PI/180);
            CGRect viewFrame = ((UIImageView *)[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW]).frame;
            CGRect rt = CGRectMake(viewFrame.origin.x + viewFrame.size.width, viewFrame.origin.y - m_txtDeleteBtn.frame.size.height, m_txtDeleteBtn.frame.size.width, m_txtDeleteBtn.frame.size.width);
            [m_txtDeleteBtn setFrame:rt];

            
        }
        else
        {
            [m_workView addSubview:tview];
            [m_textArray addObject:td];
            vTag ++;
        }
    }
}

//====================gesture recognizer delegate============================//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) textPinchGesture:(UIPinchGestureRecognizer *) pin
{
    if(!isFixText)
    {
        CGPoint lLocationInView = [pin locationInView:[(UIGestureRecognizer *)pin view]];
        if ([pin state] == UIGestureRecognizerStateBegan)
        {
            m_txtPinchSize = [(UIGestureRecognizer *)pin view].frame.size;
            [self setTextPinchScale:pin.scale atPoint:lLocationInView target:pin];
        } else if ([pin state] == UIGestureRecognizerStateChanged){

            [self setTextPinchScale:pin.scale atPoint:lLocationInView target:pin];
        } else if ([pin state] == UIGestureRecognizerStateEnded) {
            [self setTextPinchScale:pin.scale atPoint:lLocationInView target:pin];
            m_txtPinchSize = [(UIGestureRecognizer *)pin view].frame.size;
        }
    }
}

- (void) setTextPinchScale:(CGFloat)pPinchScale atPoint:(CGPoint)pAnchorPoint target:(UIPinchGestureRecognizer *)pin
{
    mLastAnchorPoint = pAnchorPoint;
    
    float new_width = m_txtPinchSize.width * pPinchScale;
    float new_height = m_txtPinchSize.height * pPinchScale;
    
    CGPoint lImageSizeDiff = CGPointMake(pAnchorPoint.x - m_cmImage.frame.origin.x, pAnchorPoint.y - m_cmImage.frame.origin.y);
    CGPoint lAnchorOffset = CGPointMake(pAnchorPoint.x - mLastAnchorPoint.x, pAnchorPoint.y - mLastAnchorPoint.y);
    
    CGFloat lXKoeficient = ([(UIGestureRecognizer *)pin view].frame.size.width - new_width) / [(UIGestureRecognizer *)pin view].frame.size.width;
    CGFloat lYKoeficient = ([(UIGestureRecognizer *)pin view].frame.size.height - new_height) / [(UIGestureRecognizer *)pin view].frame.size.height;
    
    CGRect rt = CGRectMake([(UIGestureRecognizer *)pin view].frame.origin.x + lImageSizeDiff.x * lXKoeficient + lAnchorOffset.x, [(UIGestureRecognizer *)pin view].frame.origin.y + lImageSizeDiff.y * lYKoeficient + lAnchorOffset.y, new_width, new_height);
    
    [[(UIGestureRecognizer *)pin view] setFrame:rt];
}


- (void) textDoubleTap:(UITapGestureRecognizer*)pTapGesureRecognizer
{
    isFixText = YES;
    isPhoto = NO;
    int tag = [(UIGestureRecognizer *)pTapGesureRecognizer view].tag;
    m_tmpFrame = [(UIGestureRecognizer *)pTapGesureRecognizer view].frame;
    tmpTag = tag;
    [m_textView becomeFirstResponder];
    NSString *str = [[m_textArray objectAtIndex:tag] objectForKey:KEY_STR];
    textColor = [[m_textArray objectAtIndex:tag] objectForKey:KEY_COLOR];
    m_currentFont = [[m_textArray objectAtIndex:tag] objectForKey:KEY_FONT];
    m_curTextView = [[m_textArray objectAtIndex:tag] objectForKey:KEY_VIEW];
    m_fsize = [[m_textArray objectAtIndex:tag] objectForKey:KEY_FSIZE];
    nTextRotateCnt = ((NSString *)[[m_textArray objectAtIndex:tag] objectForKey:KEY_ROTATE]).intValue;
    [m_textView setText:str];
    [m_textView setFont:[UIFont fontWithName:m_currentFont size:20]];
    [m_txtDeleteBtn setHidden:NO];
    CGRect rt = CGRectMake(m_curTextView.frame.origin.x + m_curTextView.frame.size.width, m_curTextView.frame.origin.y - m_txtDeleteBtn.frame.size.height, m_txtDeleteBtn.frame.size.width, m_txtDeleteBtn.frame.size.width);
    [m_txtDeleteBtn setFrame:rt];
    
}

- (void) textPanGesture:(UIPanGestureRecognizer*)pPanGesureRecognizer
{
    if(!isFixText)
    {
        CGPoint lTransitionInView = [pPanGesureRecognizer translationInView:m_workView];
        
        if ([pPanGesureRecognizer state] == UIGestureRecognizerStateBegan){
            [self setTransitionText:lTransitionInView];
        } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateChanged){
            [self setTransitionText:lTransitionInView];
        } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateEnded){
            [self setTransitionText:lTransitionInView];
        }
        [pPanGesureRecognizer setTranslation:CGPointZero inView:m_workView];
    }
}

- (void) setTransitionText:(CGPoint)pPoint

{
    
    CGFloat newOrign_x = m_curTextView.frame.origin.x + pPoint.x;
    CGFloat newOrign_y = m_curTextView.frame.origin.y + pPoint.y;
    m_curTextView.frame = CGRectMake(newOrign_x, newOrign_y, m_curTextView.frame.size.width, m_curTextView.frame.size.height);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int index = 0;
    m_curTextView = nil;
    m_curTextDic = nil;
	UITouch *touch = [touches anyObject];
	if ([touch tapCount] == 2) {
		return;
	}
	CGPoint lastPoint = [touch locationInView:m_workView];
    for(NSDictionary *d in m_textArray)
    {
        UIImageView *v = [d objectForKey:KEY_VIEW];
        
        if(CGRectContainsPoint(v.frame,lastPoint))
        {
            m_curTextView = v;
            m_curTextDic = d;
        }
        index++;
    }
    CGRect rt;
    if([UIScreen mainScreen].bounds.size.width == 568)
    {
        rt = CGRectMake(0, 0, 160, 568);
    }
    else
    {
        rt = CGRectMake(0, 0, 160, 480);

    }
    
    if(CGRectContainsPoint(rt, lastPoint) && isFont) [self txtFontPanelSlideRight];
}

- (IBAction)rotateText:(id)sender
{
    if(isFont)[self txtFontPanelSlideRight];
    [self setActiveIndicator:2];
    nTextRotateCnt ++;
    if(isFixText)
    {
        ((UIImageView *)[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW]).transform = CGAffineTransformMakeRotation(90*nTextRotateCnt*M_PI/180);
        CGRect viewFrame = ((UIImageView *)[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW]).frame;
        CGRect rt = CGRectMake(viewFrame.origin.x + viewFrame.size.width, viewFrame.origin.y - m_txtDeleteBtn.frame.size.height, m_txtDeleteBtn.frame.size.width, m_txtDeleteBtn.frame.size.width);
        [m_txtDeleteBtn setFrame:rt];

    }
    if(nTextRotateCnt == 4)nTextRotateCnt = 0;
   
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"---------------touch moved---------------");
}

- (void) textLongPressGesture:(UILongPressGestureRecognizer*)pLongPressGesureRecognizer
{
    NSLog(@"---------text long press gesture---------------");
    if([pLongPressGesureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        NSString *str = [m_curTextDic objectForKey:KEY_STR];
        UIColor *color = [[UIColor alloc] init];
        color = [m_curTextDic objectForKey:KEY_COLOR];
        NSString *fontName = [m_curTextDic objectForKey:KEY_FONT];
        NSString *fsize = [m_curTextDic objectForKey:KEY_FSIZE];
        [self createTextView:str :fontName :color:fsize:0];
    }
    
}

- (void) endAddText
{
    //initialize...-------------------//
    
    isPhoto = YES;
    m_textControlPanel.hidden = YES;
    [m_textView setText:@""];
    m_textView.hidden = YES;
    [m_textView setFont:[UIFont fontWithName:@"Arial" size:20]];
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [mCollageController setFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, COLLAGE_CONTROLLER_HEIGHT)];
        [m_colorPickerBack setFrame:mCollageController.frame];
        [m_txtSliderView setFrame:CGRectMake(0.0f, mBottomView.frame.origin.y, self.view.frame.size.width, SLIDERVIEW_HEIGHT)];
        
    } completion:^(BOOL finished) {
        [mCollageController setHidden:YES];
    }];

    
}
#pragma textview touch--------------//

#pragma TEXT VIEW DELEGARES---------//


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"------------UITextView did begin editing------------");
    [self slideWithKeyboard];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"------------UITextView did end editing------------");
    [self slideWithKeyboard];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
}
- (void)textViewDidChange:(UITextView *)textView
{
    
}
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
}
#pragma UITableViewDelegate--------//
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 43;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"GSCustomCell" owner:self options:nil];
    GSCustomCell *cell = [nibArray objectAtIndex:0];
    
    cell.backgroundColor = [UIColor clearColor];
    m_strFont = [[fontArray objectAtIndex:indexPath.row] objectForKey:@"str"];
    cell.m_textLabel.text = m_strFont;
    cell.m_textLabel.font = [UIFont fontWithName:m_strFont size:20];
#ifdef FREE
    if(indexPath.row < m_freeCountFont)
    {
        cell.m_textLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.m_textLabel.textColor = [UIColor grayColor];
    }
#else
    cell.m_textLabel.textColor = [UIColor whiteColor];
#endif
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *separatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"font-panel-divider.png"]];
    separatorView.frame = CGRectMake(0, 49, 160, 1);
    [cell.contentView addSubview:separatorView];
    return cell;

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef FREE
    if(indexPath.row < m_freeCountFont)
    {
        m_currentFont = [[fontArray objectAtIndex:indexPath.row] objectForKey:@"str"];
        [m_textView setFont:[UIFont fontWithName:m_currentFont size:20]];
        m_fsize = [[fontArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        if(isFixText) [self createTextView:m_textView.text:m_currentFont:textColor:m_fsize:nTextRotateCnt];
        
    }
    else
    {
        [self buyFont:indexPath.row];
    }
#else
    m_currentFont = [[fontArray objectAtIndex:indexPath.row] objectForKey:@"str"];
    [m_textView setFont:[UIFont fontWithName:m_currentFont size:20]];
    m_fsize = [[fontArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    if(isFixText) [self createTextView:m_textView.text:m_currentFont:textColor:m_fsize:nTextRotateCnt];
    [m_fontPanel reloadData];
    [((GSCustomCell *)[m_fontPanel cellForRowAtIndexPath:indexPath]).m_textLabel setTextColor:[UIColor blueColor]];
    
#endif
    
}

- (void) buyFont:(int)index
{
    if (m_buyFontView != nil) {
        [m_buyFontView removeFromSuperview];
        m_buyFontView = nil;
    }
    
    m_buyFontView = (GSBuyPopupView*)[[[NSBundle mainBundle] loadNibNamed:@"GSBuyPopupView" owner:nil options:nil] objectAtIndex:0];
    m_buyFontView.delegate = self;
    [self.view addSubview:m_buyFontView];
    
    [m_buyFontView startDisplaying];
}

#pragma mark - GSBuyPopupViewDelegate methods
- (void)GSBuyPopupViewDelegateAdsPressed{
    [m_buyFontView hideMessage];
    m_buyFontView = nil;
    
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_ADS_REMOVED]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    
    mPurchaseTag = GSPurchaseTypeAds;
    
}

- (void)GSBuyPopupViewDelegateWatermarkPressed{
    [m_buyFontView hideMessage];
    m_buyFontView = nil;
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_WATERMARK]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeWatermark;
}

- (void)GSBuyPopupViewDelegateFramesPressed{
    [m_buyFontView hideMessage];
    m_buyFontView = nil;
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_FRAMES]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeFrames;
}

- (void)GSBuypopupviewdelegateFontPressed{
    [m_buyFontView hideMessage];
    m_buyFontView = nil;
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_FONTS]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSpurchasetypeFonts;
}

- (void)GSBuyPopupViewDelegateBuyPressed {
    [m_buyFontView hideMessage];
    m_buyFontView = nil;
    
    if ([SKPaymentQueue canMakePayments]) {
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:IAP_PRO_VERSION]];
        request.delegate = self;
        [request start];
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable In App Purchase in Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    mPurchaseTag = GSPurchaseTypeGoPro;
}

- (void)GSBuyPopupViewDelegateCancelPressed {
    [m_buyFontView hideMessage];
    m_buyFontView = nil;
}

#pragma mark -SKProductsRequestDelegate-

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *products = response.products;
    if (products.count != 0) {
        SKPayment *payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Product not found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [lAlertView show];
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products){
        NSLog(@"Product not found: %@", product);
    }}

#pragma mark -SKPaymentTransactionObserver-
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                [self goPro];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Transaction Failed");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                [self goPro];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            default:
                break;
        }
    }
}

- (void)goPro {
    if (mPurchaseTag == GSPurchaseTypeWatermark) {
        [self removeWatermark];
    } else if (mPurchaseTag == GSPurchaseTypeFrames) {
        [self buyFrames];
        [self removeLockers];
    } else if (mPurchaseTag == GSPurchaseTypeAds) {
        [self removeAds];
    }
    else if(mPurchaseTag == GSPurchaseTypeAds){
        [self buyFonts];
        
    } else if (mPurchaseTag == GSPurchaseTypeGoPro) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_OLD_PURCHASE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FONTS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self removeLockers];
    }
}

- (void)removeLockers {
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_AD_NOTIFICATION object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_OLD_PURCHASE];
    
    mUseHasBoughtCollages = YES;
    mCountOfFreeCollages = mArrayOfColages.count+1;
    m_freeCountFont = [fontArray count];
    [m_fontPanel reloadData];
    [mCollageController loadTemplates];
    
    mBuyCollagesButton.hidden = YES;
    mPublishButton.hidden = NO;
}

- (void)removeWatermark {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
}

- (void)removeAds {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
}

- (void)buyFrames {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
}

- (void)buyFonts
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FONTS];
    m_freeCountFont = [fontArray count]+1;
}

#pragma SLIDE ANIMATIONS-----------//

- (void) slideWithKeyboard
{
    NSLog(@"------------------------------------slide with keyboards----------------------------------");
    if(isText)
    {
        NSLog(@"********************ISTEXT IS YES*******************");
        [mCollageController setHidden:NO];
        m_textControlPanel.hidden = NO;
        [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [m_textView setFrame:CGRectMake(0.0f,mBottomView.frame.origin.y - m_textView.frame.size.height , self.view.frame.size.width, m_textView.frame.size.height)];
            [m_workView setFrame:CGRectMake(0.0f, 45.f , self.view.frame.size.width, m_workView.frame.size.height)];
            if(isFixText)
            {

                [self createTextView:m_textView.text:m_currentFont:textColor:m_fsize:nTextRotateCnt];
                CGRect viewFrame = ((UIImageView *)[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW]).frame;
                CGRect rt = CGRectMake(viewFrame.origin.x + viewFrame.size.width, viewFrame.origin.y - m_txtDeleteBtn.frame.size.height, m_txtDeleteBtn.frame.size.width, m_txtDeleteBtn.frame.size.width);
                [m_txtDeleteBtn setFrame:rt];

            }
        } completion:^(BOOL finished) {
            
        }];
        isText = NO;
        NSLog(@"-----------%f==================",m_workView.frame.origin.y);
    }
    else
    {
        NSLog(@"********************ISTEXT IS NO*******************");
        m_textView.hidden = NO;
        [mCollageController setHidden:YES];
        m_textControlPanel.hidden = YES;
        [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [m_textView setFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - KEYBOARD_HEIGHT - m_textView.frame.size.height , self.view.frame.size.width, m_textView.frame.size.height)];
            [m_workView setFrame:CGRectMake(0.0f, [UIScreen mainScreen].bounds.size.height - KEYBOARD_HEIGHT - m_workView.frame.size.height , self.view.frame.size.width, m_workView.frame.size.height)];

            if(isFixText)
            {
                CGRect viewFrame = ((UIImageView *)[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW]).frame;
                CGRect rt = CGRectMake(viewFrame.origin.x + viewFrame.size.width, viewFrame.origin.y - m_txtDeleteBtn.frame.size.height, m_txtDeleteBtn.frame.size.width, m_txtDeleteBtn.frame.size.width);
                [m_txtDeleteBtn setFrame:rt];
            }
        } completion:^(BOOL finished) {
            
        }];
        isText = YES;
    }
}

- (void) txtViewSlideDown
{
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [m_textView setFrame:CGRectMake(0.0f,mBottomView.frame.origin.y - m_textView.frame.size.height , self.view.frame.size.width, m_textView.frame.size.height)];
        [m_workView setFrame:CGRectMake(0.0f, 45.f , self.view.frame.size.width, m_workView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
    isText = NO;
    [m_textView resignFirstResponder];
}

- (void)deleteText:(id)sender
{
    [[[m_textArray objectAtIndex:tmpTag] objectForKey:KEY_VIEW] removeFromSuperview];
    [fontArray removeObjectAtIndex:tmpTag];
    [m_txtDeleteBtn setHidden:YES];
    [m_textView setText:@""];
    isFixText = NO;
    if(isText)[m_textView resignFirstResponder];
    
}
#pragma END ADD TEXT---------------//

@end
