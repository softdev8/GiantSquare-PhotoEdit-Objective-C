//
//  GSAbstractViewController.m
//  GiantSquare
//
//  Created by Roman Andruseiko on 10/29/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSAbstractViewController.h"

@interface GSAbstractViewController ()

@end

@implementation GSAbstractViewController

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

#pragma mark - hide status bar for iOS7
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
