//
//  GSFacebookLoginView.m
//  GiantSquare
//
//  Created by roman.andruseiko on 3/19/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//


#import "GSFacebookLoginWebView.h"
#import "NSString+QueryString.h"
#import "Global.h"

#define REDIRECT_URL @"http://www.facebook.com/connect/login_success.html"
#define SCOPE @"email,publish_actions,user_photos,user_groups,friends_groups,friends_photos,create_note,manage_pages,publish_stream,photo_upload,share_item,status_update,video_upload"

@interface GSFacebookLoginWebView()

@end

@implementation GSFacebookLoginWebView

@synthesize authDelegate;

- (id)initWithFrame:(CGRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
    }
    return self;
}

- (void)startLoadingWithClientId{
    self.delegate = self;
    
    NSString* url = [NSString stringWithFormat:@"https://m.facebook.com/dialog/oauth?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch", FACEBOOK_APPID, REDIRECT_URL, SCOPE];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    DLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    DLog(@"didFailLoadWithError ");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"should url  -  %@", [[request URL] absoluteString]);
    NSString *url = [[request URL] absoluteString];
    if ([[url lowercaseString] hasPrefix:[REDIRECT_URL lowercaseString]]) {
        // Stop loading
        self.delegate = nil;
        [self stopLoading];
        
        // Extract the token
        NSRange tokenRange = [[url lowercaseString] rangeOfString:@"#access_token="];
        if (tokenRange.location != NSNotFound) {
            // We have our token
            NSString* token = [url substringFromIndex:tokenRange.location + tokenRange.length];
            NSLog(@"Access token: %@", token);
            if (authDelegate) {
                [authDelegate facebookAuthSucceeded:token];
            }
        }
        else {
            NSDictionary* params = [url dictionaryFromQueryComponents];
            if (authDelegate) {
                [authDelegate facebookAuthFailed:[params objectForKey:@"error"]
                                      errorReason:[params objectForKey:@"error_reason"] 
                                 errorDescription:[params objectForKey:@"error_description"]];
            }
        }
        
        //clear cookies
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return NO;
    }

    return YES;
}



//- (void)webView:(UIWebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
//    if (authDelegate) {
//        [authDelegate facebookAuthLoadFailed:error];
//    }
//}

@end
