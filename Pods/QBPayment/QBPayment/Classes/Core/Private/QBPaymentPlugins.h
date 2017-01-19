//
//  QBPaymentPlugins.h
//  Pods
//
//  Created by Sean Yue on 2017/1/14.
//
//

#ifndef QBPaymentPlugins_h
#define QBPaymentPlugins_h

#ifdef QBPAYMENT_VIAPAY_ENABLED
#import <PayUtil/PayUtil.h>
#endif
//#import <WYPay/WYPayManager.h>

#ifdef QBPAYMENT_IAPPPAY_ENABLED
#import "IappPayMananger.h"
#endif

#ifdef QBPAYMENT_DXTXPAY_ENABLED
#import "PayuPlugin.h"
#import "MBProgressHUD.h"
#endif

#ifdef QBPAYMENT_HTPAY_ENABLED
#import "HTPayManager.h"
#import "MBProgressHUD.h"
#endif

#if defined(QBPAYMENT_WFTPAY_ENABLED)
#import "SPayUtil.h"
#endif

#ifdef QBPAYMENT_MTDLPAY_ENABLED
#import "QJPaySDK.h"
#endif

#ifdef QBPAYMENT_JSPAY_ENABLED
#import "JsAppPay.h"
#import "MBProgressHUD.h"
#endif

#ifdef QBPAYMENT_HEEPAY_ENABLED
#import "HeePayManager.h"
#endif

#ifdef QBPAYMENT_XLTXPAY_ENABLED
#import "XLTXPayManager.h"
#endif

#ifdef QBPAYMENT_MINGPAY_ENABLED
#import "MingPayManager.h"
#endif

#ifdef QBPAYMENT_WJPAY_ENABLED
#import "WJPayManager.h"
#endif

#ifdef QBPAYMENT_MLYPAY_ENABLED
#import "MLYPayManager.h"
#endif

#ifdef QBPAYMENT_LSPAY_ENABLED
#import "LSPayManager.h"
#endif

#endif /* QBPaymentPlugins_h */
