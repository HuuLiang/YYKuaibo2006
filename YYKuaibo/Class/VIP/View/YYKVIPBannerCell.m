//
//  YYKVIPBannerCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKVIPBannerCell.h"
#import <iCarousel.h>
#import "YYKVIPBannerItemView.h"

@implementation YYKVIPBannerItem

+ (instancetype)itemWithImageURL:(NSURL *)imageURL title:(NSString *)title {
    YYKVIPBannerItem *item = [[self alloc] init];
    item.imageURL = imageURL;
    item.title = title;
    return item;
}

@end

@interface YYKVIPBannerCell () <iCarouselDataSource,iCarouselDelegate>
{
    iCarousel *_sliderView;
}
@property (nonatomic,retain) NSTimer *autoScrollTimer;
@end

@implementation YYKVIPBannerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_background"]];
        
        _sliderView = [[iCarousel alloc] initWithFrame:frame];
        _sliderView.dataSource = self;
        _sliderView.delegate = self;
        _sliderView.type = iCarouselTypeRotary;
        [self addSubview:_sliderView];
    }
    return self;
}

- (void)setItems:(NSArray<YYKVIPBannerItem *> *)items {
    _items = items;
    
    [self stopAutoScroll];
    [_sliderView reloadData];
    
    if (items.count > 0) {
        [self startAutoScroll];
    }
}

- (void)startAutoScroll {
    @weakify(self);
    self.autoScrollTimer = [NSTimer bk_scheduledTimerWithTimeInterval:3 block:^(NSTimer *timer) {
        @strongify(self);
        if (!self) {
            [timer invalidate];
            return ;
        }
        
        NSUInteger nextItem = self->_sliderView.currentItemIndex + 1;
        if (nextItem >= self.items.count) {
            nextItem = 0;
        }
        
        [self->_sliderView scrollToItemAtIndex:nextItem animated:YES];
    } repeats:YES];
}

- (void)stopAutoScroll {
    [self.autoScrollTimer invalidate];
    self.autoScrollTimer = nil;
}

- (void)dealloc {
    [self stopAutoScroll];
}

#pragma mark - iCarouselDataSource,iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.items.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    YYKVIPBannerItemView *itemView = (YYKVIPBannerItemView *)view;
    if (!itemView) {
        itemView = [[YYKVIPBannerItemView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width*0.8, self.bounds.size.width*0.4)];
    }
    
    if (index < self.items.count) {
        YYKVIPBannerItem *item = self.items[index];
        itemView.imageURL = item.imageURL;
        itemView.title = item.title;
    }
    return itemView;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionWrap) {
        return 1;
    }
    return value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    SafelyCallBlock(self.selectionAction, index, self);
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    [self startAutoScroll];
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel {
    [self stopAutoScroll];
}
@end
