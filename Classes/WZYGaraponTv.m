//
//  WZYGaraponTv.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponError.h"
#import "WZYGaraponWrapDictionary.h"
#import "WZYGaraponRequest.h"
#import "WZYGaraponTv.h"
#import "WZYGaraponTvChannel.h"
#import "WZYGaraponTvProgram.h"

#define WZYGaraponTvDefaultApiVersion @"v3"

@implementation WZYGaraponTv

{
    NSString *_devId, *_sessionId;
    NSString *_loginId, *_password;
}

@synthesize host = _host, port = _port, port2 = _port2, apiVersion = _apiVersion;
@synthesize globalIPAddress = _globalIPAddress, privateIPAddress = _privateIPAddress, globalPort = _globalPort;
@synthesize gtvVersion = _gtvVersion, firmwareVersion = _firmwareVersion;
@synthesize devId = _devId;
@synthesize sessionId = _sessionId;
@dynamic hasSession;

+ (id)garaponTvWithAddressResponse:(NSDictionary *)response apiVersion:(NSString *)apiVersionString
{
    WZYGaraponTv *tv = [[WZYGaraponTv alloc] init];
    tv.apiVersion = apiVersionString;
    [tv setHostAndPortWithAddressResponse:response];
    return tv;
}

- (id)init
{
    self = [super init];
    if (self) {
        _apiVersion = WZYGaraponTvDefaultApiVersion;
    }
    return self;
}

- (id)initWithHost:(NSString *)host port:(NSInteger)port apiVersion:(NSString *)apiVersionString
{
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _apiVersion = (apiVersionString) ? apiVersionString : WZYGaraponTvDefaultApiVersion;
    }
    return self;
}

- (void)setHostAndPortWithAddressResponse:(NSDictionary *)response
{
    WZYGaraponWrapDictionary *wrap = [WZYGaraponWrapDictionary wrapWithDictionary:response];

    NSString *host = [wrap stringValueWithKey:@"ipaddr" defaultValue:nil];
    _privateIPAddress = [wrap stringValueWithKey:@"pipaddr" defaultValue:nil];
    _globalIPAddress = [wrap stringValueWithKey:@"gipaddr" defaultValue:nil];
    _globalPort = [wrap intgerValueWithKey:@"port" defaultValue:80];

    NSInteger port = [host isEqualToString:_globalIPAddress] ? _globalPort : 80;

    _host = host;
    _port = port;
    _port2 = [wrap intgerValueWithKey:@"port2" defaultValue:51935];
    _gtvVersion = [wrap stringValueWithKey:@"gtvver" defaultValue:nil];

    // remove GTV (GTV3.0 -> 3.0)
    _gtvVersion = [_gtvVersion stringByReplacingOccurrencesOfString:@"GTV" withString:@""];
}

- (void)setAlternateHostAndrPort
{
    if (_globalIPAddress && _privateIPAddress) {
        if ([_host isEqualToString:_globalIPAddress]) {
            _host = _privateIPAddress;
            _port = 80;
        } else {
            _host = _globalIPAddress;
            _port = _globalPort;
        }
    }
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
    return [NSString stringWithFormat:@"http://%@:%d%@", _host, (int)_port, path];
}

- (NSString *)apiURLStringWithPath:(NSString *)path
{
    if (_port == 80) {
        return [NSString stringWithFormat:@"http://%@/gapi/%@%@", _host, _apiVersion, path];
    }
    return [NSString stringWithFormat:@"http://%@:%d/gapi/%@%@", _host, (int)_port, _apiVersion, path];
}

+ (NSString *)formatDate:(NSTimeInterval)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatDateTime:(NSTimeInterval)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
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
             @"sdate": [WZYGaraponTv formatDateTime:sdate],
             @"sdate": [WZYGaraponTv formatDateTime:edate],
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

- (NSString *)thumbnailURLStringWithProgram:(WZYGaraponTvProgram *)program
{
    return [self thumbnailURLStringWithId:program.gtvid];
}

- (NSString *)httpLiveStreamingURLStringWithId:(NSString *)gtvid
{
    NSString *path = [NSString stringWithFormat:@"/cgi-bin/play/m3u8.cgi?%@-%@", gtvid, _sessionId];
    return [self URLStringWithPath:path];
}

- (NSString *)httpLiveStreamingURLStringWithProgram:(WZYGaraponTvProgram *)program
{
    return [self httpLiveStreamingURLStringWithId:program.gtvid];
}

- (void)loginWithLoginId:(NSString *)loginId rawPassword:(NSString *)rawPassword completionHandler:(WZYGaraponAsyncBlock)completionHandler
{
    [self loginWithLoginId:loginId password:[WZYGaraponRequest md5StringWithString:rawPassword] completionHandler:completionHandler];
}

- (WZYGaraponRequest *)request
{
    WZYGaraponRequest *r = [[WZYGaraponRequest alloc] initWithSessionId:_sessionId];
    r.devId = _devId;
    return r;
}

- (void)loginWithLoginId:(NSString *)loginId password:(NSString *)password completionHandler:(WZYGaraponAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/auth"];
    NSDictionary *parameter = @{@"type": @"login",
                                @"loginid": loginId,
                                @"md5pswd": password
                                };

    WZYGaraponRequest *request = [self request];
    [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {

        if (!error) {
            WZYGaraponWrapDictionary *wrapResponse = [WZYGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            NSInteger result = [wrapResponse intgerValueWithKey:@"login" defaultValue:-1];
            if (!(status == 1 && result == 1)) {
                error = [[WZYGaraponError alloc] initWithGaraponTvV3Api:WZYGaraponAuthLoginApi status:status userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
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

- (void)logoutWithCompletionHandler:(WZYGaraponAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/auth"];
    NSDictionary *parameter = @{@"type": @"logout"};

    WZYGaraponRequest *request = [self request];
    [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {

        if (!error) {
            WZYGaraponWrapDictionary *wrapResponse = [WZYGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            NSInteger result = [wrapResponse intgerValueWithKey:@"logout" defaultValue:-1];
            if (result != 1) {
                error = [[WZYGaraponError alloc] initWithGaraponTvV3Api:WZYGaraponAuthLogoutApi status:status userInfo:@{@"result":[NSNumber numberWithInteger:result]}];
            } else {
                _sessionId = nil;
            }
        }

        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

- (void)postRequestRetryIfSessionFailedWithURLString:(NSString *)URLString parameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    __weak WZYGaraponTv *me = self;
    WZYGaraponRequest *request = [self request];
    [request post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            WZYGaraponWrapDictionary *wrapResponse = [WZYGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status == 0) {
                [me loginWithLoginId:_loginId password:_password completionHandler:^(NSError *loginError) {
                    if (loginError) {
                        if (completionHandler) {
                            completionHandler(response, error);
                        }
                    } else {
                        WZYGaraponRequest *request = [self request];
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

- (void)searchWithParameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/search"];
    [self postRequestRetryIfSessionFailedWithURLString:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            WZYGaraponWrapDictionary *wrapResponse = [WZYGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZYGaraponError alloc] initWithGaraponTvV3Api:WZYGaraponSearchApi status:status userInfo:nil];
            }
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)searchWithGtvid:(NSString *)gtvid completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    assert(gtvid);
    NSDictionary *params = @{@"gtvid": gtvid};
    [self searchWithParameter:params completionHandler:completionHandler];
}

- (void)favoriteWithParameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/favorite"];
    [self postRequestRetryIfSessionFailedWithURLString:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            WZYGaraponWrapDictionary *wrapResponse = [WZYGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZYGaraponError alloc] initWithGaraponTvV3Api:WZYGaraponSearchApi status:status userInfo:nil];
            }
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

- (void)favoriteWithGtvid:(NSString *)gtvid rank:(NSInteger)rank completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    assert(gtvid);
    NSDictionary *params = @{@"gtvid": gtvid, @"rank": [NSNumber numberWithInteger:rank]};
    [self favoriteWithParameter:params completionHandler:completionHandler];
}

- (void)channelWithCompletionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [self apiURLStringWithPath:@"/channel"];
    [self postRequestRetryIfSessionFailedWithURLString:URLString parameter:nil completionHandler:^(NSDictionary *response, NSError *error) {

        if (!error) {
            WZYGaraponWrapDictionary *wrapResponse = [WZYGaraponWrapDictionary wrapWithDictionary:response];
            NSInteger status = [wrapResponse intgerValueWithKey:@"status" defaultValue:-1];
            if (status != 1) {
                error = [[WZYGaraponError alloc] initWithGaraponTvV3Api:WZYGaraponChannelApi status:status userInfo:nil];
            }
        }

        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

@end
