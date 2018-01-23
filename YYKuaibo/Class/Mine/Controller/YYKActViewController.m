//
//  YYKActViewController.m
//  YYKuaibo
//
//  Created by Liang on 2016/10/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKActViewController.h"
#import "YYKAutoActivateManager.h"

@interface YYKActViewController () <UITextFieldDelegate>
{
    UILabel     * _autoLabel;
    UITextField * _textField;
    UIButton    * _nonAutoBtn;
}
@end

@implementation YYKActViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"我的订单";
    
    [self.navigationController.navigationBar bk_whenTouches:1 tapped:5 handler:^{
        NSString *baseURLString = [YYK_BASE_URL stringByReplacingCharactersInRange:NSMakeRange(0, YYK_BASE_URL.length-6) withString:@"******"];
        [[YYKHudManager manager] showHudWithText:[NSString stringWithFormat:@"Server:%@\nChannelNo:%@\nPackageCertificate:%@\npV:%@/%@", baseURLString, YYK_CHANNEL_NO, YYK_PACKAGE_CERTIFICATE, YYK_REST_PV, YYK_PAYMENT_PV]];
    }];
    
    [self createViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createViews {
    
    _autoLabel = [[UILabel alloc] init];
    _autoLabel.text = @"输入支付订单号自助激活";
    _autoLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    _autoLabel.font = [UIFont systemFontOfSize:kWidth(32)];
    _autoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_autoLabel];
    
    {
        [_autoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(kWidth(150)+64);
            make.height.mas_equalTo(kWidth(44));
        }];
    }
    
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = [UIColor colorWithHexString:@"#DCDCDC"];
    _textField.font = [UIFont systemFontOfSize:kWidth(34)];
    _textField.textColor = [UIColor colorWithHexString:@"#000000"];
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    _textField.placeholder = @"  请输入正确的订单号";
    _textField.layer.borderColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.3].CGColor;
    _textField.layer.borderWidth = 1;
    _textField.layer.masksToBounds = YES;
    [_textField setValue:[UIColor colorWithHexString:@"#999999"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.view addSubview:_textField];
    
    _nonAutoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nonAutoBtn setTitle:@"提交激活" forState:UIControlStateNormal];
    [_nonAutoBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    _nonAutoBtn.backgroundColor = [UIColor colorWithHexString:@"#FF680D"];
    _nonAutoBtn.titleLabel.font = [UIFont systemFontOfSize:kWidth(34)];
    _nonAutoBtn.layer.cornerRadius = kWidth(10);
    _nonAutoBtn.layer.masksToBounds = YES;
    [self.view addSubview:_nonAutoBtn];
    
    @weakify(self);
    [_nonAutoBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        [[YYKAutoActivateManager sharedManager] requestExchangeCode:self->_textField.text];
    } forControlEvents:UIControlEventTouchUpInside];
    
    {
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_autoLabel.mas_bottom).offset(kWidth(30));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(kWidth(560), kWidth(88)));
        }];
        
        [_nonAutoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textField.mas_bottom).offset(kWidth(40));
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(kWidth(542), kWidth(88)));
        }];
    }
}

@end
