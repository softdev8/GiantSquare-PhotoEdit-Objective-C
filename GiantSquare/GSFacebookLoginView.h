//
//  GSFacebookLoginView.h
//  GiantSquare
//
//  Created by roman.andruseiko on 3/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSFacebookLoginWebView.h"

@protocol GSFacebookLoginViewDelegate;

@interface GSFacebookLoginView : UIView <GSFacebookLoginWebViewDelegate>{
    GSFacebookLoginWebView *mFacebook;
    NSInteger mAttemptsCount;
}

@property (nonatomic, assign) id<GSFacebookLoginViewDelegate> delegate;

- (void)loadWebView;

@end

@protocol GSFacebookLoginViewDelegate <NSObject>
@required
- (void)facebookAuthSucceeded:(NSString*)token;
- (void)facebookAuthFailed:(NSString*)error
               errorReason:(NSString*)errorReason
          errorDescription:(NSString*)errorMessage;
- (void)facebookAuthLoadFailed:(NSError*)error;
- (void)facebookAuthCancelled;

@end
