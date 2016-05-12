//
//  YYKPaymentViewController.m
//  kuaibov
//
//  Created by Sean Yue on 15/12/9.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "YYKPaymentViewController.h"
#import "YYKPaymentPopView.h"
#import "YYKSystemConfigModel.h"
#import "YYKPaymentModel.h"
#import <objc/runtime.h>
#import "YYKProgram.h"
#import "YYKPaymentInfo.h"
#import "YYKPaymentConfig.h"

@interface YYKPaymentViewController ()
@property (nonatomic,retain) YYKPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,retain) YYKProgram *programToPayFor;
@property (nonatomic,retain) YYKPaymentInfo *paymentInfo;

@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@property (nonatomic,copy) dispatch_block_t completionHandler;
@property (nonatomic) NSUInteger closeSeq;
@end

@implementation YYKPaymentViewController
@synthesize paymentTypeMap = _paymentTypeMap;

+ (instancetype)sharedPaymentVC {
    static YYKPaymentViewController *_sharedPaymentVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPaymentVC = [[YYKPaymentViewController alloc] init];
    });
    return _sharedPaymentVC;
}

- (YYKPaymentPopView *)popView {
    if (_popView) {
        return _popView;
    }
    
    @weakify(self);
    void (^Pay)(YYKPaymentType type, YYKPaymentType subType) = ^(YYKPaymentType type, YYKPaymentType subType)
    {
        @strongify(self);
        if (!self.payAmount) {
            [[YYKHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
            return ;
        }
        
        [self payForProgram:self.programToPayFor
                      price:self.payAmount.unsignedIntegerValue
                paymentType:type
             paymentSubType:subType];
        
        [self hidePayment];
    };
    
    _popView = [[YYKPaymentPopView alloc] init];
    _popView.backgroundColor = [UIColor colorWithHexString:@"#121212"];
//    _popView.headerImageURL = [NSURL URLWithString:[YYKSystemConfigModel sharedModel].hasDiscount ? [YYKSystemConfigModel sharedModel].discountImage : [YYKSystemConfigModel sharedModel].paymentImage];
    _popView.footerImage = [UIImage imageNamed:@"payment_footer"];
    
    if ([YYKPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & YYKSubPayTypeAlipay) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
            Pay(YYKPaymentTypeVIAPay, YYKPaymentTypeAlipay);
        }];
    }
    
    if ([YYKPaymentConfig sharedConfig].syskPayInfo.supportPayTypes.integerValue & YYKSubPayTypeWeChat) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
            Pay(YYKPaymentTypeVIAPay, YYKPaymentTypeWeChatPay);
        }];
    } else if ([YYKPaymentConfig sharedConfig].wftPayInfo) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
            Pay(YYKPaymentTypeSPay, YYKPaymentTypeWeChatPay);
        }];
    }
    
//    if (([YYKPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & YYKIAppPayTypeWeChat)
//        || [YYKPaymentConfig sharedConfig].weixinInfo) {
//        BOOL useBuildInWeChatPay = [YYKPaymentConfig sharedConfig].weixinInfo != nil;
//        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信客户端支付" available:YES action:^(id sender) {
//            Pay(useBuildInWeChatPay?YYKPaymentTypeWeChatPay:YYKPaymentTypeIAppPay, useBuildInWeChatPay?YYKPaymentTypeNone:YYKPaymentTypeWeChatPay);
//        }];
//    }
//    
//    if (([YYKPaymentConfig sharedConfig].iappPayInfo.supportPayTypes.unsignedIntegerValue & YYKIAppPayTypeAlipay)
//        || [YYKPaymentConfig sharedConfig].alipayInfo) {
//        BOOL useBuildInAlipay = [YYKPaymentConfig sharedConfig].alipayInfo != nil;
//        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝支付" available:YES action:^(id sender) {
//            Pay(useBuildInAlipay?YYKPaymentTypeAlipay:YYKPaymentTypeIAppPay, useBuildInAlipay?YYKPaymentTypeNone:YYKPaymentTypeAlipay);
//        }];
//    }
//    
    _popView.closeAction = ^(id sender){
        @strongify(self);
        [self hidePayment];
    };
    return _popView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.popView];
    {
        [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            
            const CGFloat width = kScreenWidth * 0.95;
            make.size.mas_equalTo(CGSizeMake(width, [self.popView viewHeightRelativeToWidth:width]));
        }];
    }
}

- (void)popupPaymentInView:(UIView *)view forProgram:(YYKProgram *)program withCompletionHandler:(void (^)(void))completionHandler; {
    self.completionHandler = completionHandler;
    
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.payAmount = nil;
    self.programToPayFor = program;
    self.popView.headerImageURL = [NSURL URLWithString:[[YYKSystemConfigModel sharedModel] paymentImageWithProgram:program]];
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    
    if (view == [UIApplication sharedApplication].keyWindow) {
        [view insertSubview:self.view belowSubview:[YYKHudManager manager].hudView];
    } else {
        [view addSubview:self.view];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1.0;
    }];
    
    [self fetchPayAmount];
}

- (void)fetchPayAmount {
    @weakify(self);
    YYKSystemConfigModel *systemConfigModel = [YYKSystemConfigModel sharedModel];
    if (systemConfigModel.loaded) {
        self.payAmount = @([systemConfigModel paymentPriceWithProgram:self.programToPayFor]);
    } else {
        [systemConfigModel fetchSystemConfigWithCompletionHandler:^(BOOL success) {
            @strongify(self);
            if (success) {
                self.payAmount = @([systemConfigModel paymentPriceWithProgram:self.programToPayFor]);
            }
        }];
    }
}

- (void)setPayAmount:(NSNumber *)payAmount {
//#ifdef DEBUG
//    payAmount = @(0.1);
//#endif
    _payAmount = payAmount;
    self.popView.showPrice = @(payAmount.doubleValue / 100);
}

- (void)hidePayment {
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        
        if (self.completionHandler) {
            self.completionHandler();
            self.completionHandler = nil;
        }
        
        ++self.closeSeq;
        if (self.closeSeq == 2 && [YYKUtil isNoVIP]) {
            [YYKUtil showSpreadBanner];
        }
    }];
}

- (void)payForProgram:(YYKProgram *)program
                price:(NSUInteger)price
          paymentType:(YYKPaymentType)paymentType
       paymentSubType:(YYKPaymentType)paymentSubType
{
    @weakify(self);
    [[YYKPaymentManager sharedManager] startPaymentWithType:paymentType
                                                    subType:paymentSubType
                                                     price:price
                                                forProgram:program
                                         completionHandler:^(PAYRESULT payResult, YYKPaymentInfo *paymentInfo) {
        @strongify(self);
        [self notifyPaymentResult:payResult withPaymentInfo:paymentInfo];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(PAYRESULT)result withPaymentInfo:(YYKPaymentInfo *)paymentInfo {
    if (result == PAYRESULT_SUCCESS) {
        if (paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeVIP && [YYKUtil isVIP]) {
            return ;
        }
        
        if (paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP && [YYKUtil isSVIP]) {
            return ;
        }
    }
    
    NSDateFormatter *dateFormmater = [[NSDateFormatter alloc] init];
    [dateFormmater setDateFormat:@"yyyyMMddHHmmss"];
    
    paymentInfo.paymentResult = @(result);
    paymentInfo.paymentStatus = @(YYKPaymentStatusNotProcessed);
    paymentInfo.paymentTime = [dateFormmater stringFromDate:[NSDate date]];
    [paymentInfo save];
    
    if (result == PAYRESULT_SUCCESS) {
        [self hidePayment];
        [[YYKHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName object:paymentInfo];
        
        [YYKUtil showSpreadBanner];
    } else if (result == PAYRESULT_ABANDON) {
        [[YYKHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[YYKHudManager manager] showHudWithText:@"支付失败"];
    }
    
    [[YYKPaymentModel sharedModel] commitPaymentInfo:paymentInfo];
}

@end
