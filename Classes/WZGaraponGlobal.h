//
//  WZGaraponGlobal.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

@class WZGaraponTvProgram;

typedef void (^WZGaraponAsyncBlock)(NSError *error);
typedef void (^WZGaraponRequestAsyncBlock)(NSDictionary *response, NSError *error);
typedef void (^WZGaraponTvProgramBlock)(WZGaraponTvProgram *program);

#define WZ_GARAPON_AUTH_HOST @"garagw.garapon.info"

typedef enum : NSInteger {
    WZGaraponUnknownApiCategory,
    WZGaraponWebAuthApiCategory,
    WZGaraponTvV3ApiCategory,
} WZGaraponApiCategory;

typedef enum : NSInteger {
    WZGaraponUnknownApi,
    WZGaraponAuthApi,
    WZGaraponAuthLoginApi,
    WZGaraponAuthLogoutApi,
    WZGaraponSearchApi,
    WZGaraponFavoriteApi,
    WZGaraponChannelApi,
} WZGaraponApiType;