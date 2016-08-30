//
//  YYKWebPlayerViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/30.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKWebPlayerViewController.h"

@interface YYKWebPlayerViewController ()
{
    UIWebView *_webView;
}
@end

@implementation YYKWebPlayerViewController

- (instancetype)initWithProgram:(YYKProgram *)program {
    self = [super init];
    if (self) {
        _program = program;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.program.title;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor = [UIColor blackColor];
    _webView.mediaPlaybackRequiresUserAction = NO;
    [self.view addSubview:_webView];
    {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    NSMutableString *videoSources = [[NSMutableString alloc] initWithFormat:@"<source src='%@' />", self.program.videoUrl];
    if (self.program.spareUrl.length > 0) {
        [videoSources appendFormat:@"<source src='%@' />", self.program.spareUrl];
    }
    
    NSString *htmlBody = [NSString stringWithFormat:@"<video width='%ld' height='%ld' poster='%@' autoplay='autoplay' controls='controls'>%@</video>", (unsigned long)kScreenWidth-1, (unsigned long)kScreenHeight, self.program.coverImg, videoSources];
    
    NSString *htmlString = [NSString stringWithFormat:@"<!DOCTYPE html><html lang='zh'><head><meta charset='UTF-8'></head><body bgColor='black'>%@</body></html>", htmlBody];
    
    [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath]];
    
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
