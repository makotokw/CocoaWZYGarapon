//
//  WZYGaraponTv.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZYGaraponGlobal.h"

@class WZYGaraponTvProgram;

@interface WZYGaraponTv : NSObject

@property NSString *host;
@property NSInteger port;
@property NSInteger port2;
@property NSString *globalIPAddress;
@property NSString *privateIPAddress;
@property NSInteger globalPort;
@property NSString *gtvVersion;
@property NSString *apiVersion;
@property (readonly) NSString *firmwareVersion;
@property NSString *devId;
@property (readonly) NSString *sessionId;
@property (readonly) BOOL hasSession;

+ (id)garaponTvWithAddressResponse:(NSDictionary *)response apiVersion:(NSString *)apiVersionString;
- (id)initWithHost:(NSString *)host port:(NSInteger)port apiVersion:(NSString *)apiVersionString;
- (void)setHostAndPortWithAddressResponse:(NSDictionary *)response;
- (void)setAlternateHostAndrPort;

+ (NSString *)formatDate:(NSTimeInterval)timestamp;
+ (NSString *)formatDateTime:(NSTimeInterval)timestamp;
+ (NSDictionary *)recordingProgramParams;

- (NSURL *)URLWithPath:(NSString *)path;

- (NSString *)thumbnailURLStringWithId:(NSString *)gtvid;
- (NSString *)thumbnailURLStringWithProgram:(WZYGaraponTvProgram *)program;
- (NSString *)httpLiveStreamingURLStringWithId:(NSString *)gtvid;
- (NSString *)httpLiveStreamingURLStringWithProgram:(WZYGaraponTvProgram *)program;

- (void)loginWithLoginId:(NSString *)loginId rawPassword:(NSString *)rawPassword completionHandler:(WZYGaraponAsyncBlock)completionHandler;
- (void)loginWithLoginId:(NSString *)loginId password:(NSString *)password completionHandler:(WZYGaraponAsyncBlock)completionHandler;
- (void)logoutWithCompletionHandler:(WZYGaraponAsyncBlock)completionHandler;
- (void)searchWithParameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)searchWithGtvid:(NSString *)gtvid completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)favoriteWithParameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)favoriteWithGtvid:(NSString *)gtvid rank:(NSInteger)rank completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)channelWithCompletionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;

@end
