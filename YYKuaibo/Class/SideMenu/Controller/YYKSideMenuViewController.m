//
//  YYKSideMenuViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKSideMenuViewController.h"
#import "YYKSideMenuVIPCell.h"
#import "YYKHistoryViewController.h"
#import "YYKWebViewController.h"
#import "YYKInputTextViewController.h"
#import "YYKRecommendViewController.h"
#import "YYKSystemConfigModel.h"

static NSString *const kSideMenuNormalCellReusableIdentifier = @"SideMenuNormalCellReusableIdentifier";
static NSString *const kSideMenuVIPCellReusableIdentifier = @"SideMenuVIPCellReusableIdentifier";

typedef NS_ENUM(NSUInteger, YYKSideMenuSection) {
    YYKSideMenuSectionVIP,
    YYKSideMenuSectionRecommended,
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

@interface YYKSideMenuViewController () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableView *_layoutTableView;
}
@end

@implementation YYKSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.backgroundColor = self.view.backgroundColor;
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.hasRowSeparator = YES;
    _layoutTableView.hasSectionBorder = YES;
//    [_layoutTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSideMenuNormalCellReusableIdentifier];
    [_layoutTableView registerClass:[YYKSideMenuVIPCell class] forCellReuseIdentifier:kSideMenuVIPCellReusableIdentifier];
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
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)onPaidNotification {
    [_layoutTableView reloadData];
}

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    if ([YYKUtil isPaid]) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [YYKUtil isPaid] ? YYKSideMenuSectionCount : YYKSideMenuSectionCount - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == YYKSideMenuSectionVIP) {
        YYKSideMenuVIPCell *vipCell = [tableView dequeueReusableCellWithIdentifier:kSideMenuVIPCellReusableIdentifier forIndexPath:indexPath];
        cell = vipCell;
        
        @weakify(self);
        if (!vipCell.backAction) {
            vipCell.backAction = ^(id sender){
                @strongify(self);
                [self.sideMenuViewController hideMenuViewController];
            };
        }
        if (!vipCell.memberAction) {
            vipCell.memberAction = ^(id sender) {
                @strongify(self);
                [self.sideMenuViewController hideMenuViewController];
                [self payForProgram:nil];
            };
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kSideMenuNormalCellReusableIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kSideMenuNormalCellReusableIdentifier];
        }
        cell.accessoryType = [YYKUtil isPaid] && indexPath.section == YYKSideMenuSectionPhone ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        
        if (indexPath.section == YYKSideMenuSectionRecommended) {
            cell.imageView.image = [UIImage imageNamed:@"side_menu_recommended_icon"];
            cell.textLabel.text = @"精品推荐";
        } else if ([YYKUtil isPaid] && indexPath.section == YYKSideMenuSectionPhone) {
            cell.imageView.image = [UIImage imageNamed:@"side_menu_phone_icon"];
            cell.textLabel.text = @"投诉热线";
            cell.detailTextLabel.text = [YYKSystemConfigModel sharedModel].contact;
        } else if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
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
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return YYKSideMenuOtherSectionCellCount;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKSideMenuSectionVIP) {
        return 200;
    } else {
        return MAX(44, lround(kScreenHeight*0.08));
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == YYKSideMenuSectionVIP) {
        return 0;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) {
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
            NSString *urlString = [YYKUtil isPaid]?YYK_AGREEMENT_PAID_URL:YYK_AGREEMENT_NOTPAID_URL;
            urlString = [YYK_BASE_URL stringByAppendingString:urlString];
            YYKWebViewController *webVC = [[YYKWebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
            webVC.title = cell.textLabel.text;
            [self.navigationController pushViewController:webVC animated:YES];
        }
    } else if (indexPath.section == YYKSideMenuSectionRecommended) {
        YYKRecommendViewController *recommendVC = [[YYKRecommendViewController alloc] init];
        recommendVC.title = cell.textLabel.text;
        [self.navigationController pushViewController:recommendVC animated:YES];
    } else if ([YYKUtil isPaid] && indexPath.section == YYKSideMenuSectionPhone) {
        NSString *phoneNum = cell.detailTextLabel.text;
        if (phoneNum.length > 0) {
            [YYKUtil callPhoneNumber:phoneNum];
        }
    }
}
@end
