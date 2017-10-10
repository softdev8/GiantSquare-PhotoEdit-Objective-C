//
//  GSTwitterCollageViewController.h
//  GiantSquare
//
//  Created by Volodymyr Shevchyk jr. on 5/16/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSCollageViewController.h"
#import "GSTwitterLoginView.h"

@interface GSTwitterCollageViewController : GSCollageViewController <GSTwitterLoginViewDelegate> {
    IBOutlet UIImageView *mHeaderImageView;
    IBOutlet UIView *mMainView;
    
    GSTwitterLoginView *mTwitterLogin;
}

@end
