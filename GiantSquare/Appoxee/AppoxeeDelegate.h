/*
 *  AppoxeeDelegate.h
 *  AppoxeeTest
 *
 *  Created by sivori on 8/5/10.
 *  Copyright 2010 Appoxee. All rights reserved.
 *
 */

@protocol AppoxeeDelegate <NSObject>

//Return the Appoxee SDK string
- (NSString *) AppoxeeDelegateAppSDKID;

//Return the Appoxee SDK string
- (NSString *) AppoxeeDelegateAppSecret;

@optional
//Do whatever you want... the Appoxee is has been closed
- (void) AppoxeeDelegateReciveAppoxeeClosed;

//Appoxee recieved a new message by push and want to open it. Make sure that the appoxee's view controller is visiable.
- (void) AppoxeeDelegateReciveAppoxeeRequestFocus;

//A new badge is ready for the Appoxee. The badge is the number of unread messages waiting for the user
- (void) AppoxeeNeedsToUpdateBadge:(int)badgeNum hasNumberChanged:(BOOL)hasNumberChanged;

//Return YES for every orientation you wish the appoxee client to rotate (defualt is just UIInterfaceOrientationPortrait)
- (BOOL)shouldAppoxeeRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

//This method is called when the user receives a push notification alert, click on it and the message contain custom parameter.
//The userInfo dictionary contains the the custom parametrs.
//If this push doesn't contain additional parametrs, this method won't call.
- (void)appDidOpenFromPushNotification:(NSDictionary *)userInfo;

@end