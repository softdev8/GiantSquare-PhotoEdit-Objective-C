//
//  GSFacebookAccountSelectContainer.h
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/22/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSFacebookAccountSelectContainer : NSObject {
    NSString *mUserID;
    NSString *mUserName;
    BOOL isActive;
}

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, readwrite) BOOL active;
@end
