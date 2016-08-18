//
//  YYKVideoLibViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/16.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVideoLibViewController.h"
#import "YYKChannelModel.h"
#import "YYKChannelCell.h"
#import "NSDate+Utilities.h"

static NSString *const kChannelCellReusableIdentifier = @"ChannelCellReusableIdentifier";
static NSString *const kChannelHeaderReusableIdentifier = @"ChannelHeaderReusableIdentifier";

@interface YYKVideoLibViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_layoutTV;
}
@property (nonatomic,retain) YYKChannelModel *channelModel;
@property (nonatomic,retain) NSMutableDictionary<NSNumber *, NSNumber *> *numbersOfupdates;
@end

@implementation YYKVideoLibViewController

DefineLazyPropertyInitialization(YYKChannelModel, channelModel)
DefineLazyPropertyInitialization(NSMutableDictionary, numbersOfupdates)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _layoutTV = [[UITableView alloc] init];
    _layoutTV.backgroundColor = self.view.backgroundColor;
    _layoutTV.delegate = self;
    _layoutTV.dataSource = self;
    _layoutTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_layoutTV registerClass:[YYKChannelCell class] forCellReuseIdentifier:kChannelCellReusableIdentifier];
    [_layoutTV registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kChannelHeaderReusableIdentifier];
    [self.view addSubview:_layoutTV];
    {
        [_layoutTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_layoutTV YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadChannels];
    }];
    [_layoutTV YYK_triggerPullToRefresh];
}

- (void)loadChannels {
    @weakify(self);
    [self.channelModel fetchChannelsInSpace:YYKChannelSpaceDefault withCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_layoutTV YYK_endPullToRefresh];
        
        if (success) {
            [self->_layoutTV reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (unsigned long)numberOfUpdatesForChannel:(YYKChannel *)channel {
    if (!channel.columnId) {
        return 20;
    }
    
    NSDate *date = [[NSDate date] dateAtStartOfDay];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    unsigned long ref = timeInterval * channel.columnId.unsignedIntegerValue / 99999;
    return ref % 30 + 10;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.channelModel.fetchedChannels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYKChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:kChannelCellReusableIdentifier forIndexPath:indexPath];
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_5_2"];
    
    if (indexPath.section < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[indexPath.section];
        cell.imageURL = [NSURL URLWithString:channel.columnImg];
        cell.title = channel.name;
        cell.subtitle = [NSString stringWithFormat:@"更新%ld部 >", (unsigned long)[self numberOfUpdatesForChannel:channel]];
        cell.popularity = channel.spare.integerValue;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kChannelHeaderReusableIdentifier];
    
    if (!headerView.backgroundView) {
        headerView.backgroundView = [[UIView alloc] init];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetWidth(tableView.bounds)/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[indexPath.section];
        [self openChannel:channel];
    }
}
@end
