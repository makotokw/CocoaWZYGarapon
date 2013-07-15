//
//  WZGaraponTv.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponError.h"
#import "WZGaraponWrapDictionary.h"
#import "WZGaraponRequest.h"
#import "WZGaraponTv.h"
#import "WZGaraponTvChannel.h"
#import "WZGaraponTvProgram.h"

@implementation WZGaraponTv

{
    WZGaraponRequest *_httpClient;
}

@synthesize host = _host, port = _port, apiVersion = _apiVersion;
@synthesize firmwareVersion = _firmwareVersion;
@dynamic devId;
@dynamic hasSession;

+ (id)garaponTvWithAddressResponse:(NSDictionary *)response apiVersion:(NSString *)apiVersionString
{
    WZGaraponTv *tv = [[WZGaraponTv alloc] init];
    tv.apiVersion = apiVersionString;
    [tv setHostAndPortWithAddressResponse:response];
    return tv;
}

- (id)init
{
    self = [super init];
    if (self) {
        _httpClient = [[WZGaraponRequest alloc] init];
        _apiVersion = @"v3";
    }
    return self;
}

- (id)initWithHost:(NSString *)host port:(NSInteger)port apiVersion:(NSString *)apiVersionString
{
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _apiVersion = (apiVersionString) ? apiVersionString : @"v3";
    }
    return self;
}

- (void)setHostAndPortWithAddressResponse:(NSDictionary *)response
{
    WZGaraponWrapDictionary *wrap = [WZGaraponWrapDictionary wrapWithDictionary:response];
    
    NSString *host = [wrap stringValueWithKey:@"ipaddr" defaultValue:nil];
    NSString *globalAddress = [wrap stringValueWithKey:@"gipaddr" defaultValue:nil];
    NSInteger globalPort = [wrap intgerValueWithKey:@"port" defaultValue:80];
    NSInteger port = [host isEqualToString:globalAddress] ? globalPort : 80;
    
    _host = host;
    _port = port;
}

- (NSString *)URLStringWithPath:(NSString *)path
{
    if (_port == 80) {
        return [NSString stringWithFormat:@"http://%@%@", _host, path];
    }
    return [NSString stringWithFormat:@"http://%@:%d%@", _host, _port, path];
}

- (NSString *)apiURLStringWithPath:(NSString *)path
{
    if (_port == 80) {
        return [NSString stringWithFormat:@"http://%@/gapi/%@%@", _host, _apiVersion, path];
    }
    return [NSString stringWithFormat:@"http://%@:%d/gapi/%@%@", _host, _port, _apiVersion, path];
}

+ (NSString *)formatDate:(NSTimeInterval)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatDateTime:(NSTimeInterval)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)devId
{
    return _httpClient.devId;
}

- (void)setDevId:(NSString *)devId
{
    _httpClient.devId = devId;
}

- (BOOL)hasSession
{
    return _httpClient.sessionId.length > 0;
}

- (NSString *)thumbnailURLStringWithId:(NSString *)gtvid
{
    NSString *path = [NSString stringWithFormat:@"/thumbs/%@", gtvid];
    return [self URLStringWithPath:path];
}

- (NSString *)thumbnailURLStringWithProgram:(WZGaraponTvProgram *)program
{
    return [self thumbnailURLStringWithId:program.gtvid];
}

- (NSString *)httpLiveStreamingURLStringWithId:(NSString *)gtvid
{
    NSString *path = [NSString stringWithFormat:@"/cgi-bin/play/m3u8.cgi?%@-%@", gtvid, _httpClient.sessionId];
    return [self URLStringWithPath:path];
}

- (NSString *)httpLiveStreamingURLStringWithProgram:(WZGaraponTvProgram *)program
{
    return [self httpLiveStreamingURLStringWithId:program.gtvid];
}

- (void)loginWithLoginId:(NSString *)loginId rawPassword:(NSString *)rawPassword completionHandler:(WZGaraponAsyncBlock)completionHandler
{
    [self loginWithLoginId:loginId password:[WZGaraponRequest md5StringWithString:rawPassword] completionHandler:completionHandler];
}

- (void)loginWithLoginId:(NSString *)loginId password:(NSString *)password completionHandler:(WZGaraponAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/auth"];
    NSDictionary *parameter = @{@"type": @"login",
                                @"loginid": loginId,
                                @"md5pswd": password
                                };
    [_httpClient post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];            
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            NSInteger result = [wrapResponse intgerValueWithKey:@"login" defaultValue:-1];
            if (!(status == 1 && result == 1)) {
                error = [[WZGaraponError alloc] initWithDomain:WZGaraponErrorDomain
                                                          code:WZGaraponErrorAuthenticationFailed
                                                      userInfo:@{@"status": [NSNumber numberWithInteger:status], @"result":[NSNumber numberWithInteger:result]}];
            }
            _firmwareVersion = [wrapResponse stringValueWithKey:@"version" defaultValue:nil];
        }
                
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)logoutWithCompletionHandler:(WZGaraponAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/auth"];
    NSDictionary *parameter = @{@"type": @"logout"};
    [_httpClient post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger result = [wrapResponse intgerValueWithKey:@"logout" defaultValue:-1];
            if (result != 1) {
                error = [[WZGaraponError alloc] initWithDomain:WZGaraponErrorDomain
                                                          code:WZGaraponErrorAuthenticationFailed
                                                      userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
            }
        }
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)searchWithParameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/search"];
    [_httpClient post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZGaraponError alloc] initWithDomain:WZGaraponErrorDomain
                                                          code:WZGaraponErrorAuthenticationFailed
                                                      userInfo:@{@"status":[NSNumber numberWithInteger:status]}];
            }
        }
        
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)channelWithCompletionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/channel"];
    [_httpClient post:URLString parameter:nil completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZGaraponError alloc] initWithDomain:WZGaraponErrorDomain
                                                          code:WZGaraponErrorAuthenticationFailed
                                                      userInfo:@{@"status":[NSNumber numberWithInteger:status]}];
            }
        }
        
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

@end
