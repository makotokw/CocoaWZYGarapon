//
//  WZYGaraponWeb.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponWeb.h"
#import "WZYGaraponError.h"
#import "WZYGaraponRequest.h"

@implementation WZYGaraponWeb

{
    WZYGaraponRequest *_httpClient;
}

@dynamic devId;

- (id)init
{
    self = [super init];
    if (self) {
        _httpClient = [[WZYGaraponRequest alloc] init];
    }
    return self;
}

- (NSString *)devId
{
    return _httpClient.devId;
}

- (void)setDevId:(NSString *)devId
{
    _httpClient.devId = devId;
}

- (void)getGaraponTvAddressWithUserId:(NSString *)userId rawPassword:(NSString *)rawPassword completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    [self getGaraponTvAddressWithUserId:userId md5passwd:[WZYGaraponRequest md5StringWithString:rawPassword] completionHandler:completionHandler];
}

- (void)getGaraponTvAddressWithUserId:(NSString *)userId md5passwd:(NSString *)md5passwd completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [NSString stringWithFormat:@"%@://%@%@", @"http", WZY_GARAPON_AUTH_HOST, @"/getgtvaddress" ];
    NSDictionary *parameter = @{@"user": userId,
                                @"md5passwd": md5passwd,
                                @"dev_id": _httpClient.devId
                                };
    
    [_httpClient post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSString *status = response[@"0"];
            NSString *errorStatus = response[@"1"];
            
            // no response but http status 200?
            if (!status && !errorStatus) {
                errorStatus = @"no response";
            }
            if (errorStatus) {
                WZYGaraponError *garaponError = [[WZYGaraponError alloc] initWithDomain:WZYGaraponErrorDomain
                                                          code:WZYGaraponAuthenticationFailedError
                                                      userInfo:nil];
                [garaponError setGaraponWebErrorStatus:errorStatus];
                error = garaponError;
            }
        }
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

@end
