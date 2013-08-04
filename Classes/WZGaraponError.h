//
//  WZGaraponError.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZGaraponGlobal.h"

#define WZGaraponErrorDomain @"com.makotokw.ios.garapon"

typedef enum : NSInteger  {
    WZGaraponUnknownError,
    WZGaraponInvalidParameterError,
    WZGaraponDatabaseConnectionFailedError,
    WZGaraponSessionFailedError,
    WZGaraponSyncAuthenticationRequiredError,
    WZGaraponAuthenticationRequiredError,
    WZGaraponAuthenticationFailedError,
    WZGaraponVideoFileNotFoundError,
} WZGaraponErrorCode;


@interface WZGaraponError : NSError

- (id)initWithGaraponTvV3Api:(WZGaraponApiType)apiType status:(NSInteger)status userInfo:(NSDictionary *)dict;

@end
