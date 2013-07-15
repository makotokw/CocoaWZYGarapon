//
//  WZGaraponTvChannel.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponTvChannel.h"
#import "WZGaraponWrapDictionary.h"

@implementation WZGaraponTvChannel

@synthesize TSID = _TSID;
@synthesize name = _name;
@synthesize hashTag = _hashTag;

+ (NSArray *)arrayWithChannelResponse:(NSDictionary *)response
{
    id value = response[@"ch_list"];
    if (!value) {
        return nil;
    }
    
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    
    WZGaraponWrapDictionary *wrap = [[WZGaraponWrapDictionary alloc] init];
    NSDictionary *chList = value;
    
    for (id key in [chList allKeys]) {

        NSString *keyString = [key description];
        NSInteger TSID = [keyString integerValue];
        
        if (TSID <= 0) {
            continue;
        }
        
        id channelValue = [chList objectForKey:key];
        if (![channelValue isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        wrap.dict = channelValue;
        
        WZGaraponTvChannel *channel = [[WZGaraponTvChannel alloc] init];
        channel.TSID = TSID;
        channel.name = [wrap stringValueWithKey:@"ch_name" defaultValue:nil];
        channel.hashTag = [wrap stringValueWithKey:@"hash_tag" defaultValue:nil];
        
        [channels addObject:channel];
    }
    
    return channels;
}

@end
