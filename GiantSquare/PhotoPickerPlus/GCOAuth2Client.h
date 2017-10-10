//
//  GCOAuth2.h
//  GetChute
//
//  Created by Aleksandar Trpeski on 4/11/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "AFHTTPClient.h"

typedef enum {
    GCServiceFacebook,
    GCServiceInstagram,
    GCServiceSkydrive,
    GCServiceGoogleDrive,
    GCServiceGooglePlus,
    GCServicePicasa,
    GCServiceFlickr,
    GCServiceTwitter,
    GCServiceChute,
    GCServiceFoursquare,
    GCServiceDropbox
} GCService;

@interface GCOAuth2Client : AFHTTPClient {
    NSString *clientID;
    NSString *clientSecret;
    NSString *redirectURI;
    NSString *scope;
}

extern NSString * const kGCClientID;
extern NSString * const kGCClientSecret;
extern int const kGCServicesCount;

@property (strong, nonatomic) NSArray *gcServices;

+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret;
+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret redirectURI:(NSString *)_redirectURI;
+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret scope:(NSString *)_scope;
+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret redirectURI:(NSString *)_redirectURI scope:(NSString *)_scope;

+ (NSString *)serviceString:(GCService)service;
+ (GCService)serviceForString:(NSString *)serviceString;

+ (NSString *)loginMethodForService:(GCService)service;
+ (GCService)serviceForLoginMethod:(NSString *)loginMethod;

- (NSURLRequest *)requestAccessForService:(GCService)service;
- (void)verifyAuthorizationWithAccessCode:(NSString *)code success:(void(^)(void))success failure:(void(^)(NSError *error))failure;

@end
