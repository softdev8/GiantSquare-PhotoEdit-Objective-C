//
//  GSSettingsViewController.m
//  GiantSquare
//
//  Created by Andriy Melnyk on 3/4/13.
//  Copyright (c) 2013 Vakoms. All rights reserved.
//

#import "GSSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import  "Global.h"
#import "SBJsonParser.h"
#import "MBBProgressHUD.h"

@interface GSSettingsViewController ()
@end

@implementation GSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //set background image
    if ([UIScreen mainScreen].bounds.size.height > 560) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDark_iPhone5.png"]]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDark.png"]]];
    }
    
    [mSecondView.layer setCornerRadius:11.0];
    [mSecondView.layer setBorderWidth:1.0];
    [mSecondView.layer setBorderColor:[UIColor lightGrayColor].CGColor];

    
    [mAccountsButton.layer setCornerRadius:5.0];
    [mAccountsButton.layer setBorderWidth:1.0];
    [mAccountsButton.layer setBorderColor:[UIColor colorWithRed:71/255.0f green:71/255.0f blue:71/255.0f alpha:1.0].CGColor];

    
    if ([MOPUB_ADVERTISMENT  isEqualToString:@"ON"]){
        BOOL lUseHasRemovedAds;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IAP_PRO_VERSION]) {
            lUseHasRemovedAds = YES;
        } else {
            lUseHasRemovedAds = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_ADS_REMOVED];
        }
        if (!lUseHasRemovedAds) {
            
            mAdView = [[MPAdView alloc] initWithAdUnitId:MOPUB_ID
                                                    size:MOPUB_BANNER_SIZE];
            [mAdView setFrame:CGRectMake(0.0f, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
            mAdView.delegate = self;
            [mAdView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
            [mAdView loadAd];
            
            mIsBannerAppear = NO;
        }
    }
    //hide restore button
#ifdef FREE
    [mRestoreButton setHidden:NO];
#else
    [mRestoreButton setHidden:YES];
#endif
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([getVal(@"publicPostsEnabled") isEqualToString:@"NO"]){
        [mSettingsSwitch setOn:YES];
    } else {
        [mSettingsSwitch setOn:NO];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            GSFacebookLoginView *lFacebook = [[GSFacebookLoginView alloc] initWithFrame:self.view.frame];
            [lFacebook loadWebView];
            lFacebook.delegate = self;
            [self.view addSubview:lFacebook];
            [self.view bringSubviewToFront:lFacebook];
        }
    }
}


#pragma mark - buttons methods
- (IBAction)connectFacebookAccountPressed:(id)sender{
    if (getVal(FACEBOOK_ACCES_TOKEN) && [getVal(FACEBOOK_ACCES_TOKEN) length] > 0) {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You have Facebook account alredy connected. Do you want to remove it and connect another account?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        lAlertView.tag = 1;
        [lAlertView show];
    }else{
        GSFacebookLoginView *lFacebook = [[GSFacebookLoginView alloc] initWithFrame:self.view.frame];
        [lFacebook loadWebView];
        lFacebook.delegate = self;
        [self.view addSubview:lFacebook];
        [self.view bringSubviewToFront:lFacebook];        
    }
}

- (IBAction)connectedTwitterAccountPressed:(id)sender{
    mTwitterLogin = [[GSTwitterLoginView alloc] initWithFrame:self.view.frame];
    [mTwitterLogin setDelegate:self];
    [mTwitterLogin startAuthorization];
    [self.view addSubview:mTwitterLogin];
    [self.view bringSubviewToFront:mTwitterLogin];
}


- (IBAction) settingSwitchPressed:(id)sender{
    if ([getVal(@"publicPostsEnabled") isEqualToString:@"YES"]){
        setVal(@"publicPostsEnabled", @"NO");
        [mSettingsSwitch setOn:YES];
        
    } else {
        setVal(@"publicPostsEnabled", @"YES");
        [mSettingsSwitch setOn:NO];
    }
}

- (IBAction) backPressed:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) restoreButtonPressed:(id)pSender {
    if([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    } else {
        NSLog(@"Parental control enabled");
    }
}

#pragma mark - MPAdViewDelegate methods
- (void) animationStart {
    mIsBannerAppear = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [mAdView setFrame:CGRectMake(0.0, self.view.frame.size.height - MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    [UIView commitAnimations];
    
}

- (UIViewController *) viewControllerForPresentingModalView{
    return self;
}

- (void) adViewDidLoadAd:(MPAdView *)view {
    
    if (mIsBannerAppear == NO){
        [mAdView setFrame:CGRectMake(0.0, self.view.frame.size.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
        [self.view addSubview:mAdView];
        [self animationStart];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    
}

#pragma mark - GSFacebookLoginViewDelegate
- (void)facebookAuthSucceeded:(NSString*)token{
    DLog(@"token  - %@", token);
    if (token && [token length] > 0) {
        NSArray* lParametersArray = [token componentsSeparatedByString: @"&"];
        NSString *lToken = [lParametersArray objectAtIndex:0];
        setVal(FACEBOOK_ACCES_TOKEN, lToken);
        
        [self getPicture];
        
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Facebook account connected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }else{
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Token receiving error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
    
}

- (void)facebookAuthFailed:(NSString*)error
               errorReason:(NSString*)errorReason
          errorDescription:(NSString*)errorMessage{
    DLog(@"facebookAuthFailed - %@   %@   %@", error, errorReason, errorMessage);
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook Auth Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
    
}

- (void)facebookAuthLoadFailed:(NSError*)error{
    DLog(@"facebookAuthLoadFailed - %@", error.localizedDescription);
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook AuthLoad Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [lAlertView show];
    
}

- (void)facebookAuthCancelled{
    DLog(@"facebookAuthCancelled");
}

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
                                               }
                                           }
                                       }
                                   }
                               } else {
                                   DLog(@"request error :%@",error.localizedDescription);
                               }
                           }];
}


#pragma mark - GSTwitterLoginViewDelegate

- (void)didReceiveOAuthAccessToken:(OAToken *)token {
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
    if (getVal(TWITTER_ACCOUNTS_ARRAY)){
        [lAccountsArray setArray:getVal(TWITTER_ACCOUNTS_ARRAY)];
    }
    NSMutableDictionary *lDictionary = [NSMutableDictionary new];
    [lDictionary setObject:pToken forKey:TWITTER_ACCES_TOKEN];
    [lDictionary setObject:pSecret forKey:TWITTER_ACCES_SECRET];
    [lDictionary setObject:pName forKey:TWITTER_ACCES_NAME];
    [lDictionary setObject:@"YES" forKey:TWITTER_ACCES_STATE];
    
    [lAccountsArray addObject:lDictionary];
    setVal(TWITTER_ACCOUNTS_ARRAY, lAccountsArray);
}

- (void)getPicture:(NSString *)pToken andSecret:(NSString*)pSecret{
    [MBBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *lRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_twitter_user/", OUR_FACEBOOK_SERVER_URL]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [lRequest setHTTPMethod:@"POST"];
    NSString *lJsonString = [NSString stringWithFormat:@"{\"access_token\":\"%@\", \"access_token_secret\":\"%@\"}", pToken, pSecret];
    DLog(@"request json:%@  lRequest %@",lJsonString, lRequest);
    
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
                                           NSLog(@"lJson %@", lJson);
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

#pragma mark -SKProductsRequestDelegate-

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    DLog(@"%@",response.invalidProductIdentifiers);
    NSArray *products = response.products;
    if (products.count != 0){
        DLog(@"products:%@",products);
        DLog(@"class:%@",[[response.products objectAtIndex:0] class]);
        
        SKPayment *payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    } else {
        UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Product not found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [lAlertView show];
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products){
        DLog(@"Product not found: %@", product);
    }
}

#pragma mark -SKPaymentTransactionObserver-
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"transactions  - %@", transactions);
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Transaction Failed");
                UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Restore fail." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [lAlertView show];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"transaction.payment.productIdentifier  - %@", transaction.payment.productIdentifier);
                if ([transaction.payment.productIdentifier isEqualToString:IAP_ADS_REMOVED]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
                    [self removeAds];
                }else if ([transaction.payment.productIdentifier isEqualToString:IAP_FRAMES]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
                }else if ([transaction.payment.productIdentifier isEqualToString:IAP_OLD_PURCHASE] || [transaction.payment.productIdentifier isEqualToString:IAP_PRO_VERSION]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_ADS_REMOVED];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_FRAMES];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_PRO_VERSION];
                }else if ([transaction.payment.productIdentifier isEqualToString:IAP_WATERMARK]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IAP_WATERMARK];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    UIAlertView *lAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Restore fail." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [lAlertView show];
}

// Then this is called
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"%@",queue );
}

// this method called when user buy this purchase and it disable ads display
- (void) removeAds {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [mAdView setFrame:CGRectMake((self.view.frame.size.width  - MOPUB_BANNER_SIZE.width)/2, self.view.frame.size.height + MOPUB_BANNER_SIZE.height, MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height)];
    
    } completion:^(BOOL finished) {
        [mAdView setHidden:YES];
        [mAdView removeFromSuperview];
        mAdView = nil;
    }];
}

@end
