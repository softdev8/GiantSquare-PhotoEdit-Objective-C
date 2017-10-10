//
//  GSFacebookLoginWebView.h
//  GiantSquare
//
//  Created by roman.andruseiko on 3/19/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//


@protocol GSFacebookLoginWebViewDelegate;


@interface GSFacebookLoginWebView : UIWebView <UIWebViewDelegate>{
}

@property (nonatomic, assign) id<GSFacebookLoginWebViewDelegate> authDelegate;

// Starts loading the authentication page
- (void)startLoadingWithClientId;

@end

@protocol GSFacebookLoginWebViewDelegate <NSObject>


- (void)facebookAuthSucceeded:(NSString*)token;
- (void)facebookAuthFailed:(NSString*)error
                errorReason:(NSString*)errorReason 
           errorDescription:(NSString*)errorMessage;
- (void)facebookAuthLoadFailed:(NSError*)error;

@end
