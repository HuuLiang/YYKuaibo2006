//
//  YYKChannelViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/4/19.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKChannelViewController.h"
#import "YYKChannelCell.h"
#import "YYKVideoCell.h"
#import "YYKChannelModel.h"
#import "YYKChannelProgramModel.h"

static NSString *const kChannelCollectionViewCellReusableIdentifier = @"ChannelCollectionCellReusableIdentifier";
static NSString *const kChannelTableViewCellReusableIdentifier = @"ChannelTableViewCellReusableIdentifier";
static const CGFloat kChannelTableViewWidth = 100;

@interface YYKChannelViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewSeparatorDelegate,UITableViewDataSource>
{
    UICollectionView *_contentView;
    UITableView *_channelTableView;
}
@property (nonatomic,retain) YYKChannelModel *channelModel;
@property (nonatomic,retain) YYKChannel *currentChannel;
@property (nonatomic,retain) YYKChannelProgramModel *programModel;
@property (nonatomic,retain) NSMutableDictionary<NSNumber *, NSMutableArray<YYKProgram *> *> *channelPrograms;
@end

@implementation YYKChannelViewController

DefineLazyPropertyInitialization(YYKChannelModel, channelModel)
DefineLazyPropertyInitialization(YYKChannelProgramModel, programModel)

- (NSMutableDictionary<NSNumber *,NSMutableArray<YYKProgram *> *> *)channelPrograms {
    if (_channelPrograms) {
        return _channelPrograms;
    }
    
    NSArray<YYKChannel *> *channels = self.programModel.cachedChannels;
    _channelPrograms = [NSMutableDictionary dictionary];
    [channels enumerateObjectsUsingBlock:^(YYKChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.columnId && obj.programList) {
            [_channelPrograms setObject:obj.programList.mutableCopy forKey:obj.columnId];
        }
    }];
    
    return _channelPrograms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _channelTableView = [[UITableView alloc] init];
    _channelTableView.scrollsToTop = NO;
    _channelTableView.backgroundColor = [UIColor clearColor];
    _channelTableView.delegate = self;
    _channelTableView.dataSource = self;
    _channelTableView.hasRowSeparator = YES;
    _channelTableView.hasSectionBorder = YES;
    _channelTableView.separatorInset = UIEdgeInsetsZero;
    _channelTableView.separatorColor = [UIColor colorWithWhite:0.5 alpha:1];
    [_channelTableView registerClass:[YYKChannelCell class] forCellReuseIdentifier:kChannelTableViewCellReusableIdentifier];
    [self.view addSubview:_channelTableView];
    {
        [_channelTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.view);
            make.width.mas_equalTo(kChannelTableViewWidth);
        }];
    }
    
    @weakify(self);
    [_channelTableView YYK_addPullToRefreshWithStyle:YYKPullToRefreshStyleDissolution handler:^{
        @strongify(self);
        [self loadChannels];
    }];
    
    //Collection View
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = layout.minimumInteritemSpacing;
    
    _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.delegate = self;
    _contentView.dataSource = self;
    [_contentView registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kChannelCollectionViewCellReusableIdentifier];
    [self.view addSubview:_contentView];
    {
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self.view);
            make.left.equalTo(_channelTableView.mas_right).offset(5);
        }];
    }
    
    self.currentChannel = self.channelModel.fetchedChannels.firstObject;

    [_contentView YYK_addPullToRefreshWithHandler:^{
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (self.channelModel.fetchedChannels.count == 0) {
            [self->_channelTableView YYK_triggerPullToRefresh];
        } else {
            [self loadProgramsInChannel:self.currentChannel.columnId withRefresh:YES];
        }
        
    }];
    
    [_contentView YYK_addPagingRefreshWithHandler:^{
        [self loadProgramsInChannel:self.currentChannel.columnId withRefresh:NO];
    }];
    [_contentView YYK_pagingRefreshNoMoreData];
    // Load data
    [_channelTableView YYK_triggerPullToRefresh];
}

- (void)loadChannels {
    @weakify(self);
    [self.channelModel fetchChannelsWithCompletionHandler:^(BOOL success, NSArray<YYKChannel *> *channels) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_channelTableView YYK_endPullToRefresh];
        
        if (success) {
            [self->_channelTableView reloadData];
            self.currentChannel = channels.firstObject;
        }
        
        if (self.currentChannel == nil && [self->_contentView isRefreshing]) {
            [self->_contentView YYK_endPullToRefresh];
        }
    }];
}

- (void)loadProgramsInChannel:(NSNumber *)channelId withRefresh:(BOOL)isRefresh {
    if (channelId == nil) {
        [_contentView YYK_endPullToRefresh];
        return ;
    }
    
    @weakify(self);
    NSUInteger pageNo = isRefresh ? 1 : self.programModel.fetchedChannel.page.unsignedIntegerValue + 1;
    [self.programModel fetchProgramsWithColumnId:channelId pageNo:pageNo pageSize:20 completionHandler:^(BOOL success, YYKChannel *channel) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        [self->_contentView YYK_endPullToRefresh];
        
        if (success) {
            if (isRefresh) {
                [self.channelPrograms removeObjectForKey:channelId];
            }
            
            NSMutableArray<YYKProgram *> *programsInChannel = [self.channelPrograms objectForKey:channelId];
            
            if (channel.programList.count > 0) {
                if (!programsInChannel) {
                    programsInChannel = [NSMutableArray array];
                }
                
                [programsInChannel addObjectsFromArray:channel.programList];
                [self.channelPrograms setObject:programsInChannel forKey:channelId];
            }
            [self->_contentView reloadData];
            
            if (programsInChannel.count >= channel.items.unsignedIntegerValue) {
                [self->_contentView YYK_pagingRefreshNoMoreData];
            }
        }
    }];
}

- (void)setCurrentChannel:(YYKChannel *)currentChannel {
    YYKChannel *oldChannel = _currentChannel;
    _currentChannel = currentChannel;
    
    NSUInteger channelIndex = [self.channelModel.fetchedChannels indexOfObject:currentChannel];
    if (!_channelTableView.indexPathForSelectedRow || channelIndex != _channelTableView.indexPathForSelectedRow.row) {
        [_channelTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:channelIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [_contentView reloadData];
    _contentView.contentOffset = CGPointZero;
    NSMutableArray<YYKProgram *> *programs = [self.channelPrograms objectForKey:currentChannel.columnId];
    if (programs.count == 0 || oldChannel == currentChannel) {
        if ([_contentView isRefreshing]) {
            [self loadProgramsInChannel:currentChannel.columnId withRefresh:YES];
        } else {
            [_contentView YYK_triggerPullToRefresh];
        }
    } else {
        if ([_contentView isRefreshing]) {
            [_contentView YYK_endPullToRefresh];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelCollectionViewCellReusableIdentifier forIndexPath:indexPath];
    cell.placeholderImage = [UIImage imageNamed:@"placeholder_5_3"];
    
    NSArray<YYKProgram *> *programs = [self.channelPrograms objectForKey:self.currentChannel.columnId];
    if (indexPath.row < programs.count) {
        YYKProgram *program = programs[indexPath.row];
        cell.title = program.title;
        cell.imageURL = [NSURL URLWithString:program.coverImg];
        cell.spec = program.spec.unsignedIntegerValue;
        cell.showPlayIcon = YES;
    } else {
        cell.title = nil;
        cell.imageURL = nil;
        cell.showPlayIcon = NO;
        cell.spec = YYKVideoSpecNone;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray<YYKProgram *> *programs = [self.channelPrograms objectForKey:self.currentChannel.columnId];
    return programs.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat itemWidth = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(itemWidth, itemWidth * 3. / 5.);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<YYKProgram *> *programs = [self.channelPrograms objectForKey:self.currentChannel.columnId];
    if (indexPath.item < programs.count) {
        YYKProgram *program = programs[indexPath.item];
        [self switchToPlayProgram:program programLocation:indexPath.item inChannel:self.currentChannel];
        
        [[YYKStatsManager sharedManager] statsCPCWithProgram:program
                                             programLocation:indexPath.item
                                                   inChannel:self.currentChannel
                                                 andTabIndex:self.tabBarController.selectedIndex
                                                 subTabIndex:NSNotFound];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _contentView) {
        [[YYKStatsManager sharedManager] statsTabIndex:self.tabBarController.selectedIndex subTabIndex:NSNotFound forSlideCount:1];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYKChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:kChannelTableViewCellReusableIdentifier forIndexPath:indexPath];
    
    if (indexPath.row < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[indexPath.row];
        cell.textLabel.text = channel.name;
    } else {
        cell.textLabel.text = nil;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelModel.fetchedChannels.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.channelModel.fetchedChannels.count) {
        YYKChannel *channel = self.channelModel.fetchedChannels[indexPath.row];
        [self setCurrentChannel:channel];
        
        [[YYKStatsManager sharedManager] statsCPCWithChannel:channel inTabIndex:self.tabBarController.selectedIndex];
    }
    
}

@end
