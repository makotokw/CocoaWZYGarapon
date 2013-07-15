//
//  WZGaraponWrapDictionary.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponWrapDictionary.h"

@implementation WZGaraponWrapDictionary

@synthesize dict = _dict;

+ (id)wrapWithDictionary:(NSDictionary *)otherDictionary
{
    return [[WZGaraponWrapDictionary alloc] initWithDictionary:otherDictionary];
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super init];
    if (self) {
        _dict = otherDictionary;
    }
    return self;
}

- (id)objectWithKey:(id)key
{
    return [_dict objectForKey:key];
}

- (BOOL)isNilOrNSNullWithKey:(id)key
{
    id value = [_dict objectForKey:key];
    return (!value || value == [NSNull null]) ? YES : NO;
}

- (NSInteger)intgerValueWithKey:(id)key defaultValue:(NSInteger)defaultValue
{
    id value = [_dict objectForKey:key];
    if (!value) {
        return defaultValue;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *numberValue = value;
        return numberValue.integerValue;
    }
    return [value description].integerValue;
}

- (NSString *)stringValueWithKey:(id)key defaultValue:(NSString *)defaultValue
{
    id value = [_dict objectForKey:key];
    if (!value) {
        return defaultValue;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    return [value description];
}

@end
