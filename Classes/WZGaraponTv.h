//
//  WZGaraponTv.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZGaraponGlobal.h"

@class WZGaraponTvProgram;

@interface WZGaraponTv : NSObject

@property NSString *host;
@property NSInteger port;
@property NSString *apiVersion;
@property (readonly) NSString *firmwareVersion;
@property NSString *devId;
@property (readonly) NSString *sessionId;
@property (readonly) BOOL hasSession;

+ (id)garaponTvWithAddressResponse:(NSDictionary *)response apiVersion:(NSString *)apiVersionString;
- (id)initWithHost:(NSString *)host port:(NSInteger)port apiVersion:(NSString *)apiVersionString;
- (void)setHostAndPortWithAddressResponse:(NSDictionary *)response;

+ (NSString *)formatDate:(NSTimeInterval)timestamp;
+ (NSString *)formatDateTime:(NSTimeInterval)timestamp;

- (NSURL *)URLWithPath:(NSString *)path;

- (NSString *)thumbnailURLStringWithId:(NSString *)gtvid;
- (NSString *)thumbnailURLStringWithProgram:(WZGaraponTvProgram *)program;
- (NSString *)httpLiveStreamingURLStringWithId:(NSString *)gtvid;
- (NSString *)httpLiveStreamingURLStringWithProgram:(WZGaraponTvProgram *)program;

- (void)loginWithLoginId:(NSString *)loginId rawPassword:(NSString *)rawPassword completionHandler:(WZGaraponAsyncBlock)completionHandler;
- (void)loginWithLoginId:(NSString *)loginId password:(NSString *)password completionHandler:(WZGaraponAsyncBlock)completionHandler;
- (void)logoutWithCompletionHandler:(WZGaraponAsyncBlock)completionHandler;
- (void)searchWithParameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler;
- (void)channelWithCompletionHandler:(WZGaraponRequestAsyncBlock)completionHandler;

@end
