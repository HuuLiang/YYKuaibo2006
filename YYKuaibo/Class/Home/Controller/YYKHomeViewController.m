//
//  YYKHomeViewController.m
//  YYKuaibo
//
//  Created by Sean Yue on 16/3/14.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "YYKHomeViewController.h"
#import "YYKVideoLibViewController.h"
#import "YYKHotVideoViewController.h"
#import "YYKSideMenuViewController.h"

@interface YYKHomeViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>
{
    UISegmentedControl *_segmentedControl;
    UIPageViewController *_pageViewController;
}
@property (nonatomic,retain) NSMutableArray<UIViewController *> *viewControllers;
@end

@implementation YYKHomeViewController

DefineLazyPropertyInitialization(NSMutableArray, viewControllers)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    YYKVideoLibViewController *videoLibVC = [[YYKVideoLibViewController alloc] init];
    [self.viewControllers addObject:videoLibVC];
    
    YYKHotVideoViewController *hotVideoVC = [[YYKHotVideoViewController alloc] init];
    [self.viewControllers addObject:hotVideoVC];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    [_pageViewController setViewControllers:@[self.viewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
    NSArray *segmentItems = @[@"片 库", @"热 播"];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentItems];
    for (NSUInteger i = 0; i < segmentItems.count; ++i) {
        [_segmentedControl setWidth:66 forSegmentAtIndex:i];
    }
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(selectedSegmentIndex))
                           options:NSKeyValueObservingOptionNew
                           context:nil];
    self.navigationItem.titleView = _segmentedControl;
    
    @weakify(self);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"side_menu_icon"]
                                                                                style:UIBarButtonItemStylePlain
                                                                              handler:^(id sender)
    {
        @strongify(self);
        [self.sideMenuViewController presentLeftMenuViewController];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(selectedSegmentIndex))]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        
        [_pageViewController setViewControllers:@[self.viewControllers[newValue.unsignedIntegerValue]]
                                      direction:newValue.unsignedIntegerValue>oldValue.unsignedIntegerValue?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES completion:nil];
    }
}

#pragma mark - UIPageViewControllerDelegate,UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger viewControllerIndex = [self.viewControllers indexOfObject:viewController];
    if (viewControllerIndex != self.viewControllers.count-1) {
        return self.viewControllers[viewControllerIndex+1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger viewControllerIndex = [self.viewControllers indexOfObject:viewController];
    if (viewControllerIndex != 0) {
        return self.viewControllers[viewControllerIndex-1];
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed) {
        _segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:pageViewController.viewControllers.firstObject];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
