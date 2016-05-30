//
//  YYKInputTextViewController.m
//  YuePaoBa
//
//  Created by Sean Yue on 15/12/24.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "YYKInputTextViewController.h"
#import <UITextView+Placeholder.h>

@interface YYKInputTextViewController () <UITextViewDelegate,UITextFieldDelegate>
{
    UITextView *_inputTextView;
    UILabel *_textLimitLabel;
}
@end

@implementation YYKInputTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _inputTextView = [[UITextView alloc] init];
    _inputTextView.font = [UIFont systemFontOfSize:14.];
    _inputTextView.backgroundColor = [UIColor whiteColor];
    _inputTextView.layer.cornerRadius = 4;
    _inputTextView.layer.borderWidth = 0.5;
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    _inputTextView.delegate = self;
    _inputTextView.placeholder = self.placeholder;
    _inputTextView.text = self.text;
    [self.view addSubview:_inputTextView];
    {
        [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.top.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.height.mas_equalTo(100);
        }];
    }
    
    @weakify(self);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:self.completeButtonTitle ?: @"保存"
                                                                                 style:UIBarButtonItemStylePlain
                                                                               handler:^(id sender)
    {
        @strongify(self);
        [self doSave];
    }];
    [self.navigationItem.rightBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-5, 0) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem.enabled = self.text.length > 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_inputTextView becomeFirstResponder];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _inputTextView.placeholder = placeholder;
}

- (void)setText:(NSString *)text {
    _text = text;
    _inputTextView.text = text;
    self.navigationItem.rightBarButtonItem.enabled = text.length > 0;
}

- (void)setLimitedTextLength:(NSUInteger)limitedTextLength {
    _limitedTextLength = limitedTextLength;
    
    if (limitedTextLength > 0 && !_textLimitLabel) {
        _textLimitLabel = [[UILabel alloc] init];
        _textLimitLabel.text = [NSString stringWithFormat:@"还可以输入%ld个字", limitedTextLength - self.text.length];
        _textLimitLabel.font = [UIFont systemFontOfSize:14.];
        [self.view addSubview:_textLimitLabel];
        {
            [_textLimitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_inputTextView);
                make.top.equalTo(_inputTextView.mas_bottom).offset(10);
            }];
        }
    }
    _textLimitLabel.hidden = limitedTextLength == 0;
}

- (void)setCompleteButtonTitle:(NSString *)completeButtonTitle {
    _completeButtonTitle = completeButtonTitle;
    
}

- (BOOL)doSave {
    [_inputTextView resignFirstResponder];
    
    if (self.completionHandler) {
        if (self.completionHandler(self, self.text)) {
            [self.navigationController popViewControllerAnimated:YES];
            return YES;
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        return YES;
    }
    return NO;
}

- (void)doChangeText {
    _text = _inputTextView.text;
    
    if (self.limitedTextLength > 0) {
        _textLimitLabel.text = [NSString stringWithFormat:@"还可以输入%ld个字", self.limitedTextLength - self.text.length];
    }
    
    if (self.changeHandler) {
        self.navigationItem.rightBarButtonItem.enabled = self.changeHandler(self, self.text);
    } else {
        self.navigationItem.rightBarButtonItem.enabled = _text.length > 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidChange:(UITextView *)textView {
    [self doChangeText];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newTextLength = textView.text.length - range.length + text.length;
    if (self.limitedTextLength > 0 && newTextLength > self.limitedTextLength) {
        return NO;
    }
    return YES;
}
@end
