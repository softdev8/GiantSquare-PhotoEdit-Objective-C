//
//  GSCustomNavigationController.h
//  GiantSquare
//
//  Created by roman.andruseiko on 2/8/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSCustomNavigationController : UINavigationController{
    BOOL mIsPortrait;
}

@property (nonatomic, readwrite) BOOL isPortrait;

@end
