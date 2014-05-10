//
//  WZYGaraponGlobal.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

@class WZYGaraponTvProgram;

#define WZYGaraponLog(...) NSLog(__VA_ARGS__)
#if WZY_GARAPON_DEBUG
#define WZYGaraponLogD(...) NSLog(__VA_ARGS__)
#else
#define WZYGaraponLogD(...) ;
#endif

typedef void (^WZYGaraponAsyncBlock)(NSError *error);
typedef void (^WZYGaraponRequestAsyncBlock)(NSDictionary *response, NSError *error);
typedef void (^WZYGaraponTvProgramBlock)(WZYGaraponTvProgram *program);

#define WZY_GARAPON_AUTH_HOST @"garagw.garapon.info"

typedef enum : NSInteger {
    WZYGaraponUnknownApiCategory,
    WZYGaraponWebAuthApiCategory,
    WZYGaraponTvV3ApiCategory,
} WZYGaraponApiCategory;

typedef enum : NSInteger {
    WZYGaraponUnknownApi,
    WZYGaraponAuthApi,
    WZYGaraponAuthLoginApi,
    WZYGaraponAuthLogoutApi,
    WZYGaraponSearchApi,
    WZYGaraponFavoriteApi,
    WZYGaraponChannelApi,
} WZYGaraponApiType;

FOUNDATION_EXPORT NSString *WZYGaraponLocalizedString(NSString *key);
