//
//  WZYGaraponError.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZYGaraponGlobal.h"

#define WZYGaraponErrorDomain @"com.makotokw.ios.garapon"

typedef enum : NSInteger  {
    WZYGaraponUnknownError,
    WZYGaraponInvalidParameterError,
    WZYGaraponDatabaseConnectionFailedError,
    WZYGaraponSessionFailedError,
    WZYGaraponSyncAuthenticationRequiredError,
    WZYGaraponAuthenticationRequiredError,
    WZYGaraponAuthenticationFailedError,
    WZYGaraponVideoFileNotFoundError,
} WZYGaraponErrorCode;


@interface WZYGaraponError : NSError

- (id)initWithGaraponTvV3Api:(WZYGaraponApiType)apiType status:(NSInteger)status userInfo:(NSDictionary *)dict;
- (void)setGaraponWebErrorStatus:(NSString *)status;

@end
