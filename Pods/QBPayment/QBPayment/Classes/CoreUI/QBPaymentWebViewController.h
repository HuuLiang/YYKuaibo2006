//
//  QBPaymentWebViewController.h
//  Pods
//
//  Created by Sean Yue on 2016/10/21.
//
//

#import <UIKit/UIKit.h>

@interface QBPaymentWebViewController : UIViewController

@property (nonatomic,copy) void (^closeAction)(void);

- (instancetype)initWithHTMLString:(NSString *)htmlString;

@end
