//
//  GSFacebookSelectAccauntViewController.m
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSFacebookSelectAccountViewController.h"
#import "GSFacebookAccountSelectContainer.h"
#import "SBJson.h"
#import "MBBProgressHUD.h"
#import "NSData+Base64.h"
#import <RevMobAds/RevMobAds.h>

@interface GSFacebookSelectAccountViewController ()
- (void) getPicture;
@end

@implementation GSFacebookSelectAccountViewController

#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isSingelSharing = YES;
        mSharingImage = pImage;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage andImage:(UIImage*)pSecondImage{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isSingelSharing = NO;
        mSharingImage = pImage;
        mSecondSharingImage = pSecondImage;
    }
    return self;
}

#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load background
    [self.view setBackgroundColor:[UIColor colorWithRed:21/255.0f green:21/255.0f blue:21/255.0f alpha:1.0f]];
    
    mDataSource = [NSMutableArray new];
   
    mTableView.separatorColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0];
    
    [self getGroups];
}

#pragma mark - mamory managment
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return [mDataSource count];
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 70.0f;
    }else{
        return 0.0f;
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *lFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 440, 40)];
    [lFooterView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 420, 50)];
    [lFooterLabel setBackgroundColor:[UIColor clearColor]];
    [lFooterLabel setText:@"By enabling this option all your uploads to Facebook will be posted privately on your wall to facebook so only you will be able to see them."];
    [lFooterLabel setTextAlignment:NSTextAlignmentLeft];
    [lFooterLabel setTextColor: [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f]];
    [lFooterLabel setFont:[UIFont systemFontOfSize:12.0]];
    lFooterLabel.numberOfLines = 0;
    
    [lFooterView addSubview:lFooterLabel];
    
    if (section == 1){
        return lFooterView;
    } else {
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *lCell;
    lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] ;
    
    if (indexPath.section == 0){
        GSFacebookAccountSelectContainer *lCurrentContainer = (GSFacebookAccountSelectContainer*)[mDataSource objectAtIndex:indexPath.row];
        if ([lCurrentContainer.userName isEqualToString:@"My Profile"]) {
            lCell.textLabel.text = getVal(FACEBOOK_USER_NAME);
        } else {
            lCell.textLabel.text = lCurrentContainer.userName;
        }
        
        [lCell.textLabel setTextColor:[UIColor colorWithRed:186.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f]];

        UIImageView * lImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkAccounts.png"]];
        [lImageView setFrame:CGRectMake(self.view.frame.size.width * 0.8, 17.5, 15, 15)];

        if (lCurrentContainer.active) {
            [lCell addSubview:lImageView];
        }else{
            [lCell setBackgroundView:nil];
        }
    }else{
        mCellSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.7, 11.5f, 70.f, 70.f)];
        [mCellSwitch addTarget:self action:@selector(privacySwitcherChanged) forControlEvents:UIControlEventValueChanged];
        
        if ([getVal(@"publicPostsEnabled") isEqualToString:@"YES"]){
            [mCellSwitch setOn:YES];
        } else {
            [mCellSwitch setOn:NO];
        }
                
        lCell.textLabel.text = @"Facebook private publish";
        lCell.textLabel.textColor = [UIColor colorWithRed:186.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
        [lCell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
        lCell.textLabel.font = [UIFont systemFontOfSize:18.0f];
        
        [lCell addSubview:mCellSwitch];
        
    }
    
    [lCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    lCell.backgroundColor = [UIColor clearColor];
    
    return lCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        GSFacebookAccountSelectContainer *lContainer = (GSFacebookAccountSelectContainer*)[mDataSource objectAtIndex:indexPath.row];
        if (lContainer.active) {
            lContainer.active = NO;
        }else{
            lContainer.active = YES;
        }
        [mTableView reloadData];
    }
    
    if ([[self getGropsIDsForShare] length] > 0) {
        mPublishButton.enabled = YES;
    }else{
        mPublishButton.enabled = NO;
    }
}

#pragma mark - buttons methods
- (IBAction)backPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)publishPressed:(id)sender{
    [self sharePhotoToFacebook];

}

- (void)privacySwitcherChanged{
    if ([getVal(@"publicPostsEnabled") isEqualToString:@"YES"]){
         setVal(@"publicPostsEnabled", @"NO");
        [mCellSwitch setOn:NO];
        
    } else {
        setVal(@"publicPostsEnabled", @"YES");
        [mCellSwitch setOn:YES];
    }
}

#pragma mark - Requests sending
- (void) getPicture {
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_picture/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [lRequest setHTTPMethod:@"POST"];
    NSString *lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\"}", getVal(FACEBOOK_ACCES_TOKEN)];
    DLog(@"request json:%@",lJsonString);
    
    NSData *requestData = [NSData dataWithBytes:[lJsonString UTF8String] length:[lJsonString length]];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [lRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [lRequest setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:lRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               
                               if (error == nil) {
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       
                                       NSMutableString *lResultStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       
                                       DLog(@"response:%@",lResultStr);
                                       if (lResultStr != nil && ![lResultStr isEqual: @""] && [data length] > 0) {
                                           
                                           SBJsonParser *lParser = [SBJsonParser new];
                                           id lJson = [lParser objectWithString:lResultStr];
                                           if (lJson != nil ) {
                                               NSString *lName = @"";
                                               if ([lJson objectForKey:@"name"]) {
                                                   lName = [lJson objectForKey:@"name"];
                                                   setVal(FACEBOOK_USER_NAME, lName);
                                                   [mTableView reloadData];
                                               }
                                           }
                                       }
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [MBBProgressHUD hideHUDForView:self.view animated:YES];
                               });
                           }];
}

- (NSString*)getGropsIDsForShare{
    NSString *lIDs = @"";
    NSMutableArray *lIDsArray = [NSMutableArray new];
    for (NSInteger i = 0; i < [mDataSource count]; i++) {
        GSFacebookAccountSelectContainer *lContainer = (GSFacebookAccountSelectContainer*)[mDataSource objectAtIndex:i];
        if (lContainer.active) {
            [lIDsArray addObject:lContainer.userID];
        }
    }
    if ([lIDsArray count] > 0) {
        lIDs = [lIDs stringByAppendingString:[lIDsArray objectAtIndex:0]];
        for (NSInteger i = 1; i < [lIDsArray count]; i++) {
            lIDs = [lIDs stringByAppendingFormat:@"\",\"%@",[lIDsArray objectAtIndex:i]];
        }
    }
    return lIDs;
}

- (void)updateToken{
    GSFacebookLoginView *lFacebook = [[GSFacebookLoginView alloc] initWithFrame:self.view.frame];
    [lFacebook loadWebView];
    lFacebook.delegate = self;
    [self.view addSubview:lFacebook];
    [self.view bringSubviewToFront:lFacebook];
}

- (void)getGroups{
    [MBBProgressHUD showHUDAddedTo:self.view withText:@"Loading accounts"];
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_groups/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    [lRequest setHTTPMethod:@"POST"];
    NSString *lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\"}", getVal(FACEBOOK_ACCES_TOKEN)];

    DLog(@"request json:%@",lJsonString);
    
    NSData *requestData = [NSData dataWithBytes:[lJsonString UTF8String] length:[lJsonString length]];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [lRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [lRequest setHTTPBody:requestData];
    
    
    [NSURLConnection sendAsynchronousRequest:lRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error == nil) {
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       
                                       NSMutableString *lResultStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       
                                       DLog(@"response:%@",lResultStr);
                                       if (lResultStr != nil && ![lResultStr isEqual: @""] && [data length] > 0) {
                                           
                                           SBJsonParser *lParser = [SBJsonParser new];
                                           id lJson = [lParser objectWithString:lResultStr];
                                           if (lJson != nil ) {
                                               DLog(@"lJson - %@", lJson);
                                               
                                               // if token is expired - need relogin
                                               if ([lJson objectForKey:@"message"] && [[lJson objectForKey:@"message"] isEqualToString:@"token is not valid!!!"]) {
                                                   [self updateToken];
                                               }else{
                                                   GSFacebookAccountSelectContainer *lMeContainer = [GSFacebookAccountSelectContainer new];
                                                   lMeContainer.userName = getVal(FACEBOOK_USER_NAME);
                                                   lMeContainer.userID = @"me";
                                                   lMeContainer.active = YES;
                                                   [mDataSource addObject:lMeContainer];
                                                   if ([lJson objectForKey:@"accounts"]) {
                                                       NSArray *lAccounts = [lJson objectForKey:@"accounts"];
                                                       
                                                       for (NSInteger i = 0; i < [lAccounts count]; i++) {
                                                           GSFacebookAccountSelectContainer *lContainer = [GSFacebookAccountSelectContainer new];
                                                           lContainer.userName = [[lAccounts objectAtIndex:i] objectForKey:@"name"];
                                                           lContainer.userID = [[lAccounts objectAtIndex:i] objectForKey:@"id"];
                                                           [mDataSource addObject:lContainer];
                                                       }
                                                   }
                                                   [mTableView reloadData];                                                   
                                               }
                                               
                                               
                                           }
                                       }
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [MBBProgressHUD hideHUDForView:self.view animated:YES];
                               });
                           }];
}

- (NSString*)getBase64DataFromImage:(UIImage*)pImage{
    NSData *lImageData = UIImageJPEGRepresentation(pImage, 1.0f);
    NSString *lEncodeString = [[[lImageData base64EncodedStringWithSeparateLines:YES] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return lEncodeString;
}

- (void)sharePhotoToFacebook{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@posting_to_album/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    [lRequest setHTTPMethod:@"POST"];
    
    NSString *lPrivacySetting = @"YES";
    if ([getVal(@"publicPostsEnabled") isEqualToString:@"YES"]){
        lPrivacySetting = @"NO";
    }
    
    NSString *lSharingMessage = @"";
//    if ([MOPUB_ADVERTISMENT isEqualToString:@"ON"]) {
//        lSharingMessage = SHARE_STRING;
//    }
    
    NSString *lJsonString = @"";
    if (isSingelSharing) {
        lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\",\"public\":\"%@\", \"message\":\"%@\", \"pages\":[\"%@\"], \"images\": [{\"image_data\":\"%@\"}]}", getVal(FACEBOOK_ACCES_TOKEN), lPrivacySetting, lSharingMessage, [self getGropsIDsForShare], [self getBase64DataFromImage:mSharingImage]];
    }else{
        lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\",\"public\":\"%@\", \"message\":\"%@\", \"pages\":[\"%@\"], \"images\": [{\"image_data\":\"%@\"},{\"image_data\":\"%@\"}]}", getVal(FACEBOOK_ACCES_TOKEN), lPrivacySetting, lSharingMessage, [self getGropsIDsForShare], [self getBase64DataFromImage:mSharingImage], [self getBase64DataFromImage:mSecondSharingImage]];
    }
    
    NSData *requestData = [NSData dataWithBytes:[lJsonString UTF8String] length:[lJsonString length]];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [lRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [lRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [lRequest setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:lRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error == nil) {
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       
                                       NSMutableString *lResultStr = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       
                                       DLog(@"response:%@",lResultStr);
                                       if (lResultStr != nil && ![lResultStr isEqual: @""] && [data length] > 0) {
                                           
                                           SBJsonParser *lParser = [SBJsonParser new];
                                           id lJson = [lParser objectWithString:lResultStr];
                                           if (lJson != nil ) {
                                               if ([lJson objectForKey:@"message"] && [[lJson objectForKey:@"message"] isEqualToString:@"success"]) {
                                                   
                                                   [self showSuccessMessage];
                                               } else {
                                                   [self showErrorMessage];
                                               }
                                           } else {
                                               [self showErrorMessage];
                                           }
                                       }
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                                   [self showErrorMessage];
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [MBBProgressHUD hideHUDForView:self.view animated:YES];
                               });
                                
                           }];
}

- (void) showSuccessMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        // advertisment
        if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
            if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
                [[RevMobAds session] showFullscreen];
            }
        }
        
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your message was posted on Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [lAlert show];
    });
}

- (void) showErrorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message posting error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [lAlert show];
    });
}

#pragma mark - GSFacebookLoginViewDelegate
- (void)facebookAuthSucceeded:(NSString*)token{
    DLog(@"token  - %@", token);
    if (token && token && [token length] > 0) {
        NSArray* lParametersArray = [token componentsSeparatedByString: @"&"];
        NSString *lToken = [lParametersArray objectAtIndex:0];
        setVal(FACEBOOK_ACCES_TOKEN, lToken);
        
        //get user name
        [self getPicture];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [lAlertView show];
        });
    }
}

- (void)facebookAuthFailed:(NSString*)error
               errorReason:(NSString*)errorReason
          errorDescription:(NSString*)errorMessage{
    DLog(@"facebookAuthFailed - %@   %@   %@", error, errorReason, errorMessage);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook Auth Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    });
}

- (void)facebookAuthLoadFailed:(NSError*)error{
    DLog(@"facebookAuthLoadFailed - %@", error.localizedDescription);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook AuthLoad Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    });
    
}

- (void)facebookAuthCancelled{
    DLog(@"facebookAuthCancelled");
}

@end
