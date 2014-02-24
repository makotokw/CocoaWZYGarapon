//
//  WZYGaraponTvChannel.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponTvChannel.h"
#import "WZYGaraponWrapDictionary.h"

@implementation WZYGaraponTvChannel

- (id)initWithCoder:(NSCoder *)coder
{
    _TSID = [coder decodeIntegerForKey:@"TSID"];
    _name = [coder decodeObjectForKey:@"name"];
    _hashTag = [coder decodeObjectForKey:@"hashTag"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:_TSID forKey:@"TSID"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_hashTag forKey:@"hashTag"];
}

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
    
    WZYGaraponWrapDictionary *wrap = [[WZYGaraponWrapDictionary alloc] init];
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
        
        WZYGaraponTvChannel *channel = [[WZYGaraponTvChannel alloc] init];
        channel.TSID = TSID;
        channel.name = [wrap stringValueWithKey:@"ch_name" defaultValue:nil];
        channel.hashTag = [wrap stringValueWithKey:@"hash_tag" defaultValue:nil];
        
        [channels addObject:channel];
    }
    
    return channels;
}

@end

