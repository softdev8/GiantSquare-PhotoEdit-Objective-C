//
//  NSString+QueryString.m
//  LROAuth2Client
//
//  Created by Luke Redpath on 14/05/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "NSString+QueryString.h"

@implementation NSString (QueryString)

- (NSString*)stringByEscapingForURLQuery
{
    return [self stringURLEncodedForQuery:YES];
}

- (NSString *)stringByEscapingForURL
{
    return [self stringURLEncodedForQuery:NO];
}

- (NSString*)stringByUnescapingFromURLQuery
{
    return [[self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

- (NSString *)stringURLEncodedForQuery:(BOOL)isQuery
{
    NSString *result = self;
    
    CFStringRef originalAsCFString = (__bridge  CFStringRef) self;
    CFStringRef leaveAlone = isQuery ? CFSTR(" ") : nil;
    CFStringRef toEscape = isQuery ? CFSTR("\n\r?[]()$,!'*;:@&=#%+/") : CFSTR("\n\r?[]()$,!'*;:@&=#%+/ ");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalAsCFString, leaveAlone, toEscape, kCFStringEncodingUTF8);
    
    if (escapedStr) {
        NSMutableString *mutable = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
        CFRelease(escapedStr);
        
        [mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
        result = mutable;
    }
    return result;
}

- (NSString *)stringByDecodingURLFormat
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSMutableDictionary *)dictionaryFromQueryComponents
{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; // Verify that there is at least one key, and at least one value.  Ignore extra = signs
        NSString *key = [[keyValuePairArray objectAtIndex:0] stringByDecodingURLFormat];
        NSString *value = [[keyValuePairArray objectAtIndex:1] stringByDecodingURLFormat];
        NSMutableArray *results = [queryComponents objectForKey:key]; // URL spec says that multiple values are allowed per key
        if(!results) // First object
        {
            results = [NSMutableArray arrayWithCapacity:1];
            [queryComponents setObject:results forKey:key];
        }
        [results addObject:value];
    }
    return queryComponents;
}

@end
