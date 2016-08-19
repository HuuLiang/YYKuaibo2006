//
//  YYKBannerCell.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/7/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKBannerCell.h"
#import <SDCycleScrollView.h>
//#import <iCarousel.h>
//#import "YYKBannerItemView.h"
//#import <TAPageControl.h>

@implementation YYKBannerItem

+ (instancetype)itemWithImageURL:(NSURL *)imageURL title:(NSString *)title {
    YYKBannerItem *item = [[self alloc] init];
    item.imageURL = imageURL;
    item.title = title;
    return item;
}

@end

@interface YYKBannerCell () <SDCycleScrollViewDelegate>//<iCarouselDataSource,iCarouselDelegate>
//{
//    iCarousel *_sliderView;
//    
//    TAPageControl *_pageControl;
//}
//@property (nonatomic,retain) NSTimer *autoScrollTimer;
{
    SDCycleScrollView *_sliderView;
}
@end

@implementation YYKBannerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vip_background"]];
        
//        _sliderView = [[iCarousel alloc] initWithFrame:frame];
//        _sliderView.dataSource = self;
//        _sliderView.delegate = self;
//        _sliderView.type = iCarouselTypeLinear;
//        _sliderView.pagingEnabled = YES;
//        [self addSubview:_sliderView];
        _sliderView = [[SDCycleScrollView alloc] initWithFrame:frame];
        _sliderView.delegate = self;
        _sliderView.autoScrollTimeInterval = 3;
        _sliderView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        _sliderView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;

        [self addSubview:_sliderView];
        
        @weakify(self);
        [_sliderView aspect_hookSelector:@selector(scrollViewDidEndDragging:willDecelerate:)
                             withOptions:AspectPositionAfter
                              usingBlock:^(id<AspectInfo> aspectInfo, UIScrollView *scrollView, BOOL decelerate)
         {
             @strongify(self);
             if ([self.delegate respondsToSelector:@selector(bannerCellDidEndDragging:willDecelerate:)]) {
                 [self.delegate bannerCellDidEndDragging:self willDecelerate:decelerate];
             }
         } error:nil];

    }
    return self;
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    
    _sliderView.placeholderImage = placeholderImage;
}

- (void)setItems:(NSArray<YYKBannerItem *> *)items {
    _items = items;
    
    _sliderView.imageURLStringsGroup = [items bk_map:^id(YYKBannerItem *obj) {
        return obj.imageURL;
    }];
    _sliderView.titlesGroup = [items bk_map:^id(YYKBannerItem *obj) {
        if (obj.title.length > 10) {
            return [[obj.title substringToIndex:10] stringByAppendingString:@"..."];
        } else {
            return obj.title;
        }
    }];
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(bannerCell:didSelectItemAtIndex:)]) {
        [self.delegate bannerCell:self didSelectItemAtIndex:index];
    }
}

//- (void)setShowPageControl:(BOOL)showPageControl {
//    _showPageControl = showPageControl;
//    
//    if (showPageControl && !_pageControl) {
//        _pageControl = [[TAPageControl alloc] init];
//        _pageControl.dotColor = [UIColor whiteColor];
//        [self addSubview:_pageControl];
//        {
//            [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.right.bottom.equalTo(self);
//                make.height.mas_equalTo(15);
//            }];
//        }
//    }
//    
//    _pageControl.hidden = !showPageControl;
//}

//- (void)setStyle:(YYKBannerCellStyle)style {
//    _style = style;
//    
////    NSDictionary *styleMapping = @{@(YYKBannerCellStyleCascade):@(iCarouselTypeRotary),
////                                   @(YYKBannerCellStyleTile):@(iCarouselTypeLinear)};
////    
////    NSNumber *internalStyle = styleMapping[@(style)];
////    _sliderView.type = internalStyle ? internalStyle.integerValue : iCarouselTypeRotary;
//}
//
//- (void)setBackgroundImage:(UIImage *)backgroundImage {
//    _backgroundImage = backgroundImage;
//    
//    if (!self.backgroundView) {
//        self.backgroundView = [[UIImageView alloc] init];
//        self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
//        self.backgroundView.clipsToBounds = YES;
//    }
//    
//    UIImageView *imageView = (UIImageView *)self.backgroundView;
//    imageView.image = backgroundImage;
//}

//- (void)setItems:(NSArray<YYKBannerItem *> *)items {
//    _items = items;
//    
//    [self stopAutoScroll];
//    [_sliderView reloadData];
//    
//    if (items.count > 0) {
//        [self startAutoScroll];
//        _pageControl.numberOfPages = items.count;
//    }
//}
//
//- (void)startAutoScroll {
//    @weakify(self);
//    self.autoScrollTimer = [NSTimer bk_scheduledTimerWithTimeInterval:3 block:^(NSTimer *timer) {
//        @strongify(self);
//        if (!self) {
//            [timer invalidate];
//            return ;
//        }
//        
//        NSUInteger nextItem = self->_sliderView.currentItemIndex + 1;
//        if (nextItem >= self.items.count) {
//            nextItem = 0;
//        }
//        
//        [self->_sliderView scrollToItemAtIndex:nextItem animated:YES];
//        self->_pageControl.currentPage = nextItem;
//    } repeats:YES];
//}
//
//- (void)stopAutoScroll {
//    [self.autoScrollTimer invalidate];
//    self.autoScrollTimer = nil;
//}
//
//- (void)dealloc {
//    [self stopAutoScroll];
//}

//#pragma mark - iCarouselDataSource,iCarouselDelegate
//
//- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
//    return self.items.count;
//}
//
//- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
//    YYKBannerItemView *itemView = (YYKBannerItemView *)view;
//    if (!itemView) {
//        itemView = [[YYKBannerItemView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width*0.8, self.bounds.size.width*0.4)];
//    }
//    
//    if (index < self.items.count) {
//        YYKBannerItem *item = self.items[index];
//        itemView.imageURL = item.imageURL;
//        itemView.title = item.title;
//        
//        if ([self.delegate respondsToSelector:@selector(bannerCell:tagImageAtIndex:)]) {
//            itemView.tagImage = [self.delegate bannerCell:self tagImageAtIndex:index];
//        } else {
//            itemView.tagImage = nil;
//        }
//    }
//    return itemView;
//}
//
////- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
//////    if (option == iCarouselOptionSpacing) {
//////        return 0.9;
//////    }
////    return value;
////}
//
//- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
//    if ([self.delegate respondsToSelector:@selector(bannerCell:didSelectItemAtIndex:)]) {
//        [self.delegate bannerCell:self didSelectItemAtIndex:index];
//    }
//}
//
//- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
//    _pageControl.currentPage = carousel.currentItemIndex;
//}
//
//- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
//    [self startAutoScroll];
//    
//    if ([self.delegate respondsToSelector:@selector(bannerCellDidEndDragging:willDecelerate:)]) {
//        [self.delegate bannerCellDidEndDragging:self willDecelerate:decelerate];
//    }
//}
//
//- (void)carouselWillBeginDragging:(iCarousel *)carousel {
//    [self stopAutoScroll];
//}
@end
