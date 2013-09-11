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

#define WZGaraponTvDefaultApiVersion @"v3"

@implementation WZGaraponTv

{
    NSString *_devId, *_sessionId;
    NSString *_loginId, *_password;
}

@synthesize host = _host, port = _port, apiVersion = _apiVersion;
@synthesize firmwareVersion = _firmwareVersion;
@synthesize devId = _devId;
@synthesize sessionId = _sessionId;
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
        _apiVersion = WZGaraponTvDefaultApiVersion;
    }
    return self;
}

- (id)initWithHost:(NSString *)host port:(NSInteger)port apiVersion:(NSString *)apiVersionString
{
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _apiVersion = (apiVersionString) ? apiVersionString : WZGaraponTvDefaultApiVersion;
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

- (NSURL *)URLWithPath:(NSString *)path
{
    return [NSURL URLWithString:[self URLStringWithPath:path]];
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

+ (NSDictionary *)recordingProgramParams
{
    NSTimeInterval sdate = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval edate = sdate + 600;
    return @{
             @"dt": @"e",
             @"sort": @"sta",
             @"sdate": [WZGaraponTv formatDateTime:sdate],
             @"sdate": [WZGaraponTv formatDateTime:edate],
             @"video": @"all",
             };
}

- (BOOL)hasSession
{
    return _sessionId.length > 0;
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
    NSString *path = [NSString stringWithFormat:@"/cgi-bin/play/m3u8.cgi?%@-%@", gtvid, _sessionId];
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

- (WZGaraponRequest *)request
{
    WZGaraponRequest *r = [[WZGaraponRequest alloc] initWithSessionId:_sessionId];
    r.devId = _devId;
    return r;
}

- (void)loginWithLoginId:(NSString *)loginId password:(NSString *)password completionHandler:(WZGaraponAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/auth"];
    NSDictionary *parameter = @{@"type": @"login",
                                @"loginid": loginId,
                                @"md5pswd": password
                                };
    
    WZGaraponRequest *request = [self request];
    [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];            
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            NSInteger result = [wrapResponse intgerValueWithKey:@"login" defaultValue:-1];
            if (!(status == 1 && result == 1)) {
                error = [[WZGaraponError alloc] initWithGaraponTvV3Api:WZGaraponAuthLoginApi status:status userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
            }
            _firmwareVersion = [wrapResponse stringValueWithKey:@"version" defaultValue:nil];
            
            // store to re-login
            _sessionId = request.sessionId;
            _loginId = loginId;
            _password = password;
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
    
    WZGaraponRequest *request = [self request];
    [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            NSInteger result = [wrapResponse intgerValueWithKey:@"logout" defaultValue:-1];
            if (result != 1) {
                error = [[WZGaraponError alloc] initWithGaraponTvV3Api:WZGaraponAuthLogoutApi status:status userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
            } else {
                _sessionId = nil;
            }
        }
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)postRequestRetryIfSessionFailedWithURLString:(NSString *)URLString parameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    __weak WZGaraponTv *me = self;
    WZGaraponRequest *request = [self request];
    [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status == 0) {
                [me loginWithLoginId:_loginId password:_password completionHandler:^(NSError *loginError) {
                    if (loginError) {
                        if (completionHandler) {
                            completionHandler(response, error);
                        }
                    } else {
                        WZGaraponRequest *request = [self request];
                        [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response2, NSError *error2) {
                            if (completionHandler) {
                                completionHandler(response2, error2);
                            }
                        }];
                    }
                }];
                return;
            }
        }

        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)searchWithParameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/search"];
    [self postRequestRetryIfSessionFailedWithURLString:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZGaraponError alloc] initWithGaraponTvV3Api:WZGaraponSearchApi status:status userInfo:nil];
            }
        }        
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)searchWithGtvid:(NSString *)gtvid completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    assert(gtvid);
    NSDictionary *params = @{@"gtvid": gtvid};
    [self searchWithParameter:params completionHandler:completionHandler];
}

- (void)favoriteWithParameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/favorite"];
    [self postRequestRetryIfSessionFailedWithURLString:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZGaraponError alloc] initWithGaraponTvV3Api:WZGaraponSearchApi status:status userInfo:nil];
            }
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)favoriteWithGtvid:(NSString *)gtvid rank:(NSInteger)rank completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    assert(gtvid);
    NSDictionary *params = @{@"gtvid": gtvid, @"rank": [NSNumber numberWithInteger:rank]};
    [self favoriteWithParameter:params completionHandler:completionHandler];
}

- (void)channelWithCompletionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/channel"];
    [self postRequestRetryIfSessionFailedWithURLString:URLString parameter:nil completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            WZGaraponWrapDictionary *wrapResponse = [WZGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZGaraponError alloc] initWithGaraponTvV3Api:WZGaraponChannelApi status:status userInfo:nil];
            }
        }
        
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

@end
