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
//
//@payInfo   {code:0, msg:xxx, order:xxx}
//    code  参考FFLPayEnumPayState状态码
//    msg   提示字符
//    order 定单详细信息字典(支付成功时返回)

typedef void(^FFLPayFinishBlock) (NSDictionary *payInfo);



//支付模式

//#define __FFLPAY_PAYTYPE_WXSDK     @"wechat_sdk"  //此模式暂停使用 SDK1.0.6

#define __FFLPAY_PAYTYPE_WXAPP     @"wechat_app"


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
