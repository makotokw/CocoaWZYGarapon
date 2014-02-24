//
//  WZYGaraponTvSite.h
//  WZYGarapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WZYGaraponTvSiteCompletionHandler)(NSString *gtvid, NSString *originalGtvid);

@interface WZYGaraponTvSite : NSObject

@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, copy) WZYGaraponTvSiteCompletionHandler completionHandler;

- (void)prepareGaraponTvSite:(NSDictionary *)dict;
- (void)setGaraponId:(NSString *)garaponId password:(NSString *)password;
- (void)queryGtvid:(NSString *)gtvid;

+ (NSString *)gtvidOfURLString:(NSString *)URLString;

@end
