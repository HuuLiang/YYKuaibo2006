//
//  QBPaymentWebViewController.m
//  Pods
//
//  Created by Sean Yue on 2016/10/21.
//
//

#import "QBPaymentWebViewController.h"
#import "MBProgressHUD.h"

@interface QBPaymentWebViewController () <UIAlertViewDelegate>
{
    UIWebView *_webView;
}
@property (nonatomic,retain) NSString *htmlString;
@end

@implementation QBPaymentWebViewController

- (instancetype)initWithHTMLString:(NSString *)htmlString {
    self = [self init];
    if (self) {
        _htmlString = htmlString;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付跳转中。。。";
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.scalesPageToFit = YES;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
    
    [_webView loadHTMLString:self.htmlString baseURL:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[MBProgressHUD HUDForView:self.view] hide:YES];
}

- (void)onClose {
    if (self.closeAction) {
        self.closeAction();
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
