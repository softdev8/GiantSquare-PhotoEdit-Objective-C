//
//  GSTwitterLoginView.m
//  TwitterAuth
//
//  Created by Ivan Podibka on 4/3/13.
//  Copyright (c) 2013 Ivan Podibka. All rights reserved.
//

#import "GSTwitterLoginView.h"
#import "sys/types.h"
#import <QuartzCore/QuartzCore.h>
#import "MBBProgressHUD.h"


#define APPLICATION_CONSUMER_KEY @"lFxjKtrwErYtjL0Pl8sXg"
#define APPLICATION_CONSUMER_SECRET @"53jwoSTF47jDjEPdRLvfUujn3W0mLNG8OCvA4pBbg"

@implementation GSTwitterLoginView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public methods -
- (void)startAuthorization {
    [MBBProgressHUD showHUDAddedTo:self animated:YES];
    
    //clear cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    
    mConsumer = [[OAConsumer alloc] initWithKey:APPLICATION_CONSUMER_KEY secret:APPLICATION_CONSUMER_SECRET];
    
    NSURL* lRequestTokenUrl = [NSURL URLWithString:@"http://api.twitter.com/oauth/request_token"];
    OAMutableURLRequest* lRequestTokenRequest = [[[OAMutableURLRequest alloc] initWithURL:lRequestTokenUrl
                                                                                consumer:mConsumer
                                                                                   token:nil
                                                                                   realm:nil
                                                                       signatureProvider:nil] autorelease];
    
    //note, that callback url (http://127.0.0.1) must be in the application settings on the dev.twitter.com
    OARequestParameter* lCallbackParam = [[[OARequestParameter alloc] initWithName:@"oauth_callback" value:@"twitter://127.0.0.1/"] autorelease];
    
    [lRequestTokenRequest setHTTPMethod:@"POST"];
    [lRequestTokenRequest setParameters:[NSArray arrayWithObject:lCallbackParam]];
    
    OADataFetcher* lDataFetcher = [[[OADataFetcher alloc] init] autorelease];
    [lDataFetcher fetchDataWithRequest:lRequestTokenRequest
                             delegate:self
                    didFinishSelector:@selector(didReceiveRequestToken:data:)
                      didFailSelector:@selector(didFailOAuth:error:)];
}

#pragma mark - OAuth routine -

- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* lHttpBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    mRequestToken = [[OAToken alloc] initWithHTTPResponseBody:lHttpBody];
    
    NSURL* lAuthorizeUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/authenticate"];
    OAMutableURLRequest* lAuthorizeRequest = [[[OAMutableURLRequest alloc] initWithURL:lAuthorizeUrl
                                                                             consumer:nil
                                                                                token:nil
                                                                                realm:nil
                                                                    signatureProvider:nil] autorelease];
    
    NSString* lOauthToken = mRequestToken.key;
    OARequestParameter* lOauthTokenParam = [[[OARequestParameter alloc] initWithName:@"oauth_token" value:lOauthToken] autorelease];
    [lAuthorizeRequest setParameters:[NSArray arrayWithObject:lOauthTokenParam]];
    
    [MBBProgressHUD hideHUDForView:self animated:YES];
    [self loadWebViewWithAuthRequest:lAuthorizeRequest];
}

- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* lHttpBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    mAccessToken = [[OAToken alloc] initWithHTTPResponseBody:lHttpBody];
    
    NSLog(@"finished retrieve access token %@", mAccessToken);
    if (self.delegate) {
        [self.delegate didReceiveOAuthAccessToken:mAccessToken];
    }
    // FINISHED!
}

- (void)didFailOAuth:(OAServiceTicket*)ticket error:(NSError*)error {
    [MBBProgressHUD hideHUDForView:self animated:YES];
    if (self.delegate) {
        [self.delegate didFailOAuthWithError:error];
    }
}

#pragma mark - UIWebView -
- (void)loadWebViewWithAuthRequest:(OAMutableURLRequest *)request {
    UIWebView* lWebView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 20)];
    [self addSubview:lWebView];
    [lWebView release];
    [lWebView.layer setCornerRadius:5.0f];
    [lWebView.layer setMasksToBounds:YES];
    
    lWebView.delegate = self;
    [lWebView loadRequest:request];
    
    UIButton *lCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 26, 1, 25, 25)];
    [lCloseButton setBackgroundColor:[UIColor clearColor]];
    [lCloseButton setImage:[UIImage imageNamed:@"facebookWebViewCloseButton.png"] forState:UIControlStateNormal];
    [lCloseButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lCloseButton];
}

#pragma mark - UIWebview delegate -

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqualToString:@"twitter"]) {
        
        // Extract oauth_verifier from URL query
        NSString* lVerifier = nil;
        NSArray* lUrlParameters = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* lParameters in lUrlParameters) {
            NSArray* lKeyValue = [lParameters componentsSeparatedByString:@"="];
            NSString* lKey = [lKeyValue objectAtIndex:0];
            
            if ([lKey isEqualToString:@"oauth_verifier"]) {
                lVerifier = [lKeyValue objectAtIndex:1];
                break;
            }
        }
        
        if (lVerifier) {
            NSURL* lAccessTokenUrl = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
            OAMutableURLRequest* lAccessTokenRequest = [[[OAMutableURLRequest alloc] initWithURL:lAccessTokenUrl
                                                                                       consumer:mConsumer
                                                                                          token:mRequestToken
                                                                                          realm:nil
                                                                              signatureProvider:nil] autorelease];
            OARequestParameter* lVerifierParam = [[[OARequestParameter alloc] initWithName:@"oauth_verifier" value:lVerifier] autorelease];
            
            [lAccessTokenRequest setHTTPMethod:@"POST"];
            [lAccessTokenRequest setParameters:[NSArray arrayWithObject:lVerifierParam]];
            
            OADataFetcher* lDataFetcher = [[[OADataFetcher alloc] init] autorelease];
            [lDataFetcher fetchDataWithRequest:lAccessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(didReceiveAccessToken:data:)
                              didFailSelector:@selector(didFailOAuth:error:)];
        } else {
            // ERROR!
        }
        
        [MBBProgressHUD showHUDAddedTo:self animated:YES];
        [webView removeFromSuperview];
        
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailOAuthWithError:)]) {
        [self.delegate didFailOAuthWithError:error];
    }
}

- (void)closePressed{
    if (self.delegate) {
        [self.delegate didTwitterCancelPressed];
    }
}


@end
