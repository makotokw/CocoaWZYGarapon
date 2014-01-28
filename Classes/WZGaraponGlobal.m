//
//  WZGaraponGlobal.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponGlobal.h"

NSString *WZGaraponLocalizedString(NSString *key)
{
    return NSLocalizedStringFromTable(key, @"WZGarapon", nil);
}