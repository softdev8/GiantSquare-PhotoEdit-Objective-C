//
//  GSFacebookSelectAccountViewController.h
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFacebookLoginView.h"

@class GSDatabaseWrapper;

@interface GSFacebookSelectAccountViewController : GSAbstractViewController <UITableViewDataSource, UITableViewDelegate, GSFacebookLoginViewDelegate>{
    
    IBOutlet UITableView *mTableView;
    IBOutlet UIButton *mPublishButton;
    NSMutableArray *mDataSource;
    
    UISwitch *mCellSwitch;
    UIImage *mSharingImage;
    UIImage *mSecondSharingImage;
    GSDatabaseWrapper *mDatabaseWrapper;
    
    BOOL isSingelSharing;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage andImage:(UIImage*)pSecondImage;

@end
