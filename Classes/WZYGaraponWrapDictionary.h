//
//  WZYGaraponDictionary.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZYGaraponWrapDictionary : NSObject

@property (retain) NSDictionary *dict;

+ (id)wrapWithDictionary:(NSDictionary *)otherDictionary;
- (id)initWithDictionary:(NSDictionary *)otherDictionary;
- (id)objectWithKey:(id)key;
- (BOOL)isNilOrNSNullWithKey:(id)key;
- (NSInteger)intgerValueWithKey:(id)key defaultValue:(NSInteger)defaultValue;
- (NSString *)stringValueWithKey:(id)key defaultValue:(NSString *)defaultValue;

@end
