//
//  GSTwitterSelectAccauntViewController.h
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "GSTwitterLoginView.h"

@class GSDatabaseWrapper;

@interface GSTwitterSelectAccauntViewController : GSAbstractViewController <UITableViewDelegate,UITableViewDataSource, MPAdViewDelegate,GSTwitterLoginViewDelegate> {
    
    NSArray *mDataSources;
    
    IBOutlet UITableView *mTableView;
    IBOutlet UIImageView *mHeaderImageView;
    
    UIImage *mSharingImage;
    UIImage *mSecondSharingImage;
    GSDatabaseWrapper *mDatabaseWrapper;
    
    MPAdView *mAdView;
    BOOL mIsBannerAppear;
    BOOL mIsCollage;
    GSTwitterLoginView *mTwitterLogin;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage andImage:(UIImage*)pSecondImage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage;
@end
