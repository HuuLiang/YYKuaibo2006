//
//  YYKVIPActivationCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPActivationCell.h"

@interface YYKVIPActivationCell ()
{
    UILabel *_payPointTypeLabel;
    UILabel *_orderIDLabel;
    UILabel *_priceLabel;
    UILabel *_dateLabel;
}
@end

@implementation YYKVIPActivationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _payPointTypeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_payPointTypeLabel];
        {
            [_payPointTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(5);
                make.left.equalTo(self.contentView).offset(5);
                make.right.equalTo(self.contentView).offset(-5);
            }];
        }
        
        _orderIDLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_orderIDLabel];
        {
            [_orderIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_payPointTypeLabel.mas_bottom).offset(5);
                make.left.right.equalTo(_payPointTypeLabel);
            }];
        }
        
        _priceLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_priceLabel];
        {
            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_orderIDLabel.mas_bottom).offset(5);
                make.left.right.equalTo(_orderIDLabel);
            }];
        }
        
        _dateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_dateLabel];
        {
            [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_priceLabel.mas_bottom).offset(5);
                make.left.right.equalTo(_priceLabel);
            }];
        }
    }
    return self;
}

- (void)setPaymentInfo:(YYKPaymentInfo *)paymentInfo {
    _paymentInfo = paymentInfo;
    
    _payPointTypeLabel.text = [NSString stringWithFormat:@"支付类型：%@", paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP ? @"黑钻VIP":@"VIP"];
    _orderIDLabel.text = [NSString stringWithFormat:@"订单号：%@", paymentInfo.orderId];
    _priceLabel.text = [NSString stringWithFormat:@"金额：%.2f元", paymentInfo.orderPrice.unsignedIntegerValue / 100.];
    
    if (!paymentInfo.paymentTime) {
        _dateLabel.text = @"下单时间：未知";
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:kDefaultDateFormat];
        
        NSDate *paymentDate = [formatter dateFromString:paymentInfo.paymentTime];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString *dateString = [formatter stringFromDate:paymentDate];
        _dateLabel.text = [NSString stringWithFormat:@"下单时间：%@", dateString ?: @"未知"];
    }
}
@end
