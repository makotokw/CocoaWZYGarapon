//
//  WZGaraponRequest.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WZGaraponGlobal.h"

@interface WZGaraponRequest : NSObject

@property NSString *devId;
@property (readonly) NSString *sessionId;

+ (NSString *)md5StringWithString:(NSString *)string;

- (void)get:(NSString *)url parameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler;
- (void)post:(NSString *)url parameter:(NSDictionary *)parameter completionHandler:(WZGaraponRequestAsyncBlock)completionHandler;

@end
