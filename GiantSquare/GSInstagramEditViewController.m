//
//  GSInstagramEditViewController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 3/14/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSInstagramEditViewController.h"
#import "MBBProgressHUD.h"
#import "GSCustomNavigationController.h"
#import "GSManualViewController.h"
#import "GSInspirationViewController.h"
#import "Flurry.h"
#import <RevMobAds/RevMobAds.h>

@interface GSInstagramEditViewController ()
- (void) showErrorMessage;
- (void) showSuccessMessage;
- (void) updateControlButtonsStates;
- (void) saveImageWithIndex:(NSNumber *)pIndex;
- (void) getAllImagesToArray;
- (void) clearArrayOfImages;
- (void) setImageForButton:(UIButton*)pButton withType:(GSButtonType)pType;
- (void) tapGestureRecognizer:(UITapGestureRecognizer*)pTapGesureRecognizer;
- (void) panGestureRecognizer:(UIPanGestureRecognizer*)pPanGesureRecognizer;
- (void) pinchGestureRecognizer:(UIPinchGestureRecognizer*)pPinchGesureRecognizer;
- (void) adjustElementSize:(GSInstagramElement*)pInstagramElement;
- (BOOL) addSelectedRectToElement:(GSInstagramElement*)pInstagramElement;
- (void) gridButtonPressed:(UIButton*)pButton;
//editing mode
- (void) selectElement:(GSInstagramElement*)pInstagramElement;
- (void) deselectElement;
- (void) addPlusButtonsToElement:(GSInstagramElement*)pInstagramElement;
- (void) removePlusButtons;
- (void) addRemoveButtons;
- (void) deleteRemoveButtons;
- (void) setMarkButtonsHidden:(BOOL)pHidden;
- (BOOL) isFreeSquare;
- (void) setChangeIsAdd:(BOOL)pIsAdd toElement:(GSInstagramElement*)pInstagramElement withButton:(UIButton*)pButton;
- (void) resetAddChanges;
@end

@implementation GSInstagramEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        mArrayOfElements = [[NSMutableArray alloc] init];
        
        mIsAddState = NO;
        mIsRemoveState = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set background image
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"backgroundLight.png", @"backgroundLight_iPhone5.png")]]];

    [self initGrid];
    
    //load bottom menu
    NSArray *lTopLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GSInstagramBottomMenu" owner:nil options:nil];
    mBottomMenu = (GSInstagramBottomMenu*)[lTopLevelObjects objectAtIndex:0];
    mBottomMenu.delegate = self;
    [mBottomMenu setMenuState:0];
    [self.view addSubview:mBottomMenu];



    // add advertisement
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
            [mAdView setFrame:CGRectMake(0.0f, self.view.bounds.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }
        
        mIsBannerAppear = NO;
    }
    
    UITapGestureRecognizer *lTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [lTapRecognizer setNumberOfTapsRequired:1];
    [mGesturesView addGestureRecognizer:lTapRecognizer];
    
    UIPanGestureRecognizer *lPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
	[lPanRecognizer setMinimumNumberOfTouches:1];
	[lPanRecognizer setMaximumNumberOfTouches:1];
	[mGesturesView addGestureRecognizer:lPanRecognizer];
    
    UIPinchGestureRecognizer *lPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
	[mGesturesView addGestureRecognizer:lPinchRecognizer];
    
    UILongPressGestureRecognizer *lLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    lLongPressRecognizer.minimumPressDuration = 0.5;
    [mGesturesView addGestureRecognizer:lLongPressRecognizer];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"instagram_label_state"]) {
        [mChangeLabelButton setSelected:YES];
        [mChangeLabelButton setImage:[UIImage imageNamed:@"label_state_on.png"] forState:UIControlStateNormal];
    }
    
    mIsChange = NO;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.view.frame.size.height > 480 || self.view.frame.size.width > 480) {
        mBottomMenu.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - mBottomMenu.frame.size.height/2 - 5);
    }else{
        mBottomMenu.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - mBottomMenu.frame.size.height/2 - 45);
    }
    
    // show tutorial at first start
    if (!getVal(@"firstStartInstagram")) {
        setVal(@"firstStartInstagram", @"NO");
        GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeInstagram];
        lHelp.delegate = self;
        [self.view addSubview:lHelp];
        [lHelp loadTutorial];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showErrorMessage {
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please turn on location services." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [lAlert show];
}

- (void) showSuccessMessage {
    // advertisment
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
            [[RevMobAds session] showFullscreen];
        }
    }
    
    
    NSString *lTitle = @"";
    NSInteger lType = arc4random() % 6;
    if (lType == 0) {
        lTitle = @"Amazing work!";
    }else if(lType == 1){
        lTitle = @"Excellent!";
    }else if(lType == 2){
        lTitle = @"You're a rockstar at this!";
    }else if(lType == 3){
        lTitle = @"Great!";
    }else if(lType == 4){
        lTitle = @"Well done!";
    }else if(lType == 5){
        lTitle = @"Awesome!";
    }
    
    
    UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:lTitle message:@"Now open Instagram and start uploading the exported pictures from your camera roll" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [lAlert show];
}

- (void) updateControlButtonsStates {
    if (mArrayOfElements.count == 0) {
        [mExportButton setEnabled:NO];
        
        if ([self isSelectedSquare]) {
            [mBottomMenu setMenuState:1];
        } else {
            [mBottomMenu setMenuState:0];
        }
        
    } else {
        if (mCurrentElement != nil) {
            
            if (mIsAddState || mIsRemoveState) {
                [mExportButton setEnabled:NO];
                [mBottomMenu setMenuState:4];
            } else {
                [mExportButton setEnabled:YES];
                [mBottomMenu setMenuState:3];
            }
            
        } else {
            [mExportButton setEnabled:YES];
            
            if ([self isFreeSquare] && [self isSelectedSquare]) {
                [mBottomMenu setMenuState:1];
            } else {
                [mBottomMenu setMenuState:3];
            }
        }
    }
}

- (void)saveImageWithIndex:(NSNumber *)pIndex {
    NSInteger lIndex = [pIndex integerValue];
    
    if (lIndex < mArrayOfCuttedImages.count) {
        DLog(@"save index - %i", [pIndex integerValue]);
        ALAssetsLibrary *lLibrary = [[ALAssetsLibrary alloc] init];
        UIImage *lImage = [mArrayOfCuttedImages objectAtIndex:lIndex];
        [lLibrary writeImageToSavedPhotosAlbum:lImage.CGImage orientation:lImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            DLog(@"writeImageToSavedPhotosAlbum  error: %@", error);
            if (error == nil) {
                ALAssetsLibrary *lLibraryForAddURLs = [[ALAssetsLibrary alloc] init];
                [lLibraryForAddURLs addAssetURL:assetURL toAlbum:ALBUM_NAME withCompletionBlock:^(NSError *error) {
                    DLog(@"addAssetURL error: %@", error);
                    if (error == nil){
                        DLog(@"lIndex  - %i", lIndex);
                        if (lIndex < [mArrayOfCuttedImages count] - 1) {
                            [self saveImageWithIndex:[NSNumber numberWithInteger:lIndex + 1]];
                        }else{
                            [MBBProgressHUD hideHUDForView:self.view animated:YES];
                            [self showSuccessMessage];
                            [self clearArrayOfImages];
                        }
                    } else {
                        [MBBProgressHUD hideHUDForView:self.view animated:YES];
                        [self showErrorMessage];
                    }
                }];
            } else {
                [MBBProgressHUD hideHUDForView:self.view animated:YES];
                [self showErrorMessage];
            }
        }];
    } else {
        [MBBProgressHUD hideHUDForView:self.view animated:YES];
        [self showSuccessMessage];
        [self clearArrayOfImages];
    }
}

-(BOOL) canDrawWatermarkAtRect:(NSUInteger)pRect {
    UIButton *lButton = [mArrayOfMarkButtons objectAtIndex:pRect];
    for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
        if ([lInstagramElement isElementContainPoint:lButton.center]) {
            UIButton *lSecondButton = [mArrayOfMarkButtons objectAtIndex:pRect - 1];
            for (GSInstagramElement *lInstagrammElement in mArrayOfElements) {
                if ([lInstagrammElement isElementContainPoint:lSecondButton.center]) {
                    return YES;
                }
           }
        }
    }
    return NO;
}

-(NSInteger) returnLastDrawableRect {
    NSInteger lTag = [mArrayOfMarkButtons count] - 1;
    NSArray *lReversedArray = [[mArrayOfMarkButtons reverseObjectEnumerator]allObjects];
    for (UIButton *lButton in lReversedArray) {
        for (GSInstagramElement *lElement in mArrayOfElements) {
            if ([lElement isElementContainPoint:lButton.center]) {
                NSLog(@"Oneelement to return: %i", lTag);
                return lTag;
            }
        }
        lTag--;
    }
    return -1;
}

- (void) getAllImagesToArray {
    if (mArrayOfCuttedImages == nil) {
        mArrayOfCuttedImages = [[NSMutableArray alloc] init];
    } else {
        [mArrayOfCuttedImages removeAllObjects];
    }
    NSInteger lDrawableRect = -1;
    if (![[NSUserDefaults standardUserDefaults]boolForKey:IAP_WATERMARK]) {
        if ([self canDrawWatermarkAtRect:8]) {
            [[mArrayOfMarkButtons objectAtIndex:8] setTag:99];
            [[mArrayOfMarkButtons objectAtIndex:7] setTag:99];
        } else if ([self canDrawWatermarkAtRect:7]) {
            [[mArrayOfMarkButtons objectAtIndex:7] setTag:99];
            [[mArrayOfMarkButtons objectAtIndex:6] setTag:99];
        } else if ([self canDrawWatermarkAtRect:5]) {
            [[mArrayOfMarkButtons objectAtIndex:5] setTag:99];
            [[mArrayOfMarkButtons objectAtIndex:4] setTag:99];
        } else if ([self canDrawWatermarkAtRect:4]) {
            [[mArrayOfMarkButtons objectAtIndex:4] setTag:99];
            [[mArrayOfMarkButtons objectAtIndex:3] setTag:99];
        } else if ([self canDrawWatermarkAtRect:2]) {
            [[mArrayOfMarkButtons objectAtIndex:2] setTag:99];
            [[mArrayOfMarkButtons objectAtIndex:1] setTag:99];
        } else if ([self canDrawWatermarkAtRect:1]) {
            [[mArrayOfMarkButtons objectAtIndex:1] setTag:99];
            [[mArrayOfMarkButtons objectAtIndex:0] setTag:99];
        } else {
            lDrawableRect = [self returnLastDrawableRect];
        }

        
    }
    BOOL lFirstOfTwo = YES;
    NSInteger lWatermarkValue = 0;
    NSInteger lCounter = 0;
    for (UIButton *lButton in mArrayOfMarkButtons) {
        UIImage *lImage = nil;
        BOOL lWatermark = (lButton.tag == 99);
        if (lWatermarkValue == 1) {
            lFirstOfTwo = NO;
        }
        if (!lWatermark) {
            lWatermarkValue = 0;
        } else if (lFirstOfTwo) {
            lWatermarkValue = 1;
        } else {
            lWatermarkValue = 2;
        }
        if (lCounter == lDrawableRect) {
            lWatermarkValue = 2;
        }
        for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
            if (lButton.tag != GSButtonTypeUsed && [lInstagramElement isElementContainPoint:lButton.center]) {
                [lButton setTag:GSButtonTypeUsed];
            }
            lImage = [lInstagramElement imageAtPoint:lButton.center withWatermark:lWatermarkValue];
            if (lImage != nil) {
                [mArrayOfCuttedImages addObject:lImage];
                break;
            }
        }
        lCounter++;
    }
    NSLog(@"mArrayOfCuttedImages %@", mArrayOfCuttedImages);
}

- (void) clearArrayOfImages {
    [mArrayOfCuttedImages removeAllObjects];
    mArrayOfCuttedImages = nil;
}

- (IBAction) changeLabelStateButtonPressed:(UIButton*)pSender {
    [pSender setSelected:!pSender.selected];
    
    if (pSender.selected) {
        [pSender setImage:[UIImage imageNamed:@"label_state_on.png"] forState:UIControlStateNormal];
    } else {
        [pSender setImage:[UIImage imageNamed:@"label_state_off.png"] forState:UIControlStateNormal];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:pSender.selected forKey:@"instagram_label_state"];
    
    for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
        [lInstagramElement setLabelState:pSender.selected];
    }
}

#pragma mark - Gestures handlers -
- (void) setImageForButton:(UIButton*)pButton withType:(GSButtonType)pType {
    if (pButton != nil) {
        [pButton setTag:pType];
        if (pType == GSButtonTypeDelete) {
            [pButton setImage:[UIImage imageNamed:@"instagram_delete_button.png"] forState:UIControlStateNormal];
            [pButton setImage:[UIImage imageNamed:@"instagram_delete_pushed_button.png"] forState:UIControlStateHighlighted];
            [pButton setImage:nil forState:UIControlStateSelected];
            [pButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateNormal];
        } else if (pType == GSButtonTypeAdd) {
            [pButton setImage:[UIImage imageNamed:@"blue_plus_button.png"] forState:UIControlStateNormal];
            [pButton setImage:nil forState:UIControlStateHighlighted];
            [pButton setImage:nil forState:UIControlStateSelected];
            [pButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateNormal];
        } else {
            [pButton setBackgroundImage:[UIImage imageNamed:@"squareNormal.png"] forState:UIControlStateNormal];
            [pButton setImage:nil forState:UIControlStateHighlighted];
            [pButton setBackgroundImage:[UIImage imageNamed:@"squareSelected.png"] forState:UIControlStateSelected];
            [pButton setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
}

- (void) tapGestureRecognizer:(UITapGestureRecognizer*)pTapGesureRecognizer {
    CGPoint lLocationInView = [pTapGesureRecognizer locationInView:mGesturesView];
    
    for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
        if ([lInstagramElement isElementContainPoint:lLocationInView]) {
            mIsAddState = YES;
            [self deselectElement];
            [self selectElement:lInstagramElement];
            break;
        }
    }
}

- (void) panGestureRecognizer:(UIPanGestureRecognizer*)pPanGesureRecognizer {
    static GSInstagramElement *sInstagramElement = nil;
    CGPoint lLocationInView = [pPanGesureRecognizer locationInView:mGesturesView];
    CGPoint lTransitionInView = [pPanGesureRecognizer translationInView:mGesturesView];
    
    if ([pPanGesureRecognizer state] == UIGestureRecognizerStateBegan){
        for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
            if ([lInstagramElement isElementContainPoint:lLocationInView]) {
                sInstagramElement = lInstagramElement;
                break;
            }
        }
        [sInstagramElement setTransition:lTransitionInView];
    } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateChanged){
        [sInstagramElement setTransition:lTransitionInView];
    } else if ([pPanGesureRecognizer state] == UIGestureRecognizerStateEnded){
        CGPoint lVelocity = [pPanGesureRecognizer velocityInView:mGesturesView];
        [sInstagramElement setTransition:lTransitionInView];
        [sInstagramElement updatePositionsWithVelocity:lVelocity];
        sInstagramElement = nil;
    }
    
    [pPanGesureRecognizer setTranslation:CGPointZero inView:mGesturesView];
}

- (void) pinchGestureRecognizer:(UIPinchGestureRecognizer*)pPinchGesureRecognizer {
    static GSInstagramElement *sInstagramElement = nil;
    
    if (pPinchGesureRecognizer.numberOfTouches != 2) {
        [pPinchGesureRecognizer setEnabled:NO];
        [sInstagramElement updatePositionsWithVelocity:CGPointMake(0.0, 0.0)];
        sInstagramElement = nil;
        [pPinchGesureRecognizer setEnabled:YES];
    }
    
    CGPoint lLocationInView = [pPinchGesureRecognizer locationInView:mGesturesView];
    
    if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint lTouchLocation = [pPinchGesureRecognizer locationOfTouch:0 inView:mGesturesView];
        for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
            if ([lInstagramElement isElementContainPoint:lTouchLocation]) {
                sInstagramElement = lInstagramElement;
                break;
            }
        }
              
        [sInstagramElement setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
    } else if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateChanged){
        [sInstagramElement setPinchScale:pPinchGesureRecognizer.scale atPoint:lLocationInView];
    } else if ([pPinchGesureRecognizer state] == UIGestureRecognizerStateEnded) {
        [sInstagramElement updatePositionsWithVelocity:CGPointMake(0.0, 0.0)];
        sInstagramElement = nil;
    }
    
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer*)pLongPressGestureRecognizer{
    
    //detect touch location
    CGPoint lLocationInView = [pLongPressGestureRecognizer locationInView:mGesturesView];
    if (pLongPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //search tapped element
        for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
            //if user tap element we show action sheet
            if ([lInstagramElement isElementContainPoint:lLocationInView]) {
                mCurrentElement = lInstagramElement;

                [self openPicker];
                break;
            }
        }
    }
    
}

- (void)openPicker{
    if([[UIDevice currentDevice] systemVersion].floatValue >= CHUTE_PICKER_REQUIRED_VERSION){
        PhotoPickerViewController *lPhotoController = [PhotoPickerViewController new];
        [lPhotoController setDelegate:self];
        [lPhotoController setIsMultipleSelectionEnabled:NO];
        [self presentModalViewController:lPhotoController animated:YES];
    }else{
        if (getVal(@"stopRepeatAlert") && [getVal(@"stopRepeatAlert") isEqualToString:@"YES"]) {
            [self openCameraRoll];
        }else{
            [self showiOS5Alert];
        }
        
    }
}

#pragma mark - iOS5 alert
- (void)showiOS5Alert{
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:IOS5_ALERT_TITLE_TEXT message:IOS5_ALERT_DESCRIPTION delegate:nil cancelButtonTitle:IOS5_ALERT_SUCCESS_BUTTON otherButtonTitles:IOS5_ALERT_DONT_REMIND_BUTTON, nil];
    lAlertView.delegate = self;
    lAlertView.tag = 3;
    [lAlertView show];
}

- (void)openCameraRoll{
    UIImagePickerController *lPicker = [[UIImagePickerController alloc] init];
    lPicker.delegate = self;
    lPicker.allowsEditing = YES;
    lPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentModalViewController:lPicker animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 3) {
        if (buttonIndex == 1){
            setVal(@"stopRepeatAlert", @"YES");
        }
        [self openCameraRoll];
       
    }else if (alertView.tag == 4){
        if (buttonIndex == 1){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


- (void) adjustElementSize:(GSInstagramElement*)pInstagramElement {
    CGFloat lMinX = 1000;
    CGFloat lMinY = 1000;
    CGFloat lMaxX = 0;
    CGFloat lMaxY = 0;
    
    if (pInstagramElement.arrayOfRects.count == 0) {
        lMinX = 1;
        lMinY = 1;
    } else {
        for (NSValue *lRectValue in pInstagramElement.arrayOfRects) {
            CGRect lRect = [lRectValue CGRectValue];
            if (CGRectGetMinX(lRect) < lMinX) {
                lMinX = CGRectGetMinX(lRect);
            }
            if (CGRectGetMinY(lRect) < lMinY) {
                lMinY = CGRectGetMinY(lRect);
            }
            if (CGRectGetMaxX(lRect) > lMaxX) {
                lMaxX = CGRectGetMaxX(lRect);
            }
            if (CGRectGetMaxY(lRect) > lMaxY) {
                lMaxY = CGRectGetMaxY(lRect);
            }
        }
        
        lMinX -= START_POINT_X;
        lMinY -= START_POINT_Y;
        lMaxX -= START_POINT_X;
        lMaxY -= START_POINT_Y;
        
        for (NSUInteger rectIndex = 0; rectIndex < pInstagramElement.arrayOfRects.count; rectIndex++) {
            NSValue *lRectValue = [pInstagramElement.arrayOfRects objectAtIndex:rectIndex];
            CGRect lRect = [lRectValue CGRectValue];
            lRect = CGRectOffset(lRect, -lMinX, -lMinY);
            [pInstagramElement.arrayOfRects replaceObjectAtIndex:rectIndex withObject:[NSValue valueWithCGRect:lRect]];
        }
    }
    
    [pInstagramElement setFrame:CGRectMake(pInstagramElement.frame.origin.x + lMinX, pInstagramElement.frame.origin.y + lMinY, lMaxX - lMinX, lMaxY - lMinY)];
    
    [pInstagramElement updateLabelsTitle];
    [pInstagramElement setNeedsDisplay];
}

- (BOOL) addSelectedRectToElement:(GSInstagramElement*)pInstagramElement {
    BOOL lResult = NO;
    for (UIButton *lButton in mArrayOfMarkButtons) {
        if (lButton.selected) {
            CGRect lNewRect = CGRectOffset(lButton.frame, -pInstagramElement.frame.origin.x + START_POINT_X, -pInstagramElement.frame.origin.y + START_POINT_Y);
            [pInstagramElement addRect:lNewRect];
            
            lButton.selected = NO;
            lButton.hidden = YES;
            lResult = YES;
        }
    }
    return lResult;
}

- (void) selectElement:(GSInstagramElement*)pInstagramElement {
    if (pInstagramElement != nil) {
        
        mCurrentElement = pInstagramElement;
        [self addPlusButtonsToElement:pInstagramElement];
        [self setMarkButtonsHidden:YES];
        [self updateControlButtonsStates];
    }
}

- (void) deselectElement {
    [self removePlusButtons];
    [self deleteRemoveButtons];
    [self setMarkButtonsHidden:NO];
    mCurrentElement = nil;
    [self updateControlButtonsStates];
}

- (void) addPlusButtonsToElement:(GSInstagramElement*)pInstagramElement {
    if (mArrayOfAddButtons) {
        [mArrayOfAddButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [mArrayOfAddButtons removeAllObjects];
    } else {
        mArrayOfAddButtons = [NSMutableArray new];
    }
    
    CGFloat lStartX = START_POINT_X;
    CGFloat lStartY = START_POINT_Y;
    
    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            
            UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(lStartX, lStartY, SQUARE_SIZE, SQUARE_SIZE)];
            [lButton setTag:GSButtonTypeAdd];
            [lButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateNormal];
            
            if (![mCurrentElement isElementContainPoint:lButton.center]) {
                [lButton setImage:[UIImage imageNamed:@"blue_plus_button.png"] forState:UIControlStateNormal];
                [lButton setImage:[UIImage imageNamed:@"blue_plus_button_highlighted.png"] forState:UIControlStateHighlighted];
                [lButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame_highlighted.png"] forState:UIControlStateHighlighted];
                [lButton addTarget:self action:@selector(gridButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [lButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateHighlighted];
            }
            
            [mArrayOfAddButtons addObject:lButton];
            [self.view insertSubview:lButton aboveSubview:mGridView];
            lStartX = lStartX + SQUARE_SIZE + START_POINT_X;
        }
        lStartY = lStartY + SQUARE_SIZE + START_POINT_X;
        lStartX = START_POINT_X;
    }
}

- (void) removePlusButtons {
    if (mArrayOfAddButtons) {
        [mArrayOfAddButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [mArrayOfAddButtons removeAllObjects];
        mArrayOfAddButtons = nil;
    }
}

- (void) addRemoveButtons {
    if (mArrayOfDeleteButtons) {
        [mArrayOfDeleteButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [mArrayOfDeleteButtons removeAllObjects];
    } else {
        mArrayOfDeleteButtons = [NSMutableArray new];
    }
    
    for (UIButton *lMarkButton in mArrayOfMarkButtons) {
        UIButton *lButton = [[UIButton alloc] initWithFrame:lMarkButton.frame];
        [lButton setTag:GSButtonTypeDelete];
        [lButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateNormal];
        [lButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateHighlighted];
        [mArrayOfDeleteButtons addObject:lButton];
        [self.view insertSubview:lButton aboveSubview:mGridView];
        if (lMarkButton.tag == GSButtonTypeUsed) {
            [lButton setImage:[UIImage imageNamed:@"instagram_delete_button.png"] forState:UIControlStateNormal];
            [lButton setImage:[UIImage imageNamed:@"instagram_delete_pushed_button.png"] forState:UIControlStateHighlighted];
            [lButton setImage:[UIImage imageNamed:@"instagram_delete_active_button.png"] forState:UIControlStateSelected];
            [lButton addTarget:self action:@selector(gridButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void) deleteRemoveButtons {
    if (mArrayOfDeleteButtons) {
        [mArrayOfDeleteButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [mArrayOfDeleteButtons removeAllObjects];
        mArrayOfDeleteButtons = nil;
    }
}

- (void) setMarkButtonsHidden:(BOOL)pHidden {
    if (mArrayOfMarkButtons != nil) {
        for (UIButton *lButton in mArrayOfMarkButtons) {
            if (pHidden) {
                [lButton setHidden:YES];
                [lButton setSelected:NO];
            } else {
                if (lButton.tag == GSButtonTypeMark) {
                    [lButton setHidden:NO];
                    [lButton setSelected:NO];
                } else {
                    [lButton setHidden:YES];
                    [lButton setSelected:NO];
                }
            }   
        }
    }
}

#pragma mark - grid methods

- (void) initGrid {
    if (mArrayOfMarkButtons) {
        [mArrayOfMarkButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [mArrayOfMarkButtons removeAllObjects];
    } else {
        mArrayOfMarkButtons = [NSMutableArray new];
    }
    
    CGFloat lStartX = START_POINT_X;
    CGFloat lStartY = START_POINT_Y;
    
    for (NSInteger i = 0; i < 3; i++) {
        for (NSInteger j = 0; j < 3; j++) {
            UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(lStartX, lStartY, SQUARE_SIZE, SQUARE_SIZE)];
            [lButton setTag:GSButtonTypeMark];
            [lButton addTarget:self action:@selector(gridButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [lButton setBackgroundImage:[UIImage imageNamed:@"squareNormal.png"] forState:UIControlStateNormal];
            [lButton setBackgroundImage:[UIImage imageNamed:@"squareSelected.png"] forState:UIControlStateSelected];
            [mArrayOfMarkButtons addObject:lButton];
            [self.view insertSubview:lButton aboveSubview:mGridView];
            lStartX = lStartX + SQUARE_SIZE + START_POINT_X;
        }
        lStartY = lStartY + SQUARE_SIZE + START_POINT_X;
        lStartX = START_POINT_X;
    }
    
}

- (void)addElementWithImage:(UIImage*)pImage{
    NSMutableArray *lFramesArray = [NSMutableArray new];
    CGFloat lMinX = 1000;
    CGFloat lMinY = 1000;
    CGFloat lMaxX = 0;
    CGFloat lMaxY = 0;
    
    for (UIButton *lButton in mArrayOfMarkButtons) {
        if (lButton.selected) {
            [lButton setTag:GSButtonTypeUsed];
            if (CGRectGetMinX(lButton.frame) < lMinX) {
                lMinX = CGRectGetMinX(lButton.frame);
            }
            if (CGRectGetMinY(lButton.frame) < lMinY) {
                lMinY = CGRectGetMinY(lButton.frame);
            }
            if (CGRectGetMaxX(lButton.frame) > lMaxX) {
                lMaxX = CGRectGetMaxX(lButton.frame);
            }
            if (CGRectGetMaxY(lButton.frame) > lMaxY) {
                lMaxY = CGRectGetMaxY(lButton.frame);
            }
        }
    }
    
    for (UIButton *lButton in mArrayOfMarkButtons) {
        if (lButton.selected) {
            CGRect lNewRect = CGRectOffset(lButton.frame, -lMinX + START_POINT_X, -lMinY + START_POINT_Y);
            [lFramesArray addObject:[NSValue valueWithCGRect:lNewRect]];
            
            lButton.selected = NO;
            lButton.hidden = YES;
        }
    }
    
    GSInstagramElement *lElement = [[GSInstagramElement alloc] initWithFrame:CGRectMake(lMinX, lMinY, lMaxX - lMinX, lMaxY - lMinY) andRects:lFramesArray];
    [lElement setFrame:CGRectMake(lMinX, lMinY, lMaxX - lMinX, lMaxY - lMinY)];
    [lElement setImage:pImage];
    [lElement setTag:mArrayOfElements.count];
    [lElement setLabelState:mChangeLabelButton.selected];
    [self.view insertSubview:lElement belowSubview:mGesturesView];
    [mArrayOfElements addObject:lElement];
    mCurrentElement = lElement;
    
    [self updateControlButtonsStates];
}

- (void) gridButtonPressed:(UIButton*)pButton {
    if (pButton.tag == GSButtonTypeDelete) {
        pButton.selected = !pButton.selected;
//        if ([mCurrentElement removeRectWithPoint:CGPointMake(pButton.center.x, pButton.center.y)]) {
//            [self adjustElementSize:mCurrentElement];
//        }
    } else if (pButton.tag == GSButtonTypeAdd) {
        [mBottomMenu setMenuState:4];
        
        for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
            if ([lInstagramElement removeRectWithPoint:pButton.center]) {
                [self setChangeIsAdd:NO toElement:lInstagramElement withButton:pButton];
                [self adjustElementSize:lInstagramElement];
                break;
            }
        }
        
        [self setChangeIsAdd:YES toElement:mCurrentElement withButton:pButton];
        
        UIButton *lAddButton = [mArrayOfMarkButtons objectAtIndex:[mArrayOfAddButtons indexOfObject:pButton]];
        [lAddButton setTag:GSButtonTypeUsed];
        
        [pButton setImage:nil forState:UIControlStateNormal];
        [pButton setImage:nil forState:UIControlStateHighlighted];
        [pButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame.png"] forState:UIControlStateHighlighted];
        [pButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        
        CGRect lNewRect = CGRectOffset(pButton.frame, -mCurrentElement.frame.origin.x + START_POINT_X, -mCurrentElement.frame.origin.y + START_POINT_Y);
        [mCurrentElement addRect:lNewRect];
        
        [self adjustElementSize:mCurrentElement];
    
    } else {
        pButton.selected = !pButton.selected;
        mCurrentElement = nil;
        [self updateControlButtonsStates];
    }
    
}

- (void) clearGrid {
    for (UIView *lView in [self.view subviews]) {
        if ([lView isKindOfClass:[GSInstagramElement class]]) {
            [lView removeFromSuperview];
        }
    }
    for (UIButton *lButton in mArrayOfMarkButtons) {
        [lButton removeFromSuperview];
    }
    [self initGrid];
}

- (BOOL) isSelectedSquare {
    BOOL isSelected = NO;
    for (UIButton *lButton in mArrayOfMarkButtons) {
        if (lButton.selected) {
            isSelected = YES;
             mIsChange = YES;
            break;
        } else {
            mIsChange = NO;
        }
    }
   
    return isSelected;
}

- (BOOL) isFreeSquare {
    BOOL isFree = NO;
    DLog(@"mArrayOfMarkButtons count  - %i", [mArrayOfMarkButtons count]);
    
    for (UIButton *lButton in mArrayOfMarkButtons) {
        DLog(@"lButton.tag  - %i", lButton.tag);
        if (lButton.tag == GSButtonTypeMark) {
            isFree = YES;
//            break;
        }
    }
    return isFree;
}

- (void) setChangeIsAdd:(BOOL)pIsAdd toElement:(GSInstagramElement*)pInstagramElement withButton:(UIButton*)pButton {
    if (mArrayOfAddChanges == nil) {
        mArrayOfAddChanges = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *lChanges = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:pIsAdd], @"is_add", pInstagramElement, @"element", pButton, @"button", nil];
    [mArrayOfAddChanges addObject:lChanges];
}

- (void) resetAddChanges {
    if (mArrayOfAddChanges != nil) {
        for (NSInteger index = mArrayOfAddChanges.count-1; index >= 0; index--) {
            NSDictionary *lChanges = [mArrayOfAddChanges objectAtIndex:index];
            GSInstagramElement *lInstagramElement = [lChanges objectForKey:@"element"];
            UIButton *lButton = [lChanges objectForKey:@"button"];
            
            [lButton setImage:[UIImage imageNamed:@"blue_plus_button.png"] forState:UIControlStateNormal];
            [lButton setImage:[UIImage imageNamed:@"blue_plus_button_highlighted.png"] forState:UIControlStateHighlighted];
            [lButton setBackgroundImage:[UIImage imageNamed:@"blue_square_frame_highlighted.png"] forState:UIControlStateHighlighted];
            [lButton addTarget:self action:@selector(gridButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([[lChanges objectForKey:@"is_add"] boolValue]) {
                [lInstagramElement removeRectWithPoint:lButton.center];
                
                UIButton *lAddButton = [mArrayOfMarkButtons objectAtIndex:[mArrayOfAddButtons indexOfObject:lButton]];
                [lAddButton setTag:GSButtonTypeMark];
            } else {
                UIButton *lAddButton = [mArrayOfMarkButtons objectAtIndex:[mArrayOfAddButtons indexOfObject:lButton]];
                [lAddButton setTag:GSButtonTypeUsed];
                
                CGRect lNewRect = CGRectOffset(lButton.frame, -lInstagramElement.frame.origin.x + START_POINT_X, -lInstagramElement.frame.origin.y + START_POINT_Y);
                [lInstagramElement addRect:lNewRect];
            }
            
            [mArrayOfAddChanges removeObjectAtIndex:index];
        }
        
        mArrayOfAddChanges = nil;
        
        for (NSInteger index = mArrayOfElements.count-1; index >= 0; index--) {
            GSInstagramElement *lInstagramElement = [mArrayOfElements objectAtIndex:index];
            if (lInstagramElement.arrayOfRects.count == 0) {
                [mArrayOfElements removeObject:lInstagramElement];
            } else {
                [self adjustElementSize:lInstagramElement];
            }
        }
    }
}

#pragma mark - bottomMenu delegate
- (void) GSInstagramBottomMenuDonePressed {
    
    if (mIsAddState) {
        for (NSInteger index = mArrayOfElements.count-1; index >= 0; index--) {
            GSInstagramElement *lInstagramElement = [mArrayOfElements objectAtIndex:index];
            if (lInstagramElement.arrayOfRects.count == 0) {
                [mArrayOfElements removeObject:lInstagramElement];
            } else {
                [self adjustElementSize:lInstagramElement];
            }
        }
        
        if (mArrayOfAddChanges != nil) {
            [mArrayOfAddChanges removeAllObjects];
            mArrayOfAddChanges = nil;
        }
    }
    
    if (mIsRemoveState) {
        for (UIButton *lRemoveButton in mArrayOfDeleteButtons) {
            if (lRemoveButton.selected) {
                CGPoint lPoint = CGPointMake(lRemoveButton.center.x, lRemoveButton.center.y);
                for (GSInstagramElement *lInstagramElement in mArrayOfElements) {
                    if ([lInstagramElement removeRectWithPoint:lPoint]) {
                        UIButton *lMarkButton = [mArrayOfMarkButtons objectAtIndex:[mArrayOfDeleteButtons indexOfObject:lRemoveButton]];
                        [lMarkButton setTag:GSButtonTypeMark];
                        break;
                    }
                }
            }
        }
        
        for (NSInteger index = mArrayOfElements.count-1; index >= 0; index--) {
            GSInstagramElement *lInstagramElement = [mArrayOfElements objectAtIndex:index];
            if (lInstagramElement.arrayOfRects.count == 0) {
                [lInstagramElement removeFromSuperview];
                [mArrayOfElements removeObject:lInstagramElement];
            } else {
                [self adjustElementSize:lInstagramElement];
            }
        }
    }
    
    //call only at the end of this method
    [self deselectElement];
    
    mIsAddState = NO;
    mIsRemoveState = NO;
}


- (void) GSInstagramBottomMenuCancelPressed {    
    if (mIsAddState) {
        [self resetAddChanges];
    }
    
    if (mIsRemoveState) {
        [self deleteRemoveButtons];
        
        if (mCurrentElement != nil) {
            mIsAddState = YES;
            [self addPlusButtonsToElement:mCurrentElement];
        }
        
        mIsRemoveState = NO;
    }
    
    //call only at the end of this method
    [self deselectElement];
    
    mIsAddState = NO;
    mIsRemoveState = NO;
    
    [self updateControlButtonsStates];
    

}

- (void) GSInstagramBottomMenuCameraPressed {
    if ([self isSelectedSquare] || (mCurrentElement != nil)) {
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        [self presentViewController:imagePickerController animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please select the squares you want to load a picture in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) GSInstagramBottomMenuCameraRollPressed {
    if ([self isSelectedSquare] || (mCurrentElement != nil)) {
        [self openPicker];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please select the squares you want to load a picture in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }    
}

- (void) GSInstagramBottomMenuRemovePressed {
    mIsRemoveState = YES;
    [mBottomMenu setMenuState:4];
    if (mIsAddState) {
        mIsAddState = NO;
        [self removePlusButtons];
    }
    [self setMarkButtonsHidden:YES];
    [self addRemoveButtons];
}

#pragma mark - buttons methods
- (IBAction)cancelPressed:(id)sender{
    if (mIsChange == NO){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to exit and lose your progress?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        lAlert.tag = 4;
        [lAlert show];
    }
    [Flurry endTimedEvent:@"instagramGiantPressed" withParameters:nil];
}
- (IBAction)exportPressed:(id)sender{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getAllImagesToArray];
    [self saveImageWithIndex:[NSNumber numberWithInteger:0]];
    [Flurry logEvent:@"exportPressed"];
}

- (IBAction)helpPressed:(id)sender{
    GSTutorialOverlayView *lHelp = [[GSTutorialOverlayView alloc] initWithFrame:self.view.frame andType:GSTutorialTypeInstagram];
    lHelp.delegate = self;
    [self.view addSubview:lHelp];
    [lHelp loadTutorial];    
}

#pragma mark - PhotoPickerPlusDelegate
- (void)photoImagePickerControllerDidCancel:(PhotoPickerViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    outputImage = [outputImage getScaledImageFromHQ];
    
    if (mCurrentElement != nil) {
        [mCurrentElement setImage:outputImage];
    } else {
        [self addElementWithImage:outputImage];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil) {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    outputImage = [outputImage getScaledImageFromHQ];
    
    if (mCurrentElement != nil) {
        [mCurrentElement setImage:outputImage];
    } else {
        [self addElementWithImage:outputImage];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

#pragma mark - GSInstagramElement delegate -
- (void)touchedOnEmtpySpace:(UIEvent *)pEvent point:(CGPoint)pTouchedPoint tag:(NSInteger)pTag {
    DLog(@"touched point: %@", NSStringFromCGPoint(pTouchedPoint));
    DLog(@"tag %i", pTag);
    
    UIView *lView = [self.view viewWithTag:pTag];
    [self.view sendSubviewToBack:lView];
}

//- (void) animationStart {
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3f];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    
//    mBottomMenu.center = CGPointMake(self.view.frame.size.width/2 , mAdView.frame.origin.y - mAdView.frame.size.height + 10);
//    mIsBannerAppear = YES;
//    [UIView commitAnimations];
//    
//}

#pragma mark - MPAdViewDelegate methods
- (void) animationStart {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    mIsBannerAppear = YES;
    
    [mAdView setFrame:CGRectMake(0.0, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    [UIView commitAnimations];
    
}

- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view {
    
    if (mIsBannerAppear == NO){
        [mAdView setFrame:CGRectMake(0.0, self.view.bounds.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        BOOL isAdded = NO;
        for (UIView *lView in [self.view subviews]) {
            if (lView.tag == 999) {
                [self.view insertSubview:mAdView belowSubview:lView];
                isAdded = YES;
            }
        }
        if (!isAdded) {
            [self.view addSubview:mAdView];    
        }
        
        [self animationStart];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}


#pragma mark - GSTutorialOverlayView Delegate
- (void)viewExamplesPressed{
    GSInspirationViewController *lViewController = [[GSInspirationViewController alloc] initWithNibName:@"GSInspirationViewController" bundle:nil andMode:GSTutorialTypeInstagram];
    [lViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:lViewController animated:YES];
    lViewController.backButton.hidden = YES;

}


@end
