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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView = [[UIWebView alloc] init];
    [self.view addSubview:_webView];
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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
