//
//  WZYGaraponTvSiteTweet.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponTvSiteTweet.h"
#import "WZYGaraponTvSite.h"

@implementation WZYGaraponTvSiteTweet

{
    NSDictionary *_status;
}

- (id)initWithStatus:(NSDictionary *)status
{
    self = [super init];
    if (self) {
        [self setStatus:status];
    }
    return self;
}

- (NSDictionary *)status
{
    return _status;
}

- (void)setStatus:(NSDictionary *)status
{
    _status = status;
    
    NSDictionary *displayStatus = status[@"retweeted_status"];
    if (!displayStatus) {
        displayStatus = status;
    }
    
    NSDictionary *entities = status[@"entities"];
    if (entities) {
        NSArray *urls = entities[@"urls"];
        for (NSDictionary *urlEntity in urls) {
            NSString *u = urlEntity[@"expanded_url"];
            if (u) {
                NSRange range = [u rangeOfString:@"site.garapon.tv"];
                if (range.location != NSNotFound) {
                    NSString *gtvid = [WZYGaraponTvSite gtvidOfURLString:u];
                    if (gtvid) {
                        _embedGtvid = gtvid;
                        break;
                    }
                }
            }
        }
    }
}

@end
