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
@property (readonly) NSDate *enddate;
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

// proxy state when its properties are not fully loaded
@property BOOL isProxy;

+ (NSArray *)arrayWithSearchResponse:(NSDictionary *)response;
+ (NSURL *)socialURLWithGtvid:(NSString *)gtvid;

- (BOOL)isEqualGtvid:(WZGaraponTvProgram *)program;
- (void)mergeFrom:(WZGaraponTvProgram *)source;

@end
