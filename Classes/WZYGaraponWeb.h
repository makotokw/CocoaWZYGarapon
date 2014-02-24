//
//  WZYGaraponWeb.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZYGaraponGlobal.h"

@interface WZYGaraponWeb : NSObject

@property NSString *devId;

- (void)getGaraponTvAddressWithUserId:(NSString *)userId rawPassword:(NSString *)rawPassword completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)getGaraponTvAddressWithUserId:(NSString *)userId md5passwd:(NSString *)md5passwd completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;

@end
