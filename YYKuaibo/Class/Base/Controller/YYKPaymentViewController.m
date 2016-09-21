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
#import <objc/runtime.h>

@interface YYKPaymentViewController ()
@property (nonatomic,retain) YYKPaymentPopView *popView;
@property (nonatomic) NSNumber *payAmount;

@property (nonatomic,retain) YYKProgram *programToPayFor;
@property (nonatomic) NSUInteger programLocationToPayFor;
@property (nonatomic,retain) YYKChannel *channelToPayFor;

//@property (nonatomic,retain) YYKPaymentInfo *paymentInfo;

//@property (nonatomic,readonly,retain) NSDictionary *paymentTypeMap;
@property (nonatomic,copy) dispatch_block_t completionHandler;
@property (nonatomic) NSUInteger closeSeq;
@end

@implementation YYKPaymentViewController

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
    void (^Pay)(QBPayType type, QBPaySubType subType) = ^(QBPayType type, QBPaySubType subType)
    {
        @strongify(self);
        [self payForPaymentType:type paymentSubType:subType];
        [self hidePayment];
    };
    
    _popView = [[YYKPaymentPopView alloc] init];
//    _popView.headerImageURL = [NSURL URLWithString:[YYKSystemConfigModel sharedModel].hasDiscount ? [YYKSystemConfigModel sharedModel].discountImage : [YYKSystemConfigModel sharedModel].paymentImage];
//    _popView.titleImage = [UIImage imageNamed:@"payment_title"];
    
    QBPayType wechatPaymentType = [[QBPaymentManager sharedManager] wechatPaymentType];
    if (wechatPaymentType != QBPayTypeNone) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"wechat_icon"] title:@"微信支付" backgroundColor:[UIColor colorWithHexString:@"#05c30b"] action:^(id sender) {
            Pay(wechatPaymentType, QBPaySubTypeWeChat);
        }];
    }
    
    QBPayType alipayPaymentType = [[QBPaymentManager sharedManager] alipayPaymentType];
    if (alipayPaymentType != QBPayTypeNone) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"alipay_icon"] title:@"支付宝" backgroundColor:[UIColor colorWithHexString:@"#02a0e9"] action:^(id sender) {
            Pay(alipayPaymentType, QBPaySubTypeAlipay);
        }];
    }
    
    QBPayType qqPaymentType = [[QBPaymentManager sharedManager] qqPaymentType];
    if (qqPaymentType != QBPayTypeNone) {
        [_popView addPaymentWithImage:[UIImage imageNamed:@"qq_icon"] title:@"QQ钱包" backgroundColor:[UIColor redColor] action:^(id sender) {
            Pay(alipayPaymentType, QBPaySubTypeQQ);
        }];
    }
    
//    QBPayType cardPayPaymentType = [[YYKPaymentManager sharedManager] cardPayPaymentType];
//    if (cardPayPaymentType != YYKPaymentTypeNone) {
//        [_popView addPaymentWithImage:[UIImage imageNamed:@"card_pay_icon"] title:@"购卡支付" subtitle:@"支持微信和支付宝" backgroundColor:[UIColor darkPink] action:^(id sender) {
//            Pay(cardPayPaymentType, YYKSubPayTypeNone);
//        }];
//    }
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
        
        
        [[YYKStatsManager sharedManager] statsPayWithOrderNo:nil
                                                   payAction:YYKStatsPayActionClose
                                                   payResult:QBPayResultUnknown
                                                  forProgram:self.programToPayFor
                                             programLocation:self.programLocationToPayFor
                                                   inChannel:self.channelToPayFor
                                                 andTabIndex:[YYKUtil currentTabPageIndex]
                                                 subTabIndex:[YYKUtil currentSubTabPageIndex]];
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

            make.centerX.equalTo(self.view);
            const CGFloat width = MAX(kScreenWidth * 0.75, 275);
            const CGFloat height = [self.popView viewHeightRelativeToWidth:width];
            make.size.mas_equalTo(CGSizeMake(width, height));
            make.centerY.equalTo(self.view).offset(-height/20);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_popView reloadData];
}

- (void)popupPaymentInView:(UIView *)view
                forProgram:(YYKProgram *)program
           programLocation:(NSUInteger)programLocation
                 inChannel:(YYKChannel *)channel
     withCompletionHandler:(void (^)(void))completionHandler
              footerAction:(YYKAction)footerAction
{
    self.completionHandler = completionHandler;
    
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
    
    self.payAmount = nil;
    self.programToPayFor = program;
    self.programLocationToPayFor = programLocation;
    self.channelToPayFor = channel;
    self.popView.payPointType = program.payPointType.unsignedIntegerValue;
    self.popView.headerImageURL = [NSURL URLWithString:[YYKSystemConfigModel sharedModel].paymentImage];
    @weakify(self);
    self.popView.footerAction = ^(id obj) {
        @strongify(self);
        SafelyCallBlock(footerAction, self);
    };
    //self.popView.headerImageURL = [NSURL URLWithString:[[YYKSystemConfigModel sharedModel] paymentImageWithProgram:program]];
    self.view.frame = view.bounds;
    self.view.alpha = 0;
    
    UIView *hudView = [YYKHudManager manager].hudView;
    if (view == [UIApplication sharedApplication].keyWindow) {
        [view insertSubview:self.view belowSubview:hudView];
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
    //self.popView.showPrice = @(payAmount.doubleValue / 100);
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
        
        self.programToPayFor = nil;
        self.programLocationToPayFor = 0;
        self.channelToPayFor = nil;
        
        ++self.closeSeq;
        if (self.closeSeq == 2 && [YYKUtil isNoVIP]) {
            [YYKUtil showSpreadBanner];
        }
    }];
}

- (void)payForPaymentType:(QBPayType)paymentType
           paymentSubType:(QBPaySubType)paymentSubType {
    @weakify(self);
    QBPayPointType payPointType = self.popView.payPointType == QBPayPointTypeSVIP ? QBPayPointTypeSVIP : QBPayPointTypeVIP;
    NSUInteger price = [[YYKSystemConfigModel sharedModel] paymentPriceWithPayPointType:payPointType];
    if (price == 0) {
        [[YYKHudManager manager] showHudWithText:@"无法获取价格信息,请检查网络配置！"];
        return ;
    }
    
#ifdef DEBUG
    if (paymentType == QBPayTypeIAppPay || paymentType == QBPayTypeHTPay || paymentType == QBPayTypeWeiYingPay) {
        if (payPointType == QBPayPointTypeSVIP) {
            price = 210;
        } else {
            price = 200;
        }
    } else if (paymentType == QBPayTypeMingPay || paymentType == QBPayTypeDXTXPay) {
        if (payPointType == QBPayPointTypeSVIP) {
            price = 110;
        } else {
            price = 100;
        }
    } else if (paymentType == QBPayTypeVIAPay) {
        price = 1000;
    } else {
        price = payPointType == QBPayPointTypeSVIP ? 2 : 1;
    }
    
#endif
    
    QBPaymentInfo *paymentInfo = [[QBPaymentInfo alloc] init];
    
    NSString *channelNo = YYK_CHANNEL_NO;
    channelNo = [channelNo substringFromIndex:channelNo.length-14];
    NSString *uuid = [[NSUUID UUID].UUIDString.md5 substringWithRange:NSMakeRange(8, 16)];
    NSString *orderNo = [NSString stringWithFormat:@"%@_%@", channelNo, uuid];
    
    paymentInfo.orderId = orderNo;
    paymentInfo.orderPrice = price;
    paymentInfo.paymentType = paymentType;
    paymentInfo.paymentSubType = paymentSubType;
    paymentInfo.payPointType = payPointType;
    paymentInfo.paymentTime = [YYKUtil currentTimeString];
    paymentInfo.paymentResult = QBPayResultUnknown;
    paymentInfo.paymentStatus = QBPayStatusPaying;
    paymentInfo.reservedData = [YYKUtil paymentReservedData];
    
    NSString *tradeName = self.programToPayFor.payPointType.unsignedIntegerValue == QBPayPointTypeSVIP ? [kSVIPText stringByAppendingString:@"会员"] : @"VIP会员";
    NSString *contactName = [YYKSystemConfigModel sharedModel].contactName;
    if (paymentType == QBPayTypeMingPay) {
        paymentInfo.orderDescription = contactName ?: @"VIP";
    } else {
        paymentInfo.orderDescription = contactName.length > 0 ? [tradeName stringByAppendingFormat:@"(%@)", contactName] : tradeName;
    }
    
    paymentInfo.contentId = self.programToPayFor.programId;
    paymentInfo.contentType = self.programToPayFor.type;
    paymentInfo.contentLocation = @(self.programLocationToPayFor+1);
    paymentInfo.columnId = self.channelToPayFor.realColumnId;
    paymentInfo.columnType = self.channelToPayFor.type;
    paymentInfo.userId = [YYKUtil userId];
    
    BOOL success = [[QBPaymentManager sharedManager] startPaymentWithPaymentInfo:paymentInfo
                                                                              completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo)
    {
        @strongify(self);
        [self notifyPaymentResult:payResult withPaymentInfo:paymentInfo];
    }];
    
    if (success) {
        [[YYKStatsManager sharedManager] statsPayWithPaymentInfo:paymentInfo
                                                    forPayAction:YYKStatsPayActionGoToPay
                                                     andTabIndex:[YYKUtil currentTabPageIndex]
                                                     subTabIndex:[YYKUtil currentSubTabPageIndex]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notifyPaymentResult:(QBPayResult)result withPaymentInfo:(YYKPaymentInfo *)paymentInfo {
//    if (result == QBPayResultSuccess) {
//        if (paymentInfo.payPointType == QBPayPointTypeVIP && [YYKUtil isVIP]) {
//            return ;
//        }
//        
//        if (paymentInfo.payPointType == QBPayPointTypeSVIP && [YYKUtil isSVIP]) {
//            return ;
//        }
//    }
    
    if (result == QBPayResultSuccess) {
        [self hidePayment];
        [[YYKHudManager manager] showHudWithText:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPaidNotificationName object:paymentInfo];
        
        [self.popView reloadData];
        [YYKUtil showSpreadBanner];
    } else if (result == QBPayResultCancelled) {
        [[YYKHudManager manager] showHudWithText:@"支付取消"];
    } else {
        [[YYKHudManager manager] showHudWithText:@"支付失败"];
    }
    
    [[YYKStatsManager sharedManager] statsPayWithPaymentInfo:paymentInfo
                                                forPayAction:YYKStatsPayActionPayBack
                                                 andTabIndex:[YYKUtil currentTabPageIndex]
                                                 subTabIndex:[YYKUtil currentSubTabPageIndex]];
}

@end
