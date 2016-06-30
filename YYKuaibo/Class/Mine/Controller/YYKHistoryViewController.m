//
//  YYKHistoryViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHistoryViewController.h"
#import "YYKHistoryCell.h"

static NSString *const kHistoryCellReusableIdentifier = @"HistoryCellReusableIdentifier";

@interface YYKHistoryViewController () <UITableViewDataSource,UITableViewSeparatorDelegate>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,retain) NSArray<YYKProgram *> *historyVideos;
@end

@implementation YYKHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.backgroundColor = self.view.backgroundColor;
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.rowHeight = lround(kScreenHeight * 0.1);
    _layoutTableView.hasRowSeparator = YES;
    _layoutTableView.hasSectionBorder = YES;
    [_layoutTableView registerClass:[YYKHistoryCell class] forCellReuseIdentifier:kHistoryCellReusableIdentifier];
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutTableView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        if (self) {
            [self reloadHistoryVideos];
            [self->_layoutTableView YYK_endPullToRefresh];
        }
    }];
    [_layoutTableView YYK_triggerPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isMovingToParentViewController) {
        [self reloadHistoryVideos];
    }
}

- (void)reloadHistoryVideos {
    self.historyVideos = [YYKProgram allPlayedPrograms];
    [_layoutTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[YYKStatsManager sharedManager] statsTabIndex:[YYKUtil currentTabPageIndex] subTabIndex:[YYKUtil currentSubTabPageIndex] forSlideCount:1];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYKHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryCellReusableIdentifier forIndexPath:indexPath];
    cell.backgroundColor = tableView.backgroundColor;
    
    if (indexPath.row < self.historyVideos.count) {
        YYKProgram *video = self.historyVideos[indexPath.row];
        cell.imageURL = [NSURL URLWithString:video.coverImg];
        cell.title = video.title;
        cell.subtitle = video.playedDateString;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyVideos.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.historyVideos.count) {
        YYKProgram *video = self.historyVideos[indexPath.row];
        [self switchToPlayProgram:(YYKProgram *)video programLocation:indexPath.row inChannel:nil shouldShowDetail:NO];
    }
}
@end
