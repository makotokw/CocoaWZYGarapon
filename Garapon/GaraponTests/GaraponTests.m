//
//  GaraponTests.m
//  GaraponTests
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

// copy from GaraponTestDefines.sample.h
#import "GaraponTestDefines.h"
#import "GaraponTests.h"

#import "WZGaraponWeb.h"
#import "WZGaraponTv.h"
#import "WZGaraponTvChannel.h"
#import "WZGaraponTvProgram.h"

static WZGaraponWeb *sGraponWeb;
static WZGaraponTv *sGraponTv;

@implementation GaraponTests
{
    WZGaraponWeb *_garaponWeb;
    WZGaraponTv *_garaponTv;
}

+ (void)initialize
{
    sGraponWeb = [[WZGaraponWeb alloc] init];
    sGraponWeb.devId = GARAPON_DEV_ID;
    sGraponTv = [[WZGaraponTv alloc] initWithHost:GARAPON_TV_ADDRESS port:GARAPON_TV_PORT apiVersion:nil];
    sGraponTv.devId = GARAPON_DEV_ID;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _garaponWeb = sGraponWeb;
    _garaponTv = sGraponTv;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testMisc
{
    [self webAuth];
    [self login];
    [self channel];
    [self search];
    [self logout];
}

- (void)webAuth
{
    __block BOOL isFinished = NO;
    [_garaponWeb getGaraponTvAddressWithUserId:GARAPON_LOGINID md5passwd:GARAPON_MD5PSWD completionHandler:^(NSDictionary *response, NSError *error) {
        STAssertNil(error, @"authError");
        if (!error) {
            sGraponTv = [WZGaraponTv garaponTvWithAddressResponse:response apiVersion:nil];
        }
        isFinished = YES;
    }];
    while (!isFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (void)login
{
    __block BOOL isFinished = NO;
    [_garaponTv loginWithLoginId:GARAPON_LOGINID password:GARAPON_MD5PSWD completionHandler:^(NSError *error) {
        STAssertNil(error, @"loginError");
        isFinished = YES;
    }];
    while (!isFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (void)search
{
    if (!_garaponTv.hasSession) {
        STFail(@"garaponTv has no session");
        return;
    }
    
    __block BOOL isFinished = NO;
    [_garaponTv searchWithParameter:nil completionHandler:^(NSDictionary *response, NSError *error) {
        STAssertNil(error, @"searchError");
        if (!error) {
            NSArray *programs = [WZGaraponTvProgram arrayWithSearchResponse:response];
            for (WZGaraponTvProgram *p in programs) {
                NSLog(@"program %@, %@", p.gtvid, p.title);
            }
            
            STAssertTrue(programs.count > 0, @"programs.count > 0");
        }
        isFinished = YES;
    }];
    while (!isFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (void)channel
{
    if (!_garaponTv.hasSession) {
        STFail(@"garaponTv has no session");
        return;
    }
    
    __block BOOL isFinished = NO;
    [_garaponTv channelWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        STAssertNil(error, @"channelError");
        if (!error) {
            NSArray *channels = [WZGaraponTvChannel arrayWithChannelResponse:response];
            for (WZGaraponTvChannel *c in channels) {
                NSLog(@"channel %d, %@", c.TSID, c.name);
            }
            STAssertTrue(channels.count > 0, @"channels.count > 0");
        }
        isFinished = YES;
    }];
    while (!isFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (void)logout
{
    if (!_garaponTv.hasSession) {
        STFail(@"garaponTv has no session");
        return;
    }
    
    __block BOOL isFinished = NO;
    [_garaponTv logoutWithCompletionHandler:^(NSError *error) {
        STAssertNil(error, @"logoutError");
        isFinished = YES;
    }];
    while (!isFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

@end
