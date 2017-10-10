//
//  GSFacebookLoginView.m
//  GiantSquare
//
//  Created by roman.andruseiko on 3/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSFacebookLoginView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GSFacebookLoginView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)loadWebView{
    mAttemptsCount = 0;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    mFacebook = [[GSFacebookLoginWebView alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 20)];
    [mFacebook startLoadingWithClientId];
    mFacebook.authDelegate = self;
    
    [mFacebook.layer setCornerRadius:5.0f];
    [mFacebook.layer setMasksToBounds:YES];
    
    [self addSubview:mFacebook];
    
    UIButton *lCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 26, 1, 25, 25)];
    [lCloseButton setBackgroundColor:[UIColor clearColor]];
    [lCloseButton setImage:[UIImage imageNamed:@"facebookWebViewCloseButton.png"] forState:UIControlStateNormal];
    [lCloseButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lCloseButton];
}

- (void)facebookAuthSucceeded:(NSString*)token{
    if (delegate) {
        [delegate facebookAuthSucceeded:token];
    }
//    mFacebook.authDelegate = nil;
    [self removeFromSuperview];
}

- (void)facebookAuthFailed:(NSString*)error
               errorReason:(NSString*)errorReason
          errorDescription:(NSString*)errorMessage{
    if (delegate) {
        [delegate facebookAuthFailed:error
                         errorReason:errorReason
                    errorDescription:errorMessage];
    }
//    mFacebook.authDelegate = nil;
    [self removeFromSuperview];
}

- (void)facebookAuthLoadFailed:(NSError*)error{

    if (mAttemptsCount < 4) {
        mAttemptsCount++;
        [mFacebook performSelector:@selector(startLoadingWithClientId) withObject:nil afterDelay:0.5f];
    }else{
        if (delegate) {
            [delegate facebookAuthLoadFailed:error];
        }
        mFacebook.authDelegate = nil;
        [self removeFromSuperview];
        
    }
}

- (void)closePressed{
    if (delegate) {
        [delegate facebookAuthCancelled];
    }
    mFacebook.authDelegate = nil;
    [self removeFromSuperview];
}

@end
