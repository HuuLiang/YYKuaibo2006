//
//  YYKVIPActivationViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/6/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPActivationViewController.h"
#import "YYKVIPActivationCell.h"
#import "YYKPaymentViewController.h"
#import "YYKOrderQueryModel.h"

static NSString *const kVIPActivationCellReusableIdentifier = @"VIPActivationCellReusableIdentifier";

@interface YYKVIPActivationViewController () <UITableViewSeparatorDelegate,UITableViewDataSource>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,retain) NSArray<YYKPaymentInfo *> *paymentInfos;
@property (nonatomic,retain) YYKOrderQueryModel *orderQueryModel;
@end

@implementation YYKVIPActivationViewController

DefineLazyPropertyInitialization(YYKOrderQueryModel, orderQueryModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择您已经付费成功的订单";
    
    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.backgroundColor = self.view.backgroundColor;
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.rowHeight = 110;
    [_layoutTableView registerClass:[YYKVIPActivationCell class] forCellReuseIdentifier:kVIPActivationCellReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    if ([YYKUtil isVIP]) {
        self.paymentInfos = [[YYKUtil allUnsuccessfulPaymentInfos] bk_select:^BOOL(YYKPaymentInfo *paymentInfo) {
            return paymentInfo.payPointType.unsignedIntegerValue == YYKPayPointTypeSVIP;
        }];
    } else {
        self.paymentInfos = [YYKUtil allUnsuccessfulPaymentInfos];
    }
    
    self.paymentInfos = [self.paymentInfos sortedArrayUsingComparator:^NSComparisonResult(YYKPaymentInfo *obj1, YYKPaymentInfo *obj2) {
        return - [obj1.paymentTime compare:obj2.paymentTime];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.paymentInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYKVIPActivationCell *cell = [tableView dequeueReusableCellWithIdentifier:kVIPActivationCellReusableIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.section < self.paymentInfos.count) {
        YYKPaymentInfo *paymentInfo = self.paymentInfos[indexPath.section];
        cell.paymentInfo = paymentInfo;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section < self.paymentInfos.count) {
        YYKPaymentInfo *paymentInfo = self.paymentInfos[indexPath.section];
        
        @weakify(self);
        [self.view beginLoading];
        [self.orderQueryModel queryOrder:paymentInfo.orderId withCompletionHandler:^(BOOL success, id obj) {
            @strongify(self);
            if (!self) {
                return ;
            }
            
            [self.view endLoading];
            if (success) {
                [[YYKPaymentViewController sharedPaymentVC] notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:paymentInfo];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [[YYKHudManager manager] showHudWithText:obj];
            }
        }];
        
    }
    
}
@end
