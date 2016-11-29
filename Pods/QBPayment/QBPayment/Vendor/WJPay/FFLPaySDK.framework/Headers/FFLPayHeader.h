//
//  FFLPayHeader.h
//  FFLPaySDK-iOS
//
//  Created by YIF on 16/11/22.
//  Copyright © 2016年 88.la. All rights reserved.
//

#ifndef FFLPayHeader_h
#define FFLPayHeader_h

//支付回调
//  成功=0   payInfo={code:0, msg:xxx, order:xxx}
//  失败!=0  payInfo={code:0, msg:xxx, order:xxx}
typedef void(^FFLPayFinishBlock) (NSDictionary *payInfo);



//支付模式
typedef enum {
    weixin_wap      = 101,               //微信wap支付（只有url)
    weixin_wft_app  = 102,               //威富通app
    weixin_wft_wap  = 103,               //威富通sdkwap
    weixin_hfb_wap  = 104,               //汇付宝sdkwap
    weixin_code     = 105,               //微信扫码
    alipay_app      = 106,               //支付宝SDK
} FFLPayEnumPayway;



//支付状态
typedef enum {
    
    //传入的参数错误
    FFLPayEnum_ParameterError    = 101,
    
    //TokenID失效
    FFLPayEnum_PayTokenIDInvalid = 102,
    
    //支付成功
    FFLPayEnum_PaySuccess    = 201,
    
    //支付处理中
    FFLPayEnum_PayProcess    = 202,
    
    //支付失败
    FFLPayEnum_PayFail       = 301,
    
    //用户取消了支付
    FFLPayEnum_PayCannel     = 302,
    
    //用户未支付
    FFLPayEnum_PayOut        = 303,
    
    
} FFLPayEnumPayState;

#endif /* FFLPayHeader_h */
