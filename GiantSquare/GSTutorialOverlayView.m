//
//  GSTutorialOverlayView.m
//  GiantSquare
//
//  Created by roman.andruseiko on 4/13/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSTutorialOverlayView.h"

#define BUTTON_WIDTH 175
#define BUTTON_HEIGHT 45

@implementation GSTutorialOverlayView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andType:(NSInteger)pType{
    self = [super initWithFrame:frame];
    if (self) {
        mCurrentType = pType;
        self.backgroundColor = [UIColor clearColor];
        self.tag = 999;

    }
    return self;
}

- (void)loadTutorial{
    UIImage *lImage = nil;
    switch (mCurrentType) {
        case GSTutorialTypeFacebook:{
            lImage = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"facebookCoverTutorial.png", @"facebookCoverTutorial_iPhone5.png")];
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            [lExampleButton setCenter:CGPointMake(lExampleButton.frame.size.width/2 + 15, self.frame.size.height - lExampleButton.frame.size.height/2 - 15)];
            [self addSubview:lExampleButton];
        }
            break;
        case GSTutorialTypeFacebookCollage:{
            lImage = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"facebookCollageTutorial.png", @"facebookCollageTutorial_iPhone5.png")];
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            [lExampleButton setCenter:CGPointMake(lExampleButton.frame.size.width/2 + 15, self.frame.size.height - lExampleButton.frame.size.height/2 - 15)];
            [self addSubview:lExampleButton];
        }
            break;
        case GSTutorialTypeFacebookAfterPublish:{
            lImage = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"facebookAfterPublishTutorial.png", @"facebookAfterPublishTutorial_iPhone5.png")];
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH + 70, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            [lExampleButton setCenter:CGPointMake(self.frame.size.width - lExampleButton.frame.size.width/2 - 15, self.frame.size.height - lExampleButton.frame.size.height/2 - 15)];
            [self addSubview:lExampleButton];
        }
            break;
        case GSTutorialTypeTwitterCollage:{
            lImage = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"facebookCollageTutorial.png", @"facebookCollageTutorial_iPhone5.png")];
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            [lExampleButton setCenter:CGPointMake(lExampleButton.frame.size.width/2 + 15, self.frame.size.height - lExampleButton.frame.size.height/2 - 15)];
            [self addSubview:lExampleButton];
        }
            break;
        case GSTutorialTypeInstagramCollage:{
            lImage = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"instagramCollageTutorial.png", @"instagramCollageTutorial_iPhone5.png")];
            
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 104.0, BUTTON_WIDTH, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:lExampleButton];
        }
            break;

        case GSTutorialTypeTwitter:{
            lImage = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"twitterTutorialOverlay.png", @"twitterTutorialOverlay_iPhone5.png")];
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            if (self.frame.size.height > 480 || self.frame.size.width > 480) {
                [lExampleButton setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height - lExampleButton.frame.size.height/2 - 50)];
            }else{
                [lExampleButton setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height - lExampleButton.frame.size.height/2 - 20)];
            }
            [self addSubview:lExampleButton];
            
        }
            break;
            
        case GSTutorialTypeInstagram:{
            mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [mScrollView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:mScrollView];
            
            UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [lImageView setImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"instagramTutorialOverlayPage0.png", @"instagramTutorialOverlayPage0_iPhone5.png")]];
            [mScrollView addSubview:lImageView];
            
            UIImageView *lImageViewOne = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
            [lImageViewOne setImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"instagramTutorialOverlayPage1.png", @"instagramTutorialOverlayPage1_iPhone5.png")]];
            [mScrollView addSubview:lImageViewOne];
            
            UIImageView *lImageViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height)];
            [lImageViewTwo setImage:[UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"instagramTutorialOverlayPage2.png", @"instagramTutorialOverlayPage2_iPhone5.png")]];
            [mScrollView addSubview:lImageViewTwo];

            mScrollView.contentSize = CGSizeMake(mScrollView.frame.size.width*3, mScrollView.frame.size.height);
            mScrollView.showsHorizontalScrollIndicator = NO;
            mScrollView.pagingEnabled = YES;
            mScrollView.delegate = self;

            UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width*3, self.frame.size.height)];
            lButton.backgroundColor = [UIColor clearColor];
            [lButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
            [mScrollView addSubview:lButton];
            
            
            mPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 130, self.frame.size.width, 80)];
            mPageControl.numberOfPages = 3;
            mPageControl.currentPage = 0;
            mPageControl.userInteractionEnabled = NO;
            [self addSubview:mPageControl];
            
            UIButton *lExampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
            lExampleButton.backgroundColor = [UIColor clearColor];
            [lExampleButton addTarget:self action:@selector(viewExamplesPressed) forControlEvents:UIControlEventTouchUpInside];
            [lExampleButton setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height - lExampleButton.frame.size.height/2 - 10)];
            [mScrollView addSubview:lExampleButton];
            
            
            
        }
            break;
            
        case GSTutorialTypeMainScreen:{
            mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [mScrollView setBackgroundColor:[UIColor clearColor]];
            [self addSubview:mScrollView];
            
            UIImage *lImage = [UIImage imageNamed:@"homeOverlay.png"];
            
            UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, lImage.size.height)];
            [lImageView setImage:lImage];
            [mScrollView addSubview:lImageView];

            mScrollView.contentSize = CGSizeMake(mScrollView.frame.size.width, lImage.size.height);
            mScrollView.showsHorizontalScrollIndicator = NO;
            
            UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, lImage.size.height)];
            lButton.backgroundColor = [UIColor clearColor];
            [lButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
            [mScrollView addSubview:lButton];            
        }
            break;

        default:
            break;
    }
    
    if (mCurrentType != GSTutorialTypeInstagram) {
        UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        lButton.backgroundColor = [UIColor clearColor];
        [lButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lButton];
        UIImageView *lImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [lImageView setImage:lImage];
        [self addSubview:lImageView];
        [self sendSubviewToBack:lButton];
        [self sendSubviewToBack:lImageView];
    }
}

- (void)viewExamplesPressed{
    if (self.delegate) {
        [self.delegate viewExamplesPressed];
    }
}

- (void)closePressed{
    [self removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = mScrollView.frame.size.width;
    int page = floor((mScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    mPageControl.currentPage = page;
}


@end
