//
//  WZGaraponTvSiteActivity.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//
//

#import "WZGaraponGlobal.h"
#import "WZGaraponTvSiteActivity.h"

@implementation WZGaraponTvSiteActivity

- (NSString *)activityType
{
    return @"tv.garapon.site";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"WZGaraponResources.bundle/GaraponTvSiteActivity.png"];
}

- (NSString *)activityTitle
{
    return WZGaraponLocalizedString(@"GaraponTvActivityTitle");
}

- (NSURL *)garaponTvSiteURLWithActivityItem:(id)activityItem
{
    if ([activityItem isKindOfClass:[NSURL class]]) {
        NSURL *u = activityItem;
        if ([u.host isEqualToString:@"site.garapon.tv"]) {
            return u;
        }
    }
    else if ([activityItem isKindOfClass:[NSString class]]) {
        NSString *s = activityItem;
        NSRange match = [s rangeOfString:@"https?://site\\.garapon\\.tv[\\w/:%#~=&\\?\\.\\+\\-]+" options:NSRegularExpressionSearch];
        if (match.location != NSNotFound) {
            return [NSURL URLWithString:[s substringWithRange:match]];
        }
    }
    return nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([self garaponTvSiteURLWithActivityItem:activityItem]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        NSURL *URL = [self garaponTvSiteURLWithActivityItem:activityItem];
        if (URL) {
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
}

@end
