//
//  AppoxeeMessage.h
//  AppBoxTest
//
//  Created by Kfir Schindelhaim on 6/4/12.
//  Copyright (c) 2012 Appoxee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPOXEE_DATE_FORMATTER @"yyyy-MM-dd'T'HH:mm:ss"

@interface AppoxeeMessage : NSObject

/* Message Header */
@property (retain, nonatomic) NSString  *messageHeader;
/* Message Description */
@property (retain, nonatomic) NSString  *messageDescription;
/* Message Group ID is the identifier of the message */
@property (retain, nonatomic) NSString  *messageGroupID;
/* Message Type (Regulr or Persistent) */
@property (retain, nonatomic) NSString  *messageType;
/* Message Post Date */
@property (retain, nonatomic) NSDate    *messagePostDate;
/* Message Last Update Date */
@property (retain, nonatomic) NSDate    *messageUpdateDate;
/* True if the message already opened */
@property (nonatomic)         BOOL      isMessageOpened;

/**
 * Get message url link
 * When this method called, it's reporting to Appoxee server that the message has been opened.
 *
 * @return NSString - url link
 */
- (NSString *)getMessageLinkAndReportToServer;


@end
