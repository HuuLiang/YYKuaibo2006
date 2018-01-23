//
//  YYKWebViewController.m
//  YuePaoBa
//
//  Created by Sean Yue on 16/1/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKWebViewController.h"

@interface YYKWebViewController ()
{
    UIWebView *_webView;
}
@end

@implementation YYKWebViewController

- (instancetype)initWithURL:(NSURL *)url standbyURL:(NSURL *)standbyUrl {
    self = [self init];
    if (self) {
        _url = url;
        _standbyUrl = standbyUrl;
    }
    return self;
}

- (instancetype)initWithHTML:(NSString *)htmlString {
    self = [super init];
    if (self) {
        _htmlString = htmlString;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] init];
    _webView.mediaPlaybackRequiresUserAction = NO;
    [self.view addSubview:_webView];
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    if (_htmlString.length > 0) {
        [_webView loadHTMLString:_htmlString baseURL:nil];
    } else {
        NSURLRequest *urlReq = [NSURLRequest requestWithURL:_url];
        NSURLRequest *standUrlReq = [NSURLRequest requestWithURL:_standbyUrl];
        
        if (_standbyUrl) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSHTTPURLResponse *response;
                NSError *error;
                [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
                NSInteger responseCode = response.statusCode;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (responseCode == 502 || responseCode == 404) {
                        [_webView loadRequest:standUrlReq];
                    } else {
                        [_webView loadRequest:urlReq];
                    }
                });
            });
        } else {
            [_webView loadRequest:urlReq];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
