//
//  GSInstagramCollageViewController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/15/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSCollageViewController.h"
#import "CHYSlider.h"
#define OFFSET_SCALE_LVL        18.f
#define OFFSET_DEVICE           88.f
#define PHOTO_HEIGHT_IPHONE4    281.f
#define PHOTO_HEIGHT_IPHONE5    369.f
#define PHOTO_WIDTH             320.f
#define RATIO_IPHONE5           0.872f
#define RATIO_IPHONE4          1.147f
#define SLIDERVIEW_HEIGHT       45.f
#define KEYBOARD_HEIGHT         216.f
#define HEIGHT_PHONE4           480.f
#define HEIGHT_PHONE5           568.f
#define HEIGHT_TEXTVIEW         45.f
#define HEIGHT_COLLAGE          66.f
#define FONT_SIZE               14.5f
#define KEY_TEXT                @"TEXT"
#define KEY_VIEW                @"VIEW"
#define KEY_FONT                @"FONT"
#define KEY_COLOR               @"COLOR"
#define KEY_STR                 @"STRING"
#define KEY_TAG                 @"TAG"
#define KEY_FSIZE               @"FSIZE"
#define KEY_FREE_FONT           @"FREEFONT"
#define KEY_ROTATE              @"ROTATE"
#define FONTVIEW_FRAME_SHOW4   CGRectMake(160.f, 0.f, 160.f, 480.f)
#define FONTVIEW_FRAME_SHOW5   CGRectMake(160.f, 0.f, 160.f, 568.f)
#define FONTVIEW_FRAME_HIDE4   CGRectMake(320.f, 0.f, 160.f, 480.f)
#define FONTVIEW_FRAME_HIDE5   CGRectMake(320.f, 0.f, 160.f, 568.f)
#define isPhone5               ([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO


@interface GSInstagramTextSquareViewController : GSCollageViewController<PhotoPickerViewControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,GSBuyPopupViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate>  {
    BOOL mFirstChange;
    float mScale;
    float mMaxScale;
    float mMinScale;
    float r,g,b;
    CGPoint mLastAnchorPoint;
    CGSize mImageSize;
    BOOL                  isPhoto;
    IBOutlet UIImageView *m_btnScaleLvl1;
    IBOutlet UIImageView *m_btnScaleLvl2;
    IBOutlet UIImageView *m_btnScaleLvl3;
    IBOutlet UIButton *m_btnFixed;
    __unsafe_unretained IBOutlet CHYSlider *m_slBrightness;
    IBOutlet UIButton *m_btnShare;
    IBOutlet UIView   *m_sliderView;
    IBOutlet UIButton *m_btnScaling;
    IBOutlet UIButton *m_bgColor;
    IBOutlet UIImageView   *m_colorPickerBack;
    IBOutlet UIImageView *overideView;
    IBOutlet UIImageView *backgroundView;
    IBOutlet UIButton    *blackSwatchButton;
    IBOutlet UIButton    *whiteSwatchButton;
    IBOutlet UIImageView *bottomView;
#pragma ADD TEXT------------------------//
    IBOutlet UIView      *m_textControlPanel;
    IBOutlet UIButton    *m_fontBtn;
    IBOutlet UIButton    *m_transparencyBtn;
    IBOutlet UIButton    *m_colorPickerBtn;
    IBOutlet UIButton    *m_doneBtn;
    IBOutlet UITextView  *m_textView;
    IBOutlet UITableView *m_fontPanel;
    IBOutlet UIImageView *fontViewIamge;
    IBOutlet UIButton    *m_textColorBtn;
    IBOutlet UIView      *m_txtSliderView;
    __unsafe_unretained IBOutlet CHYSlider *m_slTextTransparency;
    CGRect                m_tmpFrame;
    int                   tTag;
    int                   tmpTag;
    UIImageView               *m_curTextView;
    UITextView           *m_txtView;
    NSMutableArray       *fontArray;
    NSMutableArray       *m_textArray;
    
    BOOL                 *isText;
    BOOL                 *isFont;
    BOOL                 *isTransparency;
    BOOL                 *isColorPicker;
    BOOL                 *isFixText;
    
    NSString             *m_strFontName;
    NSString             *m_strFont;
    NSString             *m_currentFont;
    float                tr,tg,tb;
    NSString             *m_fsize;
    UIColor              *textColor;
    UIColor              *m_tmpColor;
    NSDictionary         *m_curTextDic;
    int                  *m_freeCountFont;
    int                   vTag;
    GSBuyPopupView       *m_buyFontView;
    int                   nTextRotateCnt;
    CGSize               m_txtPinchSize;
    NSIndexPath          *m_oldFontIndexPath;
    IBOutlet UIButton    *m_txtDeleteBtn;
    IBOutlet UIImageView          *m_indiFont;
    IBOutlet UIImageView          *m_indiRotate;
    IBOutlet UIImageView          *m_indiBrightness;
    IBOutlet UIImageView          *m_indiColorPicker;
    IBOutlet UIImageView          *m_indiDone;
    
    
#pragma END ADD TEXT-------------------//
    UIImage *m_pScaleLvlActive;
    UIImage *m_pScaleLvlInActive;
    UIImage *m_pScaleLvlInactive;
    int m_nScaleLvl;
    BOOL isFixed;
    
    CGRect   m_originalPortraitRect;
    CGRect   m_originalLandscapeRect;
    BOOL     isFirst;
    BOOL     isShowColorPicker;
    
    UIImage  *outputImage;
}
@property (strong, nonatomic) IBOutlet UIImageView *m_workView;
@property (strong, nonatomic) UIImageView *m_cmImage;
@property (nonatomic, readwrite) CGRect  m_cmRect;
@property (nonatomic, readwrite) CGRect  m_originalRect;
@property (nonatomic, retain)    UIImage *m_originalImage;
@property (strong, nonatomic) IBOutlet UIView *mBottomView;
@property (nonatomic,retain) NSMutableArray *m_squareColorArray;
@property (nonatomic, retain) UIColor *cmBgColor;
@property (nonatomic, readwrite) int m_nRotateCnt;

- (void)openCameraRoll;
- (void)showiOS5Alert;
- (void) setImageWithArrayInfo:(NSArray *) info;
- (IBAction)rotatePicture:(id)sender;
- (IBAction)fixScaling:(id)sender;
- (IBAction)FixImage:(id)sender;
- (IBAction)changedSlider:(CHYSlider *)slider;
- (IBAction)shareImage:(id)sender;
- (IBAction)resetImage:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)blackSwatch:(id)sender;
- (IBAction)whiteSwatch:(id)sender;
- (IBAction)showHideColorPicker:(id)sender;
- (IBAction)addText:(id)sender;

#pragma ADD TEXT------------------------//
- (IBAction)fontBtnClicked:(id)sender;
- (IBAction)transparencyBtnClicked:(id)sender;
- (IBAction)colorPickerBtnClicked:(id)sender;
- (IBAction)doneBtnClicked:(id)sender;
- (IBAction)rotateText:(id)sender;
- (IBAction)deleteText:(id)sender;
- (IBAction)changeTextSlider:(id)sender;
#pragma END ADD TEXT-------------------//

- (void) setTransition:(CGPoint)pPoint;
- (CGRect) getImageRect:(float)w height:(float) h;
- (UIImage *) getImageFromColor:(UIColor *)color;

@end
