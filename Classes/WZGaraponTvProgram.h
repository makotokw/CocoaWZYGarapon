//
//  WZGaraponTvProgram.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZGaraponTvProgram : NSObject

@property NSString *gtvid;
@property NSDate *startdate;
@property NSTimeInterval duration;
@property NSInteger ch;
@property NSString *title;
@property NSString *descriptionText;
@property NSArray *genres;
@property NSInteger favorite;
@property NSInteger captionHit;
@property NSArray *caption;
@property NSString *bc;
@property NSString *bcTags;
@property NSInteger ts;

@property (readonly) NSURL *socialURL;

+ (NSArray *)arrayWithSearchResponse:(NSDictionary *)response;
- (void)mergeFrom:(WZGaraponTvProgram *)source;

@end
