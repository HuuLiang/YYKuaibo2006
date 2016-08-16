//
//  YYKTagSearchViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKTagSearchViewController.h"
#import "YYKTagSearchFooterView.h"
#import "YYKKeywordTagModel.h"
#import "YYKKeyword.h"
#import "YYKVideoCell.h"
#import "YYKVideoSectionHeader.h"

static NSString *const kTagSearchCellReusableIdentifier = @"TagSearchCellReusableIdentifier";
static NSString *const kSearchErrorCellReusableIdentifier = @"SearchErrorCellReusableIdentifier";

static NSString *const kTagSearchHeaderReusableIdentifier = @"TagSearchHeaderReusableIdentifier";
static NSString *const kTagSearchFooterReusableIdentifier = @"TagSearchFooterReusableIdentifier";

static NSString *const kFeaturedHeaderReusableIdentifier = @"FeaturedHeaderReusableIdentifier";
static NSString *const kFeaturedCellReusableIdentifier = @"FeaturedCellReusableIdentifier";

static const void *kTextLabelAssociatedKey = &kTextLabelAssociatedKey;
static const void *kImageViewAssociatedKey = &kImageViewAssociatedKey;

static const NSUInteger kUnexpandedItemCount = 9;

typedef NS_ENUM(NSUInteger, YYKTagSearchSection) {
    YYKErrorSection,
    YYKTagSection,
    YYKFeaturedVideoSection,
    YYKTagSearchSectionCount
};

@interface YYKTagSearchViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCV;
}
@property (nonatomic,retain) NSArray<YYKKeyword *> *searchedKeywords;
@property (nonatomic,retain) YYKKeywordTagModel *tagModel;
@property (nonatomic) BOOL shouldExpandTags;

@end

@implementation YYKTagSearchViewController

DefineLazyPropertyInitialization(YYKKeywordTagModel, tagModel)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _layoutCV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCV.backgroundColor = self.view.backgroundColor;
    _layoutCV.delegate = self;
    _layoutCV.dataSource = self;
    [_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kTagSearchCellReusableIdentifier];
    [_layoutCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kSearchErrorCellReusableIdentifier];
    [_layoutCV registerClass:[YYKVideoCell class] forCellWithReuseIdentifier:kFeaturedCellReusableIdentifier];
    
    [_layoutCV registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kTagSearchHeaderReusableIdentifier];
    [_layoutCV registerClass:[YYKTagSearchFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kTagSearchFooterReusableIdentifier];
    [_layoutCV registerClass:[YYKVideoSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kFeaturedHeaderReusableIdentifier];
    [self.view addSubview:_layoutCV];
    {
        [_layoutCV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)reloadData {
    [_layoutCV reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.searchedKeywords = [YYKKeyword allKeywords];
    [_layoutCV reloadData];
    
    [self reloadHotTags];
    
}

//- (void)reloadSearchedKeywords {
//    self.searchedKeywords = [YYKKeyword allKeywords];
//    
//    NSUInteger numberOfSections = [_layoutCV numberOfSections];
//    if (numberOfSections > YYKHistorySection) {
//        [_layoutCV reloadSections:[NSIndexSet indexSetWithIndex:YYKHistorySection]];
//    }
//}

- (void)reloadHotTags {
    @weakify(self);
    [self.tagModel fetchTagsWithCompletionHandler:^(BOOL success, id obj) {
        @strongify(self);
        if (!self) {
            return ;
        }
        
        if (success) {
            self.shouldExpandTags = NO;
            [self->_layoutCV reloadData];
        }
    }];
}

- (UILabel *)textLabelInCell:(UICollectionViewCell *)cell {
    UILabel *textLabel = objc_getAssociatedObject(cell, kTextLabelAssociatedKey);
    if (!textLabel) {
        textLabel = [[UILabel alloc] init];
        objc_setAssociatedObject(cell, kTextLabelAssociatedKey, textLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        textLabel.font = kMediumFont;
        textLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:textLabel];
        {
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell).insets(UIEdgeInsetsMake(0, 5, 0, 5));
            }];
        }
    }
    return textLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return YYKTagSearchSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == YYKFeaturedVideoSection) {
        return self.tagModel.fetchedHotChannel.programList.count;
    } else if (section == YYKErrorSection) {
        if ([self.delegate respondsToSelector:@selector(searchErrorMessageInTagSearchViewController:)]) {
            if ([self.delegate searchErrorMessageInTagSearchViewController:self].length > 0) {
                return 1;
            }
        }
        return 0;
    } else if (section == YYKTagSection) {
        NSUInteger items = (self.tagModel.fetchedTags.count + 2)/3*3;
        if (self.shouldExpandTags || self.tagModel.fetchedTags.count <= kUnexpandedItemCount) {
            return items;
        } else {
            return kUnexpandedItemCount;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKErrorSection) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSearchErrorCellReusableIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        
        UILabel *textLabel = [self textLabelInCell:cell];
        textLabel.numberOfLines = 4;
        
        if ([self.delegate respondsToSelector:@selector(searchErrorMessageInTagSearchViewController:)]) {
            textLabel.attributedText = [self.delegate searchErrorMessageInTagSearchViewController:self];
        } else {
            textLabel.attributedText = nil;
        }
        return cell;
    } else if (indexPath.section == YYKTagSection) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagSearchCellReusableIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        
        UILabel *textLabel = [self textLabelInCell:cell];
        if (indexPath.section == YYKFeaturedVideoSection) {
            if (indexPath.item < self.searchedKeywords.count) {
                YYKKeyword *keyword = self.searchedKeywords[indexPath.item];
                textLabel.text = keyword.text;
            } else {
                textLabel.text = nil;
            }
        } else if (indexPath.section == YYKTagSection) {
            if (indexPath.item < self.tagModel.fetchedTags.count) {
                NSString *tag = self.tagModel.fetchedTags[indexPath.item];
                textLabel.text = tag;
            } else {
                textLabel.text = nil;
            }
        }
        return cell;
    } else if (indexPath.section == YYKFeaturedVideoSection) {
        YYKVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFeaturedCellReusableIdentifier forIndexPath:indexPath];
        if (!cell.placeholderImage) {
            cell.placeholderImage = [UIImage imageNamed:@"placeholder_1_1"];
        }
        
        if (indexPath.item < self.tagModel.fetchedHotChannel.programList.count) {
            YYKProgram *program = self.tagModel.fetchedHotChannel.programList[indexPath.item];
            cell.imageURL = [NSURL URLWithString:program.coverImg];
            cell.title = program.title;
            cell.tagText = program.tag;
            cell.tagBackgroundColor = kThemeColor;
            cell.popularity = program.spare.integerValue;
        }
        return cell;
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (indexPath.section == YYKTagSection) {
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTagSearchHeaderReusableIdentifier forIndexPath:indexPath];
            
            UIImageView *imageView = objc_getAssociatedObject(headerView, kImageViewAssociatedKey);
            if (!imageView) {
                imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"section_title_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                objc_setAssociatedObject(headerView, kImageViewAssociatedKey, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                imageView.tintColor = kThemeColor;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [headerView addSubview:imageView];
                {
                    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(headerView);
                        make.left.equalTo(headerView).offset(5);
                        make.height.equalTo(headerView).multipliedBy(0.5);
                        make.width.equalTo(imageView.mas_height);
                    }];
                }
            }
            
            UILabel *textLabel = objc_getAssociatedObject(headerView, kTextLabelAssociatedKey);
            if (!textLabel) {
                textLabel = [[UILabel alloc] init];
                objc_setAssociatedObject(headerView, kTextLabelAssociatedKey, textLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
                textLabel.font = kMediumFont;
                [headerView addSubview:textLabel];
                {
                    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(imageView.mas_right).offset(5);
                        make.centerY.equalTo(headerView);
                    }];
                }
            }
            textLabel.text = indexPath.section == YYKTagSection ? @"热门搜索" : @"搜索历史";
            return headerView;
        } else if (indexPath.section == YYKFeaturedVideoSection) {
            YYKVideoSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kFeaturedHeaderReusableIdentifier forIndexPath:indexPath];
            headerView.title = @"热搜影片";
            return headerView;
        }
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        YYKTagSearchFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kTagSearchFooterReusableIdentifier forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor whiteColor];
        
        if (indexPath.section == YYKTagSection) {
            footerView.image = [UIImage imageNamed:@"search_tag_expand"];
            
            if (self.shouldExpandTags) {
                footerView.imageTransform = CGAffineTransformMakeRotation(M_PI);
            } else {
                footerView.imageTransform = CGAffineTransformIdentity;
            }
            
            @weakify(self);
            footerView.tapAction = ^(id obj) {
                @strongify(self);
                self.shouldExpandTags = !self.shouldExpandTags;
                [self->_layoutCV reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            };
        }
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKFeaturedVideoSection) {
        const CGFloat itemWidth = (CGRectGetWidth(collectionView.bounds) - kDefaultCollectionViewInteritemSpace)/2;
        const CGFloat itemHeight = [YYKVideoCell heightRelativeToWidth:itemWidth withScale:5./3.];
        return CGSizeMake(itemWidth, itemHeight);
    } else if (indexPath.section == YYKErrorSection) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 100);
    } else {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds)/3, 44);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == YYKErrorSection) {
        return CGSizeZero;
    } else if (section == YYKTagSection) {
        if (self.tagModel.fetchedTags.count == 0) {
            return CGSizeZero;
        }
    } else if (section == YYKFeaturedVideoSection) {
        if (self.tagModel.fetchedHotChannel.programList.count == 0) {
            return CGSizeZero;
        }
    }
    return CGSizeMake(0, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == YYKTagSection) {
        if (self.tagModel.fetchedTags.count <= kUnexpandedItemCount) {
            return CGSizeZero;
        } else {
            return CGSizeMake(0, 35);
        }
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == YYKFeaturedVideoSection) {
        return kDefaultCollectionViewInteritemSpace;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == YYKFeaturedVideoSection) {
        return kDefaultCollectionViewInteritemSpace;
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYKFeaturedVideoSection) {
        if (indexPath.item < self.tagModel.fetchedHotChannel.programList.count) {
            YYKProgram *program = self.tagModel.fetchedHotChannel.programList[indexPath.item];
            [self switchToPlayProgram:program programLocation:indexPath.item inChannel:self.tagModel.fetchedHotChannel];
        }
    } else {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UILabel *textLabel = objc_getAssociatedObject(cell, kTextLabelAssociatedKey);
        if (textLabel.text.length == 0) {
            return ;
        }
        
        if (indexPath.section == YYKErrorSection) {
            if ([self.delegate respondsToSelector:@selector(tagSearchViewController:didSelectErrorMessage:)]) {
                [self.delegate tagSearchViewController:self didSelectErrorMessage:textLabel.text];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(tagSearchViewController:didSelectKeyword:)]) {
                BOOL isTag = indexPath.section == YYKTagSection;
                [self.delegate tagSearchViewController:self didSelectKeyword:[YYKKeyword keywordWithText:textLabel.text isTag:isTag]];
            }
        }
    }
}
@end
