//
//  WZYGaraponTvSiteTweet.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZYGaraponTvSiteTweet : NSObject

@property (retain, readonly) NSString *embedGtvid;
@property (retain, readwrite) NSDictionary *status;

- (id)initWithStatus:(NSDictionary *)status;

@end
