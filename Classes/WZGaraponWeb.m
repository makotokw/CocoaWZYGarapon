//
//  WZGaraponWeb.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponWeb.h"
#import "WZGaraponError.h"
#import "WZGaraponRequest.h"

@implementation WZGaraponWeb

{
    WZGaraponRequest *_httpClient;
}

@dynamic devId;

- (id)init
{
    self = [super init];
    if (self) {
        _httpClient = [[WZGaraponRequest alloc] init];
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

- (void)getGaraponTvAddressWithUserId:(NSString *)userId rawPassword:(NSString *)rawPassword completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    [self getGaraponTvAddressWithUserId:userId md5passwd:[WZGaraponRequest md5StringWithString:rawPassword] completionHandler:completionHandler];
}

- (void)getGaraponTvAddressWithUserId:(NSString *)userId md5passwd:(NSString *)md5passwd completionHandler:(WZGaraponRequestAsyncBlock)completionHandler
{
    NSString *URLString = [NSString stringWithFormat:@"%@://%@%@", @"http", WZ_GARAPON_AUTH_HOST, @"/getgtvaddress" ];
    NSDictionary *parameter = @{@"user": userId,
                                @"md5passwd": md5passwd,
                                @"dev_id": _httpClient.devId
                                };
    
    [_httpClient post:URLString parameter:parameter completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            NSString *errorStatus = response[@"1"];
            if (errorStatus) {
                error = [[WZGaraponError alloc] initWithDomain:WZGaraponErrorDomain
                                                          code:WZGaraponAuthenticationFailedError
                                                      userInfo:@{@"description": errorStatus}];
            }
        }        
        if (completionHandler) {
            completionHandler(response, error);
        }
    }];
}

@end
