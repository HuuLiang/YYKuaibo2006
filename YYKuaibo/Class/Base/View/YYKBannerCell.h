//
//  YYKBannerCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKBannerItem : NSObject

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;

+ (instancetype)itemWithImageURL:(NSURL *)imageURL title:(NSString *)title;

@end

@class YYKBannerCell;

typedef NS_ENUM(NSUInteger, YYKBannerCellStyle) {
    YYKBannerCellStyleCascade,
    YYKBannerCellStyleTile
};

@protocol YYKBannerCellDelegate <NSObject>

@optional
- (void)bannerCell:(YYKBannerCell *)bannerCell didSelectItemAtIndex:(NSUInteger)index;
- (UIImage *)bannerCell:(YYKBannerCell *)bannerCell tagImageAtIndex:(NSUInteger)index;
- (void)bannerCellDidEndDragging:(YYKBannerCell *)bannerCell willDecelerate:(BOOL)decelerate;

@end

@interface YYKBannerCell : UICollectionViewCell

@property (nonatomic) YYKBannerCellStyle style;
@property (nonatomic,weak) id<YYKBannerCellDelegate> delegate;
@property (nonatomic,retain) NSArray<YYKBannerItem *> *items;

@property (nonatomic,retain) UIImage *backgroundImage;
@property (nonatomic) BOOL showPageControl;

@end
