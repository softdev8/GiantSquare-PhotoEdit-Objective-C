//
//  GCOAuth2.m
//  GetChute
//
//  Created by Aleksandar Trpeski on 4/11/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCOAuth2Client.h"
#import "AFJSONRequestOperation.h"
#import "NSDictionary+QueryString.h"
#import "GCClient.h"

static NSString * const kGCBaseURLString = @"https://getchute.com";

static NSString * const kGCScope = @"scope";
static NSString * const kGCScopeDefaultValue = @"all_resources manage_resources profile resources";
static NSString * const kGCType = @"type";
static NSString * const kGCTypeValue = @"web_server";
static NSString * const kGCResponseType = @"response_type";
static NSString * const kGCResponseTypeValue = @"code";
static NSString * const kGCRedirectURI = @"redirect_uri";
static NSString * const kGCRedirectURIDefaultValue = @"http://getchute.com/oauth/callback";

static NSString * const kGCOAuth = @"oauth";

static NSString * kGCServices[] = {
    @"facebook",
    @"instagram",
    @"skydrive",
    @"googledrive",
    @"google",
    @"picasa",
    @"flickr",
    @"twitter",
    @"chute",
    @"foursquare",
    @"dropbox"
};

static NSString * kGCLoginMethods[] = {
    @"facebook",
    @"instagram",
    @"microsoft_account",
    @"google",
    @"google",
    @"google",
    @"flickr",
    @"twitter",
    @"chute",
    @"foursquare",
    @"dropbox"
};

int const kGCServicesCount = 11;

NSString * const kGCClientID = @"client_id";
NSString * const kGCClientSecret = @"client_secret";
NSString * const kGCCode = @"code";
NSString * const kGCGrantType = @"grant_type";
NSString * const kGCGrantTypeValue = @"authorization_code";

@implementation GCOAuth2Client

+ (instancetype)clientWithBaseURL:(NSURL *)url {
    NSAssert(NO, @"GCOAuth2Client instance cannot be generated with this method.");
    return nil;
}

+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret {
    return [self clientWithClientID:_clientID clientSecret:_clientSecret redirectURI:kGCRedirectURIDefaultValue scope:kGCScopeDefaultValue];
}

+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret redirectURI:(NSString *)_redirectURI {
    return [self clientWithClientID:_clientID clientSecret:_clientSecret redirectURI:_redirectURI scope:kGCScopeDefaultValue];
}

+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret scope:(NSString *)_scope {
    return [self clientWithClientID:_clientID clientSecret:_clientSecret redirectURI:kGCRedirectURIDefaultValue scope:_scope];
}

+ (instancetype)clientWithClientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret redirectURI:(NSString *)_redirectURI scope:(NSString *)_scope {
    return [[GCOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:kGCBaseURLString] clientID:_clientID clientSecret:_clientSecret redirectURI:_redirectURI scope:_scope];
}

- (id)initWithBaseURL:(NSURL *)url clientID:(NSString *)_clientID clientSecret:(NSString *)_clientSecret redirectURI:(NSString *)_redirectURI scope:(NSString *)_scope {
    
    NSParameterAssert(_clientID);
    NSParameterAssert(_clientSecret);
    NSParameterAssert(_redirectURI);
    NSParameterAssert(_scope);
    
    self = [super initWithBaseURL:url];
    
    if (!self) {
        return nil;
    }
    
    clientID = _clientID;
    clientSecret = _clientSecret;
    redirectURI = _redirectURI;
    scope = _scope;
    
//    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        if (status == AFNetworkReachabilityStatusNotReachable) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No Internet connection detected." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//        }
//    }];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [self setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    return self;
}

- (void)verifyAuthorizationWithAccessCode:(NSString *)code success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSDictionary *params = @{
                             kGCClientID:clientID,
                             kGCClientSecret:clientSecret,
                             kGCRedirectURI:redirectURI,
                             kGCCode:code,
                             kGCGrantType:kGCGrantTypeValue,
                             };
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientPOST path:@"oauth/token" parameters:params];
        
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){

        [apiClient setAuthorizationHeaderWithToken:[JSON objectForKey:@"access_token"]];
        success();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];
}

- (NSURLRequest *)requestAccessForService:(GCService)service {
    
    NSDictionary *params = @{
                             kGCScope:@"",
                             kGCResponseType:kGCResponseTypeValue,
                             kGCClientID:clientID,
                             kGCRedirectURI:kGCRedirectURIDefaultValue,
                             };

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://getchute.com/v2/oauth/%@/authorize?%@",
                                                                               kGCLoginMethods[service],
                                                                               [params stringWithFormEncodedComponents]]]];
    [self clearCookiesForService:service];
    return request;
}

- (void)clearCookiesForService:(GCService)service {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSHTTPCookie *cookie = obj;
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:kGCServices[service]];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }];
}

+ (NSString *)serviceString:(GCService)service
{
    if (service >= kGCServicesCount)
        return @"";
    return kGCServices[service];
}

+ (GCService)serviceForString:(NSString *)serviceString
{
    for (int i = 0; i < kGCServicesCount; i++) {
        if ([serviceString isEqualToString:kGCServices[i]]) {
            return i;
        }
    }
    return nil;
}

+ (NSString *)loginMethodForService:(GCService)service
{
    if (service >= kGCServicesCount)
        return @"";
    return kGCLoginMethods[service];
}

+ (GCService)serviceForLoginMethod:(NSString *)loginMethod
{
    for (int i = 0; i < kGCServicesCount; i++) {
        if ([loginMethod isEqualToString:kGCLoginMethods[i]]) {
            return i;
        }
    }
    return nil;
}

@end
