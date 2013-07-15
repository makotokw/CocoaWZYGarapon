//
//  WZGaraponWeb.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZGaraponGlobal.h"

@interface WZGaraponWeb : NSObject

@property NSString *devId;

- (void)getGaraponTvAddressWithUserId:(NSString *)userId rawPassword:(NSString *)rawPassword completionHandler:(WZGaraponRequestAsyncBlock)completionHandler;
- (void)getGaraponTvAddressWithUserId:(NSString *)userId md5passwd:(NSString *)md5passwd completionHandler:(WZGaraponRequestAsyncBlock)completionHandler;

@end
