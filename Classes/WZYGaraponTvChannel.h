//
//  WZYGaraponTvChannel.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZYGaraponTvChannel : NSObject

@property NSInteger TSID;
@property NSString *name;
@property NSString *hashTag;

+ (NSArray *)arrayWithChannelResponse:(NSDictionary *)response;

@end
