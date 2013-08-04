//
//  WZGaraponError.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponError.h"

@implementation WZGaraponError

{
    WZGaraponApiCategory _apiCategory;
    WZGaraponApiType _apiType;
    NSInteger _garaponError;
    NSInteger _garaponStatus;
    NSString *_garaponDescription;
    NSString *_garaponRecoverySuggestion;
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    if (self = [super initWithDomain:WZGaraponErrorDomain code:code userInfo:dict]) {
        _apiCategory = WZGaraponUnknownApiCategory;
        _apiType = WZGaraponUnknownApi;
        _garaponError = code;
    }
    return self;
}

- (id)initWithGaraponTvV3Api:(WZGaraponApiType)apiType status:(NSInteger)status userInfo:(NSDictionary *)dict
{
    if (self = [super initWithDomain:WZGaraponErrorDomain code:status userInfo:dict]) {
        _apiCategory = WZGaraponTvV3ApiCategory;
        _apiType = apiType;
        _garaponError = WZGaraponUnknownError;
        
        switch (apiType) {                
            case WZGaraponAuthLoginApi:
            case WZGaraponAuthLogoutApi:
            {
                switch (status) {
                    case 100:
                        _garaponError = WZGaraponInvalidParameterError;
                        _garaponDescription = @"リクエストパラメータにエラーがありました。";
                        break;
                    case 200:
                        _garaponError = WZGaraponSyncAuthenticationRequiredError;
                        _garaponDescription = @"ガラポン中央サーバとのユーザデータの同期が必要です。";
                        _garaponRecoverySuggestion = @"ガラポンTVをインターネットに接続し時間がたってから再度してください。";
                        break;
                }
                
                NSNumber *result = dict[@"result"];
                if (result) {
                    switch (result.intValue) {
                        case 100:
                        case 200:
                            _garaponDescription = @"IDとパスワードが一致しませんでした。";
                            break;                            
                        default:
                            break;
                    }
                }
            }
                break;
                
            case WZGaraponSearchApi:
            case WZGaraponFavoriteApi:
            case WZGaraponChannelApi:
                switch (status) {
                    case 0:
                        _garaponError = WZGaraponSessionFailedError;
                        _garaponDescription = @"ログインセッションが無効になっています。";
                        _garaponRecoverySuggestion = @"ガラポンTVに再ログインしてください。";
                        break;
                    case 100:
                        _garaponError = WZGaraponInvalidParameterError;
                        _garaponDescription = @"リクエストパラメータにエラーがありました。";
                        break;
                    case 150:
                        _garaponError = WZGaraponVideoFileNotFoundError;
                        _garaponDescription = @"録画ファイルがみつかりませんでした。";
                        break;
                    case 200:
                        _garaponError = WZGaraponDatabaseConnectionFailedError;
                        _garaponDescription = @"データベース接続にエラーがありました。";
                        break;                        
                }
                
                break;
                
            default:
                break;
        }
        
    }
    return self;
}


- (NSInteger)code
{
    return _garaponError;
}

- (NSString *)localizedDescription
{    
    NSString *description = self.userInfo[@"description"];
    if (description) {
        return description;
    }
    if (_garaponDescription) {
        return _garaponDescription;
    }
    return [super localizedDescription];
}

- (NSString *)localizedRecoverySuggestion
{
    if (_garaponRecoverySuggestion) {
        return _garaponRecoverySuggestion;
    }
    return [super localizedRecoverySuggestion];
}

@end
