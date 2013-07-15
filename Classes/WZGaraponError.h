//
//  WZGaraponError.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WZGaraponErrorDomain @"com.makotokw.ios.garapon"

enum {
    WZGaraponErrorUnknown = 0,
    WZGaraponErrorAuthenticationRequired = -1,
    WZGaraponErrorAuthenticationFailed = -2,
};

@interface WZGaraponError : NSError



@end
