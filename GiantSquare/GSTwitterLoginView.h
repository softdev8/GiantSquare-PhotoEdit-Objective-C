//
//  GSTwitterLoginView.h
//  TwitterAuth
//
//  Created by Ivan Podibka on 4/3/13.
//  Copyright (c) 2013 Ivan Podibka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"

@protocol GSTwitterLoginViewDelegate <NSObject>
- (void)didReceiveOAuthAccessToken:(OAToken *)token;
- (void)didFailOAuthWithError:(NSError *)error;
- (void)didTwitterCancelPressed;
@end

@interface GSTwitterLoginView : UIView <UIWebViewDelegate> {
    OAConsumer *mConsumer;
    OAToken *mRequestToken;
    OAToken *mAccessToken;
}

@property (nonatomic, assign) id <GSTwitterLoginViewDelegate> delegate;

- (void)startAuthorization;

@end
