//
//  GCServiceAsset.m
//  GetChute
//
//  Created by Aleksandar Trpeski on 3/26/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCServiceAsset.h"
#import "GCClient.h"
#import "GCAsset.h"
#import "GCResponse.h"

@implementation GCServiceAsset

static NSString * const kGCPerPage = @"per_page";
static NSString * const kGCDefaultPerPage = @"100";

+ (void)getAssetsForAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *responseStatus, NSArray *assets, GCPagination *pagination))success failure:(void (^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"albums/%@/assets", albumID];
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientGET path:path parameters:@{kGCPerPage:kGCDefaultPerPage}];
    
    [apiClient request:request factoryClass:[GCAsset class] success:^(GCResponse *response) {
        success(response.response, response.data, response.pagination);
    } failure:failure];
}

+ (void)getAssetsWithSuccess:(void (^)(GCResponseStatus *responseStatus, NSArray *assets, GCPagination *pagination))success failure:(void (^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = @"assets";
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientGET path:path parameters:@{kGCPerPage:kGCDefaultPerPage}];
    
    [apiClient request:request factoryClass:[GCAsset class] success:^(GCResponse *response) {
        success(response.response, response.data, response.pagination);
    } failure:failure];
}
////////////////////////////////  THESE ARE THE ONES I'VE ADDED  ////////////////////////////////
+ (void)getAssetWithID:(NSNumber *)assetID success:(void (^)(GCResponseStatus *responseStatus, GCAsset *asset))success failure:(void (^)(NSError *error))failure
{
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"assets/%@",assetID];

    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientGET path:path parameters:nil];
    
    [apiClient request:request factoryClass:[GCAsset class] success:^(GCResponse *response) {
        success(response.response, response.data);
    } failure:failure];
}

+ (void)getAssetWithID:(NSNumber *)assetID fromAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *responseStatus, GCAsset *asset))success failure:(void (^)(NSError *error))failure
{
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"albums/%@/assets/%@", albumID, assetID];
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientGET path:path parameters:nil];
    
    [apiClient request:request factoryClass:[GCAsset class] success:^(GCResponse *response) {
        success(response.response, response.data);
    } failure:failure];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)importAssetsFromURLs:(NSArray *)urls success:(void (^)(GCResponseStatus *responseStatus, NSArray *assets, GCPagination *pagination))success failure:(void (^)(NSError *error))failure {
    
    [self importAssetsFromURLs:urls forAlbumWithID:nil success:^(GCResponseStatus *response, NSArray *assets, GCPagination *pagination) {
        success(response, assets, pagination);
    } failure:failure];
    
}

+ (void)importAssetsFromURLs:(NSArray *)urls forAlbumWithID:(NSNumber *)albumID success:(void (^)(GCResponseStatus *repsonseStatus, NSArray *assets, GCPagination *pagination))success failure:(void (^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path;
    
    if (albumID != nil)
        path = [NSString stringWithFormat:@"albums/%@/assets/import", albumID];
    else
        path = @"assets/import";
    
    NSDictionary *params = @{@"urls":urls};
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientPOST path:path parameters:params];
    
    [apiClient request:request factoryClass:[GCAsset class] success:^(GCResponse *response) {
        success(response.response, response.data, response.pagination);
    } failure:failure];
}

+ (void)updateAssetWithID:(NSNumber *)assetID caption:(NSString *)caption success:(void (^)(GCResponseStatus *responseStatus, GCAsset *asset))success failure:(void (^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"assets/%@", assetID];
    
    /*
     GCAlbum *album = [GCAlbum new];
     [album setName:name];
     [album setModerateMedia:moderateMedia];
     [album setModerateComments:moderateComments];
     
     DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[GCAlbum class]];
     
     NSDictionary *params = [mapping serializeObject:album];
     */
    
    NSDictionary *params = @{@"caption":caption};
    
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientPUT path:path parameters:params];
    
    [apiClient request:request factoryClass:[GCAsset class] success:^(GCResponse *response) {
        success(response.response, response.data);
    } failure:failure];
}

+ (void)deleteAssetWithID:(NSNumber *)assetID success:(void (^)(GCResponseStatus *responseStatus))success failure:(void (^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"assets/%@", assetID];
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientDELETE path:path parameters:nil];
    
    [apiClient request:request factoryClass:nil success:^(GCResponse *response) {
        success(response.response);
    } failure:failure];
}


+ (void)getGeoCoordinateForAssetWithID:(NSNumber *)assetID success:(void (^)(GCResponseStatus *responseStatus, GCCoordinate *coordinate))success failure:(void (^)(NSError *error))failure {
    
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"assets/%@/geo", assetID];
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientGET path:path parameters:nil];
    
    [apiClient request:request factoryClass:nil success:^(GCResponse *response) {
        success(response.response, response.data);
    } failure:failure];
}

+ (void)getAssetsForCentralCoordinate:(GCCoordinate *)coordinate andRadius:(NSNumber *)radius success:(void (^)(GCResponseStatus *responseStatus, NSArray *assets, GCPagination *pagination))success failure:(void (^)(NSError *error))failure {
    
    GCClient *apiClient = [GCClient sharedClient];
    
    NSString *path = [NSString stringWithFormat:@"assets/geo/%@,%@/%@", coordinate.latitude, coordinate.longitude, radius];
    
    NSMutableURLRequest *request = [apiClient requestWithMethod:kGCClientGET path:path parameters:@{kGCPerPage:kGCDefaultPerPage}];
    
    [apiClient request:request factoryClass:nil success:^(GCResponse *response) {
        success(response.response, response.data, response.pagination);
    } failure:failure];
}


@end
