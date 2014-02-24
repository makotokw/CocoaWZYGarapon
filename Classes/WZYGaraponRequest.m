//
//  WZYGaraponRequest.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "WZYGaraponGlobal.h"
#import "WZYGaraponRequest.h"

@implementation WZYGaraponRequest

@synthesize devId = _devId;
@synthesize sessionId = _sessionId;

static NSString *md5(NSString *str)
{
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

static NSString *escapeString(NSString *text)
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                (__bridge CFStringRef)text,
                                                                                NULL,
                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                kCFStringEncodingUTF8);
}

static NSString *queryString(NSDictionary *dictionary)
{
    NSMutableString *queryString = nil;
    NSArray *keys = [dictionary allKeys];
    
    if ([keys count] > 0) {
        for (id key in keys) {
            id value = [dictionary objectForKey:key];
            if (nil == queryString) {
                queryString = [[NSMutableString alloc] init];
            } else {
                [queryString appendFormat:@"&"];
            }
            
            if (nil != key && nil != value) {
                [queryString appendFormat:@"%@=%@", escapeString([key description]), escapeString([value description])];
            } else if (nil != key) {
                [queryString appendFormat:@"%@", escapeString([key description])];
            }
        }
    }
    
    return queryString;
}

static NSURL *URLByAppendingQueryString(NSURL *URL, NSString *queryString)
{
    if (![queryString length]) {
        return URL;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [URL absoluteString],
                           [URL query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    
    return theURL;
}

+ (NSString *)md5StringWithString:(NSString *)string
{
    return md5(string);
}

- (id)initWithSessionId:(NSString *)sessionId
{
    self = [super init];
    if (self) {
        _sessionId = sessionId;
    }
    return self;
}

- (NSString *)sessionQueryString
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
    if (_devId.length > 0) {
        query[@"dev_id"] = _devId;
    }
    if (_sessionId.length > 0) {
        query[@"gtvsession"] = _sessionId;
    }
    return queryString(query);
}

- (void)get:(NSString *)url parameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    [self request:url method:@"GET" parameter:parameter completionHandler:completionHandler];
}

- (void)post:(NSString *)url parameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    [self request:url method:@"POST" parameter:parameter completionHandler:completionHandler];
}

- (void)request:(NSString *)url method:(NSString *)method parameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];    
    
    __block NSURL *URL = [NSURL URLWithString:url];
    
    if (parameter.count > 0) {
        NSString *content = queryString(parameter);
        if ([[method lowercaseString] isEqualToString:@"get"]) {
            URL = URLByAppendingQueryString(URL, content);
        } else {
            [request setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    NSRange range = [URL.path rangeOfString:@"/gapi/"];    
    if (range.location != NSNotFound) {
        URL = URLByAppendingQueryString(URL, [self sessionQueryString]);
    }
    
    request.URL = URL;
    request.HTTPMethod = method;
    request.HTTPShouldHandleCookies = YES;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (error) {
                                   if (completionHandler) {
                                       completionHandler(nil, error);
                                   }
                                   return;
                               }                               
                               
                               NSDictionary *result = nil;
                               
                               if ([URL.host isEqualToString:WZY_GARAPON_AUTH_HOST]) { // GaraponWeb API
                                   NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                   NSString *string = [NSString stringWithUTF8String:data.bytes];
                                   
                                   NSUInteger lineEnd = 0;
                                   while (lineEnd < string.length) {
                                       NSRange currentRange = [string lineRangeForRange:NSMakeRange(lineEnd, 0)];
                                       NSString *line = [string substringWithRange:currentRange];
                                       
                                       NSArray *keyValues = [line componentsSeparatedByString:@";"];
                                       if (keyValues.count == 2) {
                                           NSString *key = keyValues[0];
                                           NSString *value = keyValues[1];                                           
                                           dict[[key stringByTrimmingCharactersInSet:
                                                   [NSCharacterSet whitespaceCharacterSet]]] =
                                               [value stringByTrimmingCharactersInSet:
                                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                       }
                                       lineEnd = currentRange.location + currentRange.length;
                                   }                                   
                                   result = dict;
                               } else { // GaraponTV API
                                   NSError *parseError = nil;
                                   result = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:&parseError];
                                   if (parseError) {
                                       if (completionHandler) {
                                           completionHandler(result, parseError);
                                       }
                                       return;
                                   }                                   
                                   
                                   NSRange range = [URL.path rangeOfString:@"/auth"];
                                   if (range.location != NSNotFound) {
                                       _sessionId = nil;
                                       id gtvsession = result[@"gtvsession"];
                                       if ([gtvsession isKindOfClass:[NSString class]]) {
                                           _sessionId = gtvsession;
                                       }
                                   }
                               }
                               if (completionHandler) {
                                   completionHandler(result, nil);
                               }
                               
                           }];

}

@end
