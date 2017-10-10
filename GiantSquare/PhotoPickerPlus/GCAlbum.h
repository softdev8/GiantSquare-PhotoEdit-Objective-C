//
//  GCAlbum.h
//  GetChute
//
//  Created by Aleksandar Trpeski on 2/8/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCLinks.h"
#import "GCCounter.h"
#import "GCUser.h"
#import "GCResponseStatus.h"
#import "GCPagination.h"

@interface GCAlbum : NSObject

@property (strong, nonatomic) NSNumber  *id;
@property (strong, nonatomic) GCLinks   *links;
@property (strong, nonatomic) GCCounter *counters;
@property (strong, nonatomic) NSString  *shortcut;
@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) GCUser    *user;
@property (assign, nonatomic) BOOL      moderateMedia;
@property (assign, nonatomic) BOOL      moderateComments;
@property (strong, nonatomic) NSDate    *createdAt;
@property (strong, nonatomic) NSDate    *updatedAt;
@property (strong, nonatomic) NSString  *description;

@end
