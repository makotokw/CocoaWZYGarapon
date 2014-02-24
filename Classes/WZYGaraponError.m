//
//  WZYGaraponError.m
//  Garapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYGaraponError.h"

@implementation WZYGaraponError

{
    WZYGaraponApiCategory _apiCategory;
    WZYGaraponApiType _apiType;
    NSInteger _garaponError;
    NSInteger _garaponStatus;
    NSString *_garaponDescription;
    NSString *_garaponRecoverySuggestion;
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    if (self = [super initWithDomain:WZYGaraponErrorDomain code:code userInfo:dict]) {
        _apiCategory = WZYGaraponUnknownApiCategory;
        _apiType = WZYGaraponUnknownApi;
        _garaponError = code;
    }
    return self;
}

- (id)initWithGaraponTvV3Api:(WZYGaraponApiType)apiType status:(NSInteger)status userInfo:(NSDictionary *)dict
{
    if (self = [super initWithDomain:WZYGaraponErrorDomain code:status userInfo:dict]) {
        _apiCategory = WZYGaraponTvV3ApiCategory;
        _apiType = apiType;
        _garaponError = WZYGaraponUnknownError;
        
        switch (apiType) {                
            case WZYGaraponAuthLoginApi:
            case WZYGaraponAuthLogoutApi:
            {
                switch (status) {
                    case 100:
                        _garaponError = WZYGaraponInvalidParameterError;
                        _garaponDescription = @"リクエストパラメータにエラーがありました。";
                        break;
                    case 200:
                        _garaponError = WZYGaraponSyncAuthenticationRequiredError;
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
                
            case WZYGaraponSearchApi:
            case WZYGaraponFavoriteApi:
            case WZYGaraponChannelApi:
                switch (status) {
                    case 0:
                        _garaponError = WZYGaraponSessionFailedError;
                        _garaponDescription = @"ログインセッションが無効になっています。";
                        _garaponRecoverySuggestion = @"ガラポンTVに再ログインしてください。";
                        break;
                    case 100:
                        _garaponError = WZYGaraponInvalidParameterError;
                        _garaponDescription = @"リクエストパラメータにエラーがありました。";
                        break;
                    case 150:
                        _garaponError = WZYGaraponVideoFileNotFoundError;
                        _garaponDescription = @"録画ファイルがみつかりませんでした。";
                        break;
                    case 200:
                        _garaponError = WZYGaraponDatabaseConnectionFailedError;
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

- (void)setGaraponWebErrorStatus:(NSString *)status
{
    _garaponDescription = NSLocalizedStringFromTable(status, @"WZYGaraponWebAuth", nil);
    if ([status isEqualToString:@"no response"]) {        
        _garaponRecoverySuggestion = NSLocalizedStringFromTable(@"recovery for no response", @"WZYGaraponWebAuth", nil);
    }
}

@end
