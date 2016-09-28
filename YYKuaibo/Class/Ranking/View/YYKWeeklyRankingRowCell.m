//
//  YYKWeeklyRankingRowCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKWeeklyRankingRowCell.h"
#import "YYKWeeklyRankingCell.h"

static NSString *const kRankingCellReusableIdentifier = @"RankingCellReusableIdentifier";

@interface YYKWeeklyRankingRowCell () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCV;
    UIImageView *_leftPagingIndicator;
    UIImageView *_rightPagingIndicator;
}
@end

@implementation YYKWeeklyRankingRowCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = layout.minimumInteritemSpacing;
        
        _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _layoutCV.backgroundColor = kLightBackgroundColor;
        _layoutCV.delegate = self;
        _layoutCV.dataSource = self;
        [_layoutCV registerClass:[YYKWeeklyRankingCell class] forCellWithReuseIdentifier:kRankingCellReusableIdentifier];
        [_layoutCV addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:nil];
        [_layoutCV addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:_layoutCV];
        {
            [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _leftPagingIndicator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"paging_indicator"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _leftPagingIndicator.tintColor = kThemeColor;
        _leftPagingIndicator.contentMode = UIViewContentModeScaleAspectFit;
        _leftPagingIndicator.hidden = YES;
        _leftPagingIndicator.transform = CGAffineTransformMakeRotation(M_PI);
        [self addSubview:_leftPagingIndicator];
        {
            [_leftPagingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(kLeftRightContentMarginSpacing);
                make.centerY.equalTo(self);
            }];
        }
        
        _rightPagingIndicator = [[UIImageView alloc] initWithImage:_leftPagingIndicator.image];
        _rightPagingIndicator.tintColor = kThemeColor;
        _rightPagingIndicator.contentMode = UIViewContentModeScaleAspectFit;
        _rightPagingIndicator.hidden = YES;
        [self addSubview:_rightPagingIndicator];
        {
            [_rightPagingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-kLeftRightContentMarginSpacing);
                make.centerY.equalTo(self);
            }];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]
        || [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        [self updateVisibilitiesOfPagingIndicators];
    }
}

- (void)updateVisibilitiesOfPagingIndicators {
    if (_layoutCV.contentOffset.x < CGRectGetHeight(_layoutCV.bounds) / 2) {
        _leftPagingIndicator.hidden = YES;
    } else {
        _leftPagingIndicator.hidden = NO;
    }
    
    if (_layoutCV.contentOffset.x + CGRectGetWidth(_layoutCV.bounds) > _layoutCV.contentSize.width - CGRectGetHeight(_layoutCV.bounds) / 2) {
        _rightPagingIndicator.hidden = YES;
    } else {
        _rightPagingIndicator.hidden = NO;
    }
}

- (void)dealloc {
    [_layoutCV removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
    [_layoutCV removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

- (void)setItems:(NSArray<YYKWeeklyRankingRowCellItem *> *)items {
    _items = items;
    
    [_layoutCV reloadData];
    _layoutCV.contentOffset = CGPointZero;
    [self updateVisibilitiesOfPagingIndicators];
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YYKWeeklyRankingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRankingCellReusableIdentifier forIndexPath:indexPath];
    
    if (indexPath.item < self.items.count) {
        YYKWeeklyRankingRowCellItem *item = self.items[indexPath.item];
        cell.imageURL = item.imageURL;
        cell.title = [NSString stringWithFormat:@"NO.%ld", indexPath.item+1];
        cell.subtitle = item.title;
        cell.tagName = item.tag;
        cell.popularity = item.popularity;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const UIEdgeInsets sectionInsets = [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
    const CGFloat lineSpacing = [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];
    
    const CGFloat itemHeight = (CGRectGetHeight(collectionView.bounds) - 2 * lineSpacing - sectionInsets.top - sectionInsets.bottom)/3;
    return CGSizeMake([YYKWeeklyRankingCell widthRelativeToHeight:itemHeight withImageScale:5./3.], itemHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SafelyCallBlock(self.selectionAction, indexPath.item, self);
}
@end

@implementation YYKWeeklyRankingRowCellItem

@end
