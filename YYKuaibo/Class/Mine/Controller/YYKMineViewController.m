//
//  YYKMineViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKMineViewController.h"
#import "YYKMineVIPCell.h"
#import "YYKHistoryViewController.h"
#import "YYKWebViewController.h"
#import "YYKInputTextViewController.h"
#import "YYKSystemConfigModel.h"

static NSString *const kSideMenuNormalCellReusableIdentifier = @"SideMenuNormalCellReusableIdentifier";
static NSString *const kSideMenuVIPCellReusableIdentifier = @"SideMenuVIPCellReusableIdentifier";

typedef NS_ENUM(NSUInteger, YYKSideMenuSection) {
    YYKSideMenuSectionVIP,
    YYKSideMenuSectionPhone,
    YYKSideMenuSectionOthers,
    YYKSideMenuSectionCount
};

typedef NS_ENUM(NSUInteger, YYKSideMenuOtherSectionCell) {
    YYKSideMenuOtherSectionCellHistory,
//    YYKSideMenuOtherSectionCellMemberCenter,
    YYKSideMenuOtherSectionCellCacheClean,
    YYKSideMenuOtherSectionCellFeedback,
    YYKSideMenuOtherSectionCellAboutUs,
    YYKSideMenuOtherSectionCellCount
};

@interface YYKMineViewController () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableView *_layoutTableView;
}
@end

@implementation YYKMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = [YYKUtil isAllVIPs];
    
    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.backgroundColor = self.view.backgroundColor;
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.separatorColor = [UIColor grayColor];
    _layoutTableView.hasRowSeparator = YES;
    _layoutTableView.hasSectionBorder = YES;
//    [_layoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSideMenuNormalCellReusableIdentifier];
    [_layoutTableView registerClass:[YYKMineVIPCell class] forCellReuseIdentifier:kSideMenuVIPCellReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaidNotificationName object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![YYKUtil isAllVIPs]) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if ([YYKUtil isAnyVIP]) {
        if ([YYKSystemConfigModel sharedModel].loaded) {
            [_layoutTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:YYKSideMenuSectionPhone]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            @weakify(self);
            [[YYKSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
                @strongify(self);
                if (!self) {
                    return ;
                }
                
                if (success) {
                    [self->_layoutTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:YYKSideMenuSectionPhone]] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }
    }
    
    if ([_layoutTableView numberOfSections] > 0) {
        NSUInteger sections = [self numberOfSectionsInTableView:_layoutTableView];
        [_layoutTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:YYKSideMenuOtherSectionCellCacheClean inSection:sections-1]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)onPaidNotification {
    if ([YYKUtil isAllVIPs]) {
        self.navigationController.navigationBarHidden = NO;
    }
    self.automaticallyAdjustsScrollViewInsets = [YYKUtil isAllVIPs];
    
    [_layoutTableView reloadData];
}

- (YYKSideMenuSection)sectionTypeInSection:(NSUInteger)section {
    if ([YYKUtil isNoVIP]) {
        if (section == 0) {
            return YYKSideMenuSectionVIP;
        } else {
            return YYKSideMenuSectionOthers;
        }
    } else if ([YYKUtil isVIP] && ![YYKUtil isSVIP]) {
        if (section == 0) {
            return YYKSideMenuSectionVIP;
        } else if (section == 1) {
            return YYKSideMenuSectionPhone;
        } else {
            return YYKSideMenuSectionOthers;
        }
    } else {
        if (section == 0) {
            return YYKSideMenuSectionPhone;
        } else {
            return YYKSideMenuSectionOthers;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([YYKUtil isAllVIPs] || [YYKUtil isNoVIP])  {
        return YYKSideMenuSectionCount - 1;
    } else {
        return YYKSideMenuSectionCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([self sectionTypeInSection:indexPath.section] == YYKSideMenuSectionVIP) {
        YYKMineVIPCell *vipCell = [tableView dequeueReusableCellWithIdentifier:kSideMenuVIPCellReusableIdentifier forIndexPath:indexPath];
        vipCell.vipImage = [YYKUtil isVIP] && ![YYKUtil isSVIP] ? [UIImage imageNamed:@"svip_text"] : [UIImage imageNamed:@"vip_text"];
        vipCell.memberTitle = [YYKUtil isVIP] && ![YYKUtil isSVIP] ? @"成为黑钻VIP会员" : @"成为VIP会员";
        cell = vipCell;
        
        @weakify(self);
        if (!vipCell.memberAction) {
            vipCell.memberAction = ^(id sender) {
                @strongify(self);
                if (![YYKUtil isAllVIPs]) {
                    [self payForPayPointType:[YYKUtil isVIP] && ![YYKUtil isSVIP] ? YYKPayPointTypeSVIP : YYKPayPointTypeVIP];
                } else {
                    [[YYKHudManager manager] showHudWithText:@"您已经是会员，感谢您的观看！"];
                }
            };
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kSideMenuNormalCellReusableIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kSideMenuNormalCellReusableIdentifier];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.detailTextLabel.text = nil;
    
        if ([self sectionTypeInSection:indexPath.section] == YYKSideMenuSectionPhone) {
            cell.imageView.image = [UIImage imageNamed:@"side_menu_phone_icon"];
            cell.textLabel.text = @"投诉热线";
            cell.detailTextLabel.text = [YYKSystemConfigModel sharedModel].contactTime;
        } else if ([self sectionTypeInSection:indexPath.section] == YYKSideMenuSectionOthers) {
            if (indexPath.row == YYKSideMenuOtherSectionCellHistory) {
                cell.imageView.image = [UIImage imageNamed:@"side_menu_history_icon"];
                cell.textLabel.text = @"播放记录";
//            } else if (indexPath.row == YYKSideMenuOtherSectionCellMemberCenter) {
//                cell.imageView.image = [UIImage imageNamed:@"side_menu_mine_icon"];
//                cell.textLabel.text = @"会员中心";
            } else if (indexPath.row == YYKSideMenuOtherSectionCellCacheClean) {
                cell.imageView.image = [UIImage imageNamed:@"side_menu_setting_icon"];
                cell.textLabel.text = @"缓存清理";
                cell.detailTextLabel.text = [YYKUtil cachedImageSizeString];
            } else if (indexPath.row == YYKSideMenuOtherSectionCellFeedback) {
                cell.imageView.image = [UIImage imageNamed:@"side_menu_feedback_icon"];
                cell.textLabel.text = @"意见反馈";
            } else if (indexPath.row == YYKSideMenuOtherSectionCellAboutUs) {
                cell.imageView.image = [UIImage imageNamed:@"side_menu_about_icon"];
                cell.textLabel.text = @"关于我们";
            }
            
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self sectionTypeInSection:section] == YYKSideMenuSectionOthers) {
        return YYKSideMenuOtherSectionCellCount;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionTypeInSection:indexPath.section] == YYKSideMenuSectionVIP) {
        return 160;
    } else {
        return MAX(44, lround(kScreenHeight*0.08));
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = self.view.backgroundColor;
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self sectionTypeInSection:indexPath.section] == YYKSideMenuSectionOthers) {
        if (indexPath.row == YYKSideMenuOtherSectionCellHistory) {
            YYKHistoryViewController *historyVC = [[YYKHistoryViewController alloc] init];
            historyVC.title = cell.textLabel.text;
            [self.navigationController pushViewController:historyVC animated:YES];
//        } else if (indexPath.row == YYKSideMenuOtherSectionCellMemberCenter) {
            
        } else if (indexPath.row == YYKSideMenuOtherSectionCellCacheClean) {
            if ([[SDImageCache sharedImageCache] getSize] == 0) {
                [[YYKHudManager manager] showHudWithText:@"没有缓存需要清理"];
                return ;
            }
            
            [UIAlertView bk_showAlertViewWithTitle:@"确认"
                                           message:@"是否确认清理缓存？"
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:@[@"确认"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex)
             {
                 if (buttonIndex == 1) {
                     [[SDImageCache sharedImageCache] clearDisk];
                     [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                 }
            }];
        } else if (indexPath.row == YYKSideMenuOtherSectionCellFeedback) {
            YYKInputTextViewController *inputVC = [[YYKInputTextViewController alloc] init];
            inputVC.completeButtonTitle = @"提交";
            inputVC.title = cell.textLabel.text;
            inputVC.limitedTextLength = 140;
            inputVC.completionHandler = ^BOOL(id sender, NSString *text) {
                [[YYKHudManager manager] showProgressInDuration:1];
                
                UIViewController *thisVC = sender;
                [thisVC bk_performBlock:^(id obj) {
                    [[obj navigationController] popViewControllerAnimated:YES];
                    [[YYKHudManager manager] showHudWithText:@"感谢您的反馈~~~"];
                } afterDelay:1];
                
                return NO;
            };
            [self.navigationController pushViewController:inputVC animated:YES];
        } else if (indexPath.row == YYKSideMenuOtherSectionCellAboutUs) {
            NSString *urlString = [YYKUtil isAnyVIP]?YYK_AGREEMENT_PAID_URL:YYK_AGREEMENT_NOTPAID_URL;
            urlString = [YYK_BASE_URL stringByAppendingString:urlString];
            
            NSString *standbyUrlString = [YYKUtil isAnyVIP]?YYK_STANDBY_AGREEMENT_PAID_URL:YYK_STANDBY_AGREEMENT_NOTPAID_URL;
            standbyUrlString = [YYK_STANDBY_BASE_URL stringByAppendingString:standbyUrlString];
            
            YYKWebViewController *webVC = [[YYKWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                         standbyURL:[NSURL URLWithString:standbyUrlString]];
            webVC.title = cell.textLabel.text;
            [self.navigationController pushViewController:webVC animated:YES];
        }
    } else if ([self sectionTypeInSection:indexPath.section] == YYKSideMenuSectionPhone) {
        NSString *phoneNum = [YYKSystemConfigModel sharedModel].contact;
        if (phoneNum.length > 0) {
            [YYKUtil callPhoneNumber:phoneNum];
        }
    }
}
@end
