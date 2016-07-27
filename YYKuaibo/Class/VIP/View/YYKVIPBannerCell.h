//
//  YYKVIPBannerCell.h
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYKVIPBannerItem : NSObject

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;

+ (instancetype)itemWithImageURL:(NSURL *)imageURL title:(NSString *)title;

@end

typedef void (^YYKVIPBannerSelectionAction)(NSUInteger index, id obj);

@interface YYKVIPBannerCell : UICollectionViewCell

@property (nonatomic,retain) NSArray<YYKVIPBannerItem *> *items;
@property (nonatomic,copy) YYKVIPBannerSelectionAction selectionAction;

@end
