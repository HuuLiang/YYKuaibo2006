//
//  YYKVersionUpdateViewController.m
//  YYKuaibo
//
//  Created by ylz on 2016/12/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVersionUpdateViewController.h"

@interface YYKVersionUpdateViewController ()

@end

@implementation YYKVersionUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.view beginLoading]
    self.view.backgroundColor = [UIColor colorWithHexString:@"#7ED321"];
    [self addAllUI];
    
}

- (void)addAllUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:kWidth(72.)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"请更新最新版本";
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    {
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(kWidth(120));
    }];
    }
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.font = [UIFont systemFontOfSize:kWidth(32)];
    subTitleLabel.textColor = [UIColor whiteColor];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.text = @"视频内容大幅增加,旧版本关停,请下载更新";
    [self.view addSubview:subTitleLabel];
    {
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(kWidth(60));
    }];
    }
    
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    updateBtn.backgroundColor = [UIColor blackColor];
    [updateBtn setTitle:@"下载最新版" forState:UIControlStateNormal];
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateBtn.titleLabel.font = [UIFont systemFontOfSize:kWidth(48)];
    updateBtn.layer.cornerRadius = 7.;
    updateBtn.clipsToBounds = YES;
    [self.view addSubview:updateBtn];
    {
    [updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view).multipliedBy(0.6);
        make.height.mas_equalTo(kWidth(110.));
    }];
    }
    @weakify(self);
    [updateBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        if (!self.linkUrl) {
            return ;
        }
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.linkUrl]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.linkUrl]];
        }
    } forControlEvents:UIControlEventTouchUpInside];
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
