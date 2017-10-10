//
//  DBFacebookAccounts.h
//  GiantSquare
//
//  Created by roman.andruseiko on 4/3/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBFacebookAccounts : NSManagedObject

@property (nonatomic, retain) NSData * dbImage;
@property (nonatomic, retain) NSNumber * dbIndex;
@property (nonatomic, retain) NSNumber * dbIsActive;
@property (nonatomic, retain) NSString * dbName;
@property (nonatomic, retain) NSString * dbToken;
@property (nonatomic, retain) NSString * dbUserID;

@end
