//
//  WZGaraponError.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponError.h"

@implementation WZGaraponError

- (id)initWithCode:(NSInteger)code
{
    if (self = [super initWithDomain:WZGaraponErrorDomain code:code userInfo:nil]) {
    }
    return self;
}

- (NSString *)localizedDescription
{    
    NSString *description = self.userInfo[@"description"];
    if (description) {
        return description;
    }
    return [super localizedDescription];
}

@end
