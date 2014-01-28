//
//  WZGaraponTvSite.m
//  WZGarapon
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZGaraponTvSite.h"

@interface WZGaraponTvSite (WebView) <UIWebViewDelegate>
@end

@implementation WZGaraponTvSite

{
    NSString *_garaponId;
    NSString *_password;
    
    NSString *_socialGtvidViewURLString;
    NSString *_gtvidSelector;
    
    NSString *_loginURLString;
    NSString *_loginSucceededURLString;
    NSString *_loginFormAction;
    NSString *_inputGaraponIdName;
    NSString *_inputPasswordName;
    NSString *_inputSaveName;
    
    NSDate *_authedAt;
    NSCache *_cache;
    
    NSString *_queryingGtvid;
}

- (id)init
{
    self = [super init];
    if (self) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)setGaraponId:(NSString *)garaponId password:(NSString *)password
{
    _garaponId  = garaponId;
    _password = password;
}

- (void)prepareGaraponTvSite:(NSDictionary *)dict
{
    _socialGtvidViewURLString = dict[@"socialGtvidViewUrl"];
    _gtvidSelector = dict[@"gtvidSelector"];
    
    NSDictionary *form = dict[@"loginForm"];
    _loginURLString = form[@"url"];
    _loginSucceededURLString = form[@"succeededUrl"];
    _loginFormAction = form[@"action"];
    _inputGaraponIdName = form[@"idName"];
    _inputPasswordName = form[@"pwName"];
    _inputSaveName = form[@"saveName"];
}

- (void)login
{
    NSLog(@"loginWithGaraponId: %@", _garaponId);
//    NSString *postData = [NSString stringWithFormat:@"gid=%@&hirapasswd=%@", _garaponId, _password];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_loginURLString]];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [_webView loadRequest:request];
}

- (void)queryGtvid:(NSString *)gtvId
{
    NSLog(@"queryGtvid: %@", gtvId);
    
    NSString *replacedGtvId = [_cache objectForKey:gtvId];
    if (replacedGtvId.length > 0) {
        if (_completionHandler) {
            _completionHandler(replacedGtvId, gtvId);
        }
        return;
    }
    
    _queryingGtvid = gtvId;
    
    if (!_authedAt || abs(_authedAt.timeIntervalSinceNow) > 3600) {
        [self login];
        return;
    }

    NSString *URLString = [NSString stringWithFormat:@"%@?gtvid=%@", _socialGtvidViewURLString, gtvId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [_webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest: %@", request.URL);
    if ([request.URL.scheme compare:@"about"] == NSOrderedSame) {
		return NO;
	}
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad: %@", webView.request.URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad: %@", webView.request.URL);
    NSLog(@"webView.isLoading: %d", webView.isLoading);
    if (!webView.isLoading) {
        
        NSString *URLString = webView.request.URL.absoluteString;
        if ([URLString hasPrefix:_socialGtvidViewURLString]) {
            NSString *originalGtvid;
            NSRange range = [URLString rangeOfString:@"gtvid="];
            if (range.location != NSNotFound) {
                originalGtvid = [URLString substringFromIndex:range.location + range.length];
            }
//#if DEBUG
//            NSString *program_table = [webView stringByEvaluatingJavaScriptFromString:@"jQuery('#program_table').html();"];
//            NSLog(@"stringByEvaluatingJavaScriptFromString: %@", program_table);
//#endif
            NSString *script = [NSString stringWithFormat:@"jQuery('%@').attr('gtvid');", _gtvidSelector];
            NSLog(@"stringByEvaluatingJavaScriptFromString: %@", script);
            NSString *gtvid = [webView stringByEvaluatingJavaScriptFromString:script];
            
            if (gtvid.length) {
                [_cache setObject:gtvid forKey:originalGtvid];
            }
            if (_completionHandler) {
                _completionHandler(gtvid, originalGtvid);
            }
            _queryingGtvid = nil;
        } else if ([URLString isEqualToString:_loginURLString]) {
            if (_queryingGtvid) {
                NSString *script = [NSString stringWithFormat:@"jQuery('input[name=\"%@\"]').val('%@');"
                               "jQuery('input[name=\"%@\"]').val('%@');"
                               "jQuery('input[name=\"%@\"]').attr('checked', true);"
                               "jQuery('form[action=\"%@\"]').submit();",
                               _inputGaraponIdName,
                               _garaponId,
                               _inputPasswordName,
                               _password,
                               _inputSaveName,
                               _loginFormAction
                               ];
                [webView stringByEvaluatingJavaScriptFromString:script];
            }
        } else if ([URLString isEqualToString:_loginSucceededURLString]) {
            _authedAt = [NSDate date];
            if (_queryingGtvid) {
                [self queryGtvid:_queryingGtvid];
            }
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError:%@ %@", error.localizedDescription, webView.request.URL);
}

+ (NSString *)gtvidOfURLString:(NSString *)URLString
{
    NSString *gtvid = nil;
    if (URLString.length > 0) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:&|\\?)(?:g=|gtvid=)([\\w]{18})"
                                                                               options:0
                                                                                 error:&error];
        
        NSArray *matches = [regex matchesInString:URLString
                                          options:0
                                            range:NSMakeRange(0, [URLString length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match rangeAtIndex:1];
            gtvid = [URLString substringWithRange:range];
            break;
        }
    }
    return gtvid;
}

@end


@implementation WZGaraponTvSite (WebView)
@end