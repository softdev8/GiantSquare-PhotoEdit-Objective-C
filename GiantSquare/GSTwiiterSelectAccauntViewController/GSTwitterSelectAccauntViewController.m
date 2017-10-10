//
//  GSTwitterSelectAccauntViewController.m
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/21/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSTwitterSelectAccauntViewController.h"
#import "GSFacebookAccountSelectContainer.h"
#import "SBJson.h"
#import "MBBProgressHUD.h"
#import "NSData+Base64.h"

#import <MessageUI/MessageUI.h>

@interface GSTwitterSelectAccauntViewController ()

@end

@implementation GSTwitterSelectAccauntViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mSharingImage = pImage;
        mIsCollage = YES;
        
        mDataSources = [[NSArray alloc] initWithArray:getVal(TWITTER_ACCOUNTS_ARRAY)];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andImage:(UIImage*)pImage andImage:(UIImage*)pSecondImage{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mSharingImage = pImage;
        mIsCollage = NO;
        mSecondSharingImage = pSecondImage;
        
        mDataSources = [[NSArray alloc] initWithArray:getVal(TWITTER_ACCOUNTS_ARRAY)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:21/255.0f green:21/255.0f blue:21/255.0f alpha:1.0f]];

    // load advertisement
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        if (![[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION] && ![[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED]) {
            mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                    size:MOPUB_BANNER_SIZE];
            [mAdView setFrame:CGRectMake((self.view.frame.size.width - MOPUB_BANNER_SIZE.width) / 2.0, self.view.bounds.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
        }
        
        mIsBannerAppear = NO;        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [mHeaderImageView setImage:[UIImage imageNamed:@"blue_top_bar_portrait.png"]];
    } else {
        [mHeaderImageView setImage:[UIImage imageNamed:@"collagesTopBar.png"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewMethod
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"mDataSources %@", mDataSources);
        return [mDataSources count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *lCell;
    lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:CellIdentifier] ;
    
    [lCell.textLabel setTextColor:[UIColor colorWithRed:186.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f]];
    [lCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    lCell.backgroundColor = [UIColor clearColor];

    if (indexPath.row < [mDataSources count]) {
        lCell.textLabel.text = [[mDataSources objectAtIndex:indexPath.row] valueForKey:TWITTER_ACCES_NAME];
        
        UIImageView * lImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkAccounts.png"]];
        [lImageView setFrame:CGRectMake(self.view.frame.size.width * 0.8, 17.5, 15, 15)];
        
        if ([[[mDataSources objectAtIndex:indexPath.row] valueForKey:TWITTER_ACCES_STATE] isEqualToString:@"YES"] == YES) {
            [lCell addSubview:lImageView];
        }else{
            [lCell setBackgroundView:nil];
        }
    } else {
        lCell.textLabel.text = @"+Add new twitter account";
    }
    
    
    return lCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [mDataSources count]) {
        if ([[[mDataSources objectAtIndex:indexPath.row] valueForKey:TWITTER_ACCES_STATE] isEqualToString:@"YES"] == YES) {
            NSLog(@"iiiiiii %@", [mDataSources objectAtIndex:indexPath.row]);
            [[mDataSources objectAtIndex:indexPath.row] setValue:@"NO" forKey:TWITTER_ACCES_STATE];
        } else {
            [[mDataSources objectAtIndex:indexPath.row] setValue:@"YES" forKey:TWITTER_ACCES_STATE];
        }
        [mTableView reloadData];
    } else {
        mTwitterLogin = [[GSTwitterLoginView alloc] initWithFrame:self.view.frame];
        [mTwitterLogin setDelegate:self];
        [mTwitterLogin startAuthorization];
        [self.view addSubview:mTwitterLogin];
        [self.view bringSubviewToFront:mTwitterLogin];

    }

}

- (IBAction)backPressed:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)publishPressed:(id)sender{
    
    [self sharePhotoToTwitter];
}

#pragma mark - requests
- (NSString*)getBase64DataFromImage:(UIImage*)pImage{
    NSData *lImageData = UIImageJPEGRepresentation(pImage, 1.0f);
    NSString *lEncodeString = [[[lImageData base64EncodedStringWithSeparateLines:YES] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return lEncodeString;
}

- (void)sharePhotoToTwitter{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_twitter_pictures/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:480.0f];
    [lRequest setHTTPMethod:@"POST"];
    
    NSMutableString *lArrayString = [NSMutableString stringWithFormat:@"["];
    for (NSUInteger i=0; i < [mDataSources count]; i++) {
        if ([[[mDataSources objectAtIndex:i] valueForKey:TWITTER_ACCES_STATE] isEqualToString:@"YES"] == YES) {
            [lArrayString appendString:[NSString stringWithFormat:@"{\"access_token\":\"%@\",\"access_token_secret\":\"%@\"}",[[mDataSources objectAtIndex:i] valueForKey:TWITTER_ACCES_TOKEN],[[mDataSources objectAtIndex:i] valueForKey:TWITTER_ACCES_SECRET]]];
            if (i<([mDataSources count]-1)) {
                [lArrayString appendString:@","];
            }
        }
    }
    [lArrayString appendString:@"]"];
    NSString *lJsonString = @"";
    if (!mIsCollage) {
        lJsonString = [NSString stringWithFormat:@"{\"accounts\":%@, \"profile_picture\":\"%@\",\"profile_banner\":\"%@\"}", lArrayString, [self getBase64DataFromImage:mSharingImage], [self getBase64DataFromImage:mSecondSharingImage]];
    } else {
        lJsonString = [NSString stringWithFormat:@"{\"accounts\":%@, \"profile_picture\":\"""\",\"profile_banner\":\"%@\"}", lArrayString, [self getBase64DataFromImage:mSharingImage]];
        
    }
    NSLog(@"lJsonString %@", lJsonString);
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
                                               }else{
                                                   [self showErrorMessage];
                                               }
                                           } else {
                                               [self showErrorMessage];
                                           }
                                       } else {
                                           [self showErrorMessage];
                                       }
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                                   [self showErrorMessage];
                               }
                               [MBBProgressHUD hideHUDForView:self.view animated:YES];
                           }];
    
//    MFMailComposeViewController *lCom = [[MFMailComposeViewController alloc] init];
//    [lCom addAttachmentData:[lJsonString dataUsingEncoding:NSStringEncodingConversionAllowLossy] mimeType:@"text/txt" fileName:@"json.txt"];
//    
//    [self presentModalViewController:lCom animated:YES];
}

- (void) showSuccessMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your message was posted on Twitter." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [lAlert show];
    });
}

- (void) showErrorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message posting error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [lAlert show];
    });
}

#pragma mark -- UIMpadBanner method

- (void) animationStart {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    mIsBannerAppear = YES;
    
    [mAdView setFrame:CGRectMake((self.view.bounds.size.width - MOPUB_BANNER_SIZE.width) / 2.0, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    
    [mTableView setFrame:CGRectMake(mTableView.frame.origin.x, mTableView.frame.origin.y, mTableView.frame.size.width, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height - mTableView.frame.origin.y)];
    
    [UIView commitAnimations];
    
}
- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view{
    if (mIsBannerAppear == NO){
        [self.view addSubview:mAdView];
        [self animationStart];
    }
    
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}


#pragma mark - GSTwitterLoginViewDelegate

- (void)didReceiveOAuthAccessToken:(OAToken *)token {
    NSLog(@"access token %@", token);
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
    DLog(@"token.key - %@", token.key);
    DLog(@"token.secret - %@", token.secret);
    
    if (token) {
        [self getPicture:token.key andSecret:token.secret];
        
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Twitter account connected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }else{
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
}

- (void)didFailOAuthWithError:(NSError *)error {
    NSLog(@"error oauth %@", error);
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
}

- (void)didTwitterCancelPressed{
    DLog(@"didTwitterCancelPressed");
    mTwitterLogin.delegate = nil;
    [mTwitterLogin removeFromSuperview];
}

- (void)addTwitterAccountWithToken:(NSString*)pToken andSecret:(NSString*)pSecret andName:(NSString*)pName{
    
    NSMutableArray *lAccountsArray = [NSMutableArray new];
    if (mDataSources){
        [lAccountsArray setArray:mDataSources];
    }
    NSMutableDictionary *lDictionary = [NSMutableDictionary new];
    [lDictionary setValue:pToken forKey:TWITTER_ACCES_TOKEN];
    [lDictionary setValue:pSecret forKey:TWITTER_ACCES_SECRET];
    [lDictionary setValue:pName forKey:TWITTER_ACCES_NAME];
    [lDictionary setValue:@"YES" forKey:TWITTER_ACCES_STATE];
    
    [lAccountsArray addObject:lDictionary];
    setVal(TWITTER_ACCOUNTS_ARRAY, lAccountsArray);
    [mTableView reloadData];
}

- (void)getPicture:(NSString *)pToken andSecret:(NSString*)pSecret{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_twitter_user/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [lRequest setHTTPMethod:@"POST"];
    NSString *lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\", \"access_token_secret\":\"%@\"}", pToken, pSecret];
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
                                               }
                                               [self addTwitterAccountWithToken:pToken andSecret:pSecret andName:lName];
                                           }
                                       }
                                       
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                                   UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [lAlertView show];
                               }
                               [MBBProgressHUD hideHUDForView:self.view animated:YES];
                           }];
    
}

@end
