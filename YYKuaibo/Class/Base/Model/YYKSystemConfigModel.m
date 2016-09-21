//
//  YYKSystemConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "YYKSystemConfigModel.h"

static NSString *const kSystemConfigModelVipKeyPrice = @"yykuaibov_systemconfigModel_vip_keyprice";
static NSString *const kSystemConfigModelSVipKeyPrice = @"yykuaibov_systemconfigModel_svip_keyprice";
static NSString *const kSystemConfigModelALLVipKeyPrice = @"yykuaibov_systemconfigModel_allvip_keyprice";

@implementation YYKSystemConfigResponse

- (Class)confisElementClass {
    return [YYKSystemConfig class];
}

@end

@implementation YYKSystemConfigModel

+ (instancetype)sharedModel {
    static YYKSystemConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[YYKSystemConfigModel alloc] init];
    });
    return _sharedModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _discountAmount = -1;
        _discountLaunchSeq = -1;
        _notificationLaunchSeq = -1;
        _notificationBackgroundDelay = -1;
    }
    return self;
}

+ (Class)responseClass {
    return [YYKSystemConfigResponse class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)fetchSystemConfigWithCompletionHandler:(YYKFetchSystemConfigCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:YYK_SYSTEM_CONFIG_URL
                         standbyURLPath:YYK_STANDBY_SYSTEM_CONFIG_URL
                             withParams:@{@"type":@([YYKUtil deviceType])}
                        responseHandler:^(QBURLResponseStatus respStatus, NSString *errorMessage)
                    {
                        @strongify(self);
                        
                        if (respStatus == QBURLResponseSuccess) {
                            YYKSystemConfigResponse *resp = self.response;
                            
                            [resp.confis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                YYKSystemConfig *config = obj;
                                
                                if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PAY_AMOUNT]) {
                                    self.payAmount = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SVIP_PAY_AMOUNT]) {
                                    self.svipPayAmount = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_ALLVIP_PAY_AMOUNT]) {
                                    self.allVIPPayAmount = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PAY_IMG]) {
                                    self.paymentImage = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SVIP_PAY_IMG]) {
                                    self.svipPaymentImage = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_ORIGINAL_PAY_AMOUNT]) {
                                    self.originalPayAmount = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_ORIGINAL_SVIP_PAY_AMOUNT]) {
                                    self.originalSVIPPayAmount = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_DISCOUNT_IMG]) {
                                    self.discountImage = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PAYMENT_TOP_IMAGE]) {
                                    self.channelTopImage = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_STARTUP_INSTALL]) {
                                    self.startupInstall = config.value;
                                    self.startupPrompt = config.memo;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_TOP_IMAGE]) {
                                    self.spreadTopImage = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_URL]) {
                                    self.spreadURL = config.value;
                                    //                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_LEFT_IMAGE]) {
                                    //                    self.spreadLeftImage = config.value;
                                    //                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_LEFT_URL]) {
                                    //                    self.spreadLeftUrl = config.value;
                                    //                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_RIGHT_IMAGE]) {
                                    //                    self.spreadRightImage = config.value;
                                    //                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SPREAD_RIGHT_URL]) {
                                    //                    self.spreadRightUrl = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_CONTACT_NAME]){
                                    self.contactName = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_CONTACT_SCHEME]) {
                                    self.contactScheme = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_CONTACT_TIME]) {
                                    self.contactTime = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_DISCOUNT_AMOUNT]) {
                                    self.discountAmount = config.value.floatValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_DISCOUNT_LAUNCH_SEQ]) {
                                    self.discountLaunchSeq = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_NOTIFICATION_LAUNCH_SEQ]) {
                                    self.notificationLaunchSeq = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_NOTIFICATION_BACKGROUND_DELAY]) {
                                    self.notificationBackgroundDelay = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_NOTIFICATION_TEXT]) {
                                    self.notificationText = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_NOTIFICATION_REPEAT_TIMES]) {
                                    self.notificationRepeatTimes = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PRICE_MIN]){
                                    self.priceMin = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PRICE_MAX]){
                                    self.priceMax = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_PRICE_EXCLUDE]){
                                    self.priceExclude = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SVIPPRICE_MIN]){
                                    self.svipPriceMin = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SVIPPRICE_MAX]){
                                    self.svipPriceMax = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_SVIPPRICE_EXCLUDE]){
                                    self.svipPriceExclude = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_ALLVIP_PRICE_MIN]) {
                                    self.allVIPPriceMin = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_ALLVIP_PRICE_MAX]) {
                                    self.allVIPPriceMax = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_ALLVIP_EXCLUDE]) {
                                    self.allVIPPriceExclude = config.value;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_STATS_TIME_INTERVAL]) {
                                    self.statsTimeInterval = config.value.integerValue;
                                } else if ([config.name isEqualToString:YYK_SYSTEM_CONFIG_H5_REGION]) {
                                    self.H5Region = config.value;
                                }
                                
                            }];
                            
                            //
                            _loaded = YES;
                            [self saveRandomPayAmount];
                        }
                        
                        if (handler) {
                            handler(respStatus==QBURLResponseSuccess);
                        }
                    }];
    return success;
}
//本地生成的价格
- (void)saveRandomPayAmount {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *vipPayAmount = [defaults objectForKey:kSystemConfigModelVipKeyPrice];
    NSString *SVipPayAmount = [defaults objectForKey:kSystemConfigModelSVipKeyPrice];
    NSString *allVipPayAmount = [defaults objectForKey:kSystemConfigModelALLVipKeyPrice];
    //VIP价格
    if (!vipPayAmount) {
        NSString *vipPrice = [self PayAmountWithPriceMin:_priceMin priceMax:_priceMax priceExclude:_priceExclude];
        if (vipPrice) {
            [defaults setObject:vipPrice forKey:kSystemConfigModelVipKeyPrice];
        }
    }
    //SVIP价格
    if (!SVipPayAmount) {
        NSString *SVipPrice = [self PayAmountWithPriceMin:_svipPriceMin priceMax:_svipPriceMax priceExclude:_svipPriceExclude];
        if (SVipPrice) {
            [defaults setObject:SVipPrice forKey:kSystemConfigModelSVipKeyPrice];
        }
    }
    
    if (!allVipPayAmount) {
        NSString *allVipPrice = [self PayAmountWithPriceMin:_allVIPPriceMin priceMax:_allVIPPriceMax priceExclude:_allVIPPriceExclude];
        if (allVipPrice) {
            [defaults setObject:allVipPrice forKey:kSystemConfigModelALLVipKeyPrice];
        }
    }
    [defaults synchronize];
}
//生成随机价格
- (NSString *)PayAmountWithPriceMin:(NSString *)priceMin priceMax:(NSString *)priceMax priceExclude:(NSString *)priceExclude {
    
    NSInteger min = [priceMin integerValue];
    NSInteger max = [priceMax integerValue];
    if (min > max) {
        return nil;
    }
    //把排除的价格添加到数组中
    NSArray *priceExcludeArr = [priceExclude componentsSeparatedByString:@","];
    //过滤掉重复数据
    NSSet *priceExcludeSet = [NSSet setWithArray:priceExcludeArr];
    priceExcludeArr = [priceExcludeSet allObjects];
    
    for (NSInteger i = min/100;i <= max/100 ; i ++) {
        
        NSString *str = [NSString stringWithFormat:@"%ld",i*100];
        
        if (![priceExcludeArr containsObject:str] ) {
            NSInteger price = 0;
            NSString *priceStr = nil;
            
            do {
                
                price = min/100 + arc4random()%(max/100 - min/100 +1);
                
                priceStr = [NSString stringWithFormat:@"%ld",price*100];
                
            }while ([priceExcludeSet containsObject:priceStr] == YES);
            
            return priceStr;
        }
    }
    return nil;
}

- (NSUInteger)payAmount {
    NSString *payAmount = [[NSUserDefaults standardUserDefaults] objectForKey:kSystemConfigModelVipKeyPrice];
    
    NSUInteger payA = _payAmount;
    
    if (payAmount.integerValue > 0) {
        payA = payAmount.integerValue;
    }
    
    if ([self hasDiscount]) {
        payA = payA * self.discountAmount;
    }
    return payA;
}

- (NSUInteger)svipPayAmount {
    NSString *SvippayAmount = [[NSUserDefaults standardUserDefaults] objectForKey:kSystemConfigModelSVipKeyPrice];
    
    if (SvippayAmount.integerValue > 0) {
        return SvippayAmount.integerValue;
    } else {
        return _svipPayAmount;
    }
}

- (NSUInteger)allVIPPayAmount {
    NSString *allVipPayAmount = [[NSUserDefaults standardUserDefaults] objectForKey:kSystemConfigModelALLVipKeyPrice];
    
    if (allVipPayAmount.integerValue > 0) {
        return allVipPayAmount.integerValue;
    } else {
        return _allVIPPayAmount;
    }
}

- (BOOL)hasDiscount {
    if (self.discountAmount > 0 && self.discountAmount <= 1 && self.discountLaunchSeq >= 0 && [YYKUtil launchSeq] >= self.discountLaunchSeq) {
        return YES;
    }
    return NO;
}

- (NSUInteger)paymentPriceWithProgram:(YYKProgram *)program {
    return [self paymentPriceWithPayPointType:program.payPointType.unsignedIntegerValue];
}

- (NSUInteger)paymentPriceWithPayPointType:(QBPayPointType)payPointType {
    if (payPointType == QBPayPointTypeSVIP && /*[YYKUtil isVIP] &&*/ ![YYKUtil isSVIP]) {
        
        if ([YYKUtil isVIP]) {
            return self.svipPayAmount;
        } else {
            return self.allVIPPayAmount;
        }
    } else {
        return self.payAmount;
    }
}

- (NSString *)paymentImageWithProgram:(YYKProgram *)program {
    return [self paymentImageWithPayPointType:program.payPointType.unsignedIntegerValue];
}

- (NSString *)paymentImageWithPayPointType:(QBPayPointType)payPointType {
    if (payPointType == QBPayPointTypeSVIP && /*[YYKUtil isVIP] &&*/ ![YYKUtil isSVIP]) {
        return self.svipPaymentImage;
    } else if ([self hasDiscount]) {
        return self.discountImage;
    } else {
        return self.paymentImage;
    }
}
@end
