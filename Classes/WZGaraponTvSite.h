//
//  WZGaraponTvSite.h
//  WZGarapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WZGaraponTvSiteCompletionHandler)(NSString *gtvid, NSString *originalGtvid);

@interface WZGaraponTvSite : NSObject

@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, copy) WZGaraponTvSiteCompletionHandler completionHandler;

- (void)prepareGaraponTvSite:(NSDictionary *)dict;
- (void)setGaraponId:(NSString *)garaponId password:(NSString *)password;
- (void)queryGtvid:(NSString *)gtvid;

+ (NSString *)gtvidOfURLString:(NSString *)URLString;

@end
