//
//  GCAsset.h
//  GetChute
//
//  Created by Aleksandar Trpeski on 3/23/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCLinks.h"
#import "GCAssetDimensions.h"
#import "GCAssetSource.h"
#import "GCResponseStatus.h"
#import "GCPagination.h"
#import "GCCoordinate.h"

@interface GCAsset : NSObject

@property (strong, nonatomic) NSNumber          *id;
@property (strong, nonatomic) GCLinks           *links;
@property (strong, nonatomic) NSString          *thumbnail;
@property (strong, nonatomic) NSString          *url;
@property (strong, nonatomic) NSString          *type;
@property (strong, nonatomic) NSString          *caption;
@property (strong, nonatomic) GCAssetDimensions *dimensions;
@property (strong, nonatomic) GCAssetSource     *source;
@property (strong, nonatomic) GCCoordinate      *coordinate;

@end
