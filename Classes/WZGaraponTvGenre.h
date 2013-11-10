//
//  WZGaraponTvGenre.h
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZGaraponTvGenre : NSObject

+ (NSDictionary *)dictionaryForGenre;
+ (NSString *)genreNameWithKey:(id)key;
+ (NSString *)majorGenreNameWithKey:(id)key;

@end
