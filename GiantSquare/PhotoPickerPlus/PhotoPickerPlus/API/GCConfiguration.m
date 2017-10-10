//
//  GCConfiguration.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 8/10/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "GCConfiguration.h"
#import "GCAccount.h"
#import "NSObject+GCDictionary.h"
#import "DCKeyValueObjectMapping.h"

static NSString * const kGCServices = @"services";
static NSString * const kGCOAuth = @"oauth";
static NSString * const kGCAccounts = @"accounts";

static NSString * const kGCConfiguration = @"GCConfiguration";
static NSString * const kGCExtension = @"plist";
//static NSString * const kGCConfigurationURL = @"http://s3.amazonaws.com/store.getchute.com/51eeae5e6e29310c9a000001";
static NSString *const kGCConfigurationURL = @"https://dl.dropboxusercontent.com/u/23635319/ChuteAPI/config.json";

static GCConfiguration *sharedData = nil;
static dispatch_queue_t serialQueue;

@implementation GCConfiguration

@synthesize services, oauthData, accounts;

+(id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create("com.getchute.gcconfiguration", NULL);
        if (sharedData == nil) {
            sharedData = [super allocWithZone:zone];
        }
    });
    
    return sharedData;
}

+(GCConfiguration *)configuration {
    static dispatch_once_t onceToken;
    static GCConfiguration *sharedData = nil;
    
    dispatch_once(&onceToken, ^{
        sharedData = [[GCConfiguration alloc] init];
    });
    return sharedData;
}

- (id)init
{
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        
        obj = [super init];
        
        if (obj) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kGCConfiguration, kGCExtension]];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:path]) {
                path = [[NSBundle mainBundle] pathForResource:kGCConfiguration ofType:kGCExtension];

            }

            NSDictionary *savedStock = [[NSDictionary alloc] initWithContentsOfFile: path];
            [self setConfiguration:savedStock];

            [self update];
            }
    });
        
    self = obj;
    return self;
}

- (void)update
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kGCConfigurationURL]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (!error) {
                [self setConfiguration:configuration];
            }
        }
    }];
}

- (void)addAccount:(GCAccount *)account
{
    if (![self accounts])
        self.accounts = [NSMutableArray new];
    
    for (int i = 0; i < [self.accounts count]; i++) {
        if ([account.type isEqualToString:[self.accounts objectAtIndex:i]]) {
            [self.accounts removeObjectAtIndex:i];
            i--;
        }
    }
    
    [self.accounts addObject:account];
    [self serialize];
}

- (void)setConfiguration:(NSDictionary *)configuration
{
    if ([configuration objectForKey:kGCOAuth]){
        
        self.oauthData = [configuration objectForKey:kGCOAuth];
    }
    if ([configuration objectForKey:kGCServices]){
        
        self.services = [configuration objectForKey:kGCServices];
    }
    if ([configuration objectForKey:kGCAccounts]) {
        
        DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[GCAccount class]];
        self.accounts = [NSMutableArray arrayWithArray:[mapping parseArray:[configuration objectForKey:kGCAccounts]]];
    }
    
    [self serialize];
}

- (void)serialize
{
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kGCConfiguration, kGCExtension]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath: path])
        {
            NSLog(@"<KXLog> File: %@",path);
            [fileManager removeItemAtPath:path error:&error];
        }
        if (![fileManager fileExistsAtPath: path])
        {
            NSMutableDictionary *stockToSave = [[NSMutableDictionary alloc] init];
            if ([self services])
            {
                [stockToSave setObject:services forKey:kGCServices];
            }
            if ([self oauthData])
            {
                [stockToSave setObject:oauthData forKey:kGCOAuth];
            }
            
            if ([self accounts]) {
                NSMutableArray *accountDictionaries = [NSMutableArray new];
                for (GCAccount *account in [self accounts]) {
                    [accountDictionaries addObject:[account dictionaryValue]];
                }
//                DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[GCAccount class]];
//                [stockToSave setObject:[mapping serializeObjectArray:self.accounts] forKey:kGCAccounts];
                NSLog(@"Serialized object: %@", [accountDictionaries objectAtIndex:0]);
                [stockToSave setObject:accountDictionaries forKey:kGCAccounts];
            }
                        
            NSLog(@"<KXLog> StockToSave: %@", stockToSave);
            [stockToSave writeToFile:path atomically:YES];
        }
}

@end
