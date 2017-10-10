//
//  GSCustomNavigationController.m
//  GiantSquare
//
//  Created by roman.andruseiko on 2/8/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSCustomNavigationController.h"

@interface GSCustomNavigationController ()

@end

@implementation GSCustomNavigationController

@synthesize isPortrait=mIsPortrait;

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    if (mIsPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskLandscape;
    }
    
}

@end
