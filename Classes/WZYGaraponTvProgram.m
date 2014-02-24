//
//  WZYGaraponTvProgram.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponTvProgram.h"
#import "WZYGaraponWrapDictionary.h"

@implementation WZYGaraponTvProgram

@synthesize gtvid = _gtvid, startdate = _startdate, duration = _duration, ch = _ch, title = _title, descriptionText = _descriptionText, genres = _genres, favorite = _favorite, captionHit = _captionHit, caption = _caption, bc = _bc, bcTags = _bcTags, ts = _ts;

@dynamic enddate;
@dynamic socialURL;

static NSDate *dateStringToDate(NSString *dateString)
{
    static NSDateFormatter *dateFormatter = nil;    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return [dateFormatter dateFromString:dateString];
}

static NSTimeInterval durationStringToTimeInterval(NSString *durationString)
{
    NSTimeInterval secound = 0;
    NSArray *a = [durationString componentsSeparatedByString:@":"];
    switch (a.count) {
        case 2:
            secound = ((NSString *)a[0]).integerValue * 60 + ((NSString *)a[1]).integerValue;
            break;
        case 3:
            secound = ((NSString *)a[0]).integerValue * 3600 + ((NSString *)a[1]).integerValue * 60 + ((NSString *)a[2]).integerValue;
            break;
        default:
            break;
    }
    return secound;
}

+ (NSArray *)arrayWithSearchResponse:(NSDictionary *)response
{
    WZYGaraponWrapDictionary *wrap = [WZYGaraponWrapDictionary wrapWithDictionary:response];
    NSInteger hit = [wrap intgerValueWithKey:@"hit" defaultValue:0];
    if (hit <= 0) {
        return nil;
    }
    
    id value = response[@"program"];
    if (![value isKindOfClass:[NSArray class]]) {
        return nil;
    }    
    
    NSMutableArray *programs = [[NSMutableArray alloc] init];
    
    NSArray *program = value;
    
    for (NSDictionary *dict in program) {
        wrap.dict = dict;
        
        WZYGaraponTvProgram *p = [[WZYGaraponTvProgram alloc] init];
        
        p.gtvid = [wrap stringValueWithKey:@"gtvid" defaultValue:nil];
        p.startdate = dateStringToDate([wrap stringValueWithKey:@"startdate" defaultValue:nil]);
        p.duration = durationStringToTimeInterval([wrap stringValueWithKey:@"duration" defaultValue:nil]);
        p.ch = [wrap intgerValueWithKey:@"ch" defaultValue:0];
        p.title = [wrap stringValueWithKey:@"title" defaultValue:nil];
        p.descriptionText = [wrap stringValueWithKey:@"description" defaultValue:nil];
        p.genres = dict[@"genre"];
        p.favorite = [wrap intgerValueWithKey:@"favorite" defaultValue:0];
        p.captionHit = [wrap intgerValueWithKey:@"caption_hit" defaultValue:0];
        p.caption = dict[@"caption"];
        p.bc = [wrap stringValueWithKey:@"bc" defaultValue:nil];
        p.bcTags = [wrap stringValueWithKey:@"bc_tags" defaultValue:nil];
        p.ts = [wrap intgerValueWithKey:@"ts" defaultValue:0];

        [programs addObject:p];
    }
    
    return programs;
}

- (NSDate *)enddate
{
    return [_startdate dateByAddingTimeInterval:_duration];
}

- (NSURL *)socialURL
{
    return [WZYGaraponTvProgram socialURLWithGtvid: self.gtvid];
}

+ (NSURL *)socialURLWithGtvid:(NSString *)gtvid
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://site.garapon.tv/social_gtvid_view?gtvid=%@", gtvid]];
}

- (BOOL)isEqualGtvid:(WZYGaraponTvProgram *)program
{
    return [self.gtvid isEqualToString:program.gtvid];
}

- (void)mergeFrom:(WZYGaraponTvProgram *)source
{
    if (![self.gtvid isEqualToString:source.gtvid]) {
        return;
    }
    
    self.startdate = source.startdate;
    self.duration = source.duration;
    self.ch = source.ch;
    self.title = source.title;
    self.descriptionText = source.descriptionText;
    self.genres = source.genres;
    self.favorite = source.favorite;
    self.captionHit = source.captionHit;
    self.caption = source.caption;
    self.bc = source.bc;
    self.bcTags = source.bcTags;
    self.ts = source.ts;
}

@end
