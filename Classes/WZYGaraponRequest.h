//
//  WZYGaraponRequest.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZYGaraponGlobal.h"

@interface WZYGaraponRequest : NSObject

@property NSString *devId;
@property (readonly) NSString *sessionId;

+ (NSString *)md5StringWithString:(NSString *)string;

- (id)initWithSessionId:(NSString *)sessionId;

- (void)get:(NSString *)url parameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;
- (void)post:(NSString *)url parameter:(NSDictionary *)parameter completionHandler:(WZYGaraponRequestAsyncBlock)completionHandler;

@end
