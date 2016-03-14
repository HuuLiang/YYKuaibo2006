//
//  YYKConfig.h
//  YYKuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#ifndef YYKConfig_h
#define YYKConfig_h

#import "YYKConfiguration.h"

#define YYK_CHANNEL_NO           [YYKConfiguration sharedConfig].channelNo
#define YYK_REST_APP_ID          @"QUBA_2004"
#define YYK_REST_PV              @100
#define YYK_PACKAGE_CERTIFICATE  @"iPhone Distribution: Jiangxi Electronic Group Corporation Ltd."

#define YYK_WECHAT_APP_ID        @"wx4af04eb5b3dbfb56"
#define YYK_WECHAT_MCH_ID        @"1281148901"
#define YYK_WECHAT_PRIVATE_KEY   @"hangzhouquba20151112qwertyuiopas"
#define YYK_WECHAT_NOTIFY_URL    @"http://phas.ihuiyx.com/pd-has/notifyWx.json"
#define YYK_UMENG_APP_ID         @"567d010667e58e2c8200223a"
#define YYK_PAYNOW_SCHEME        @"com.jiqingkuaibo.app.paynow.scheme"

#define YYK_BASE_URL             @"http://120.24.252.114:8093" //@"http://iv.ihuiyx.com"//

#define YYK_HOME_VIDEO_URL              @"/iosvideo/homePage.htm"
#define YYK_HOME_CHANNEL_URL            @"/iosvideo/channelRanking.htm"
#define YYK_HOME_CHANNEL_PROGRAM_URL    @"/iosvideo/program.htm"
#define YYK_HOT_VIDEO_URL               @"/iosvideo/hotVideo.htm"
#define YYK_MOVIE_URL                   @"/iosvideo/hotFilm.htm"

#define YYK_ACTIVATE_URL                @"/iosvideo/activat.htm"
#define YYK_SYSTEM_CONFIG_URL           @"/iosvideo/systemConfig.htm"
#define YYK_USER_ACCESS_URL             @"/iosvideo/userAccess.htm"
#define YYK_AGREEMENT_NOTPAID_URL       @"/iosvideo/agreement.html"
#define YYK_AGREEMENT_PAID_URL          @"/iosvideo/agreement-paid.html"

#define YYK_PAYMENT_COMMIT_URL   @"http://pay.iqu8.net/paycenter/qubaPr.json"
#define YYK_PAYMENT_SIGN_URL     @"http://phas.ihuiyx.com/pd-has/signtureNowdata.json"

#define YYK_SYSTEM_CONFIG_PAY_AMOUNT            @"PAY_AMOUNT"
#define YYK_SYSTEM_CONFIG_PAYMENT_TOP_IMAGE     @"CHANNEL_TOP_IMG"
#define YYK_SYSTEM_CONFIG_STARTUP_INSTALL       @"START_INSTALL"
#define YYK_SYSTEM_CONFIG_SPREAD_TOP_IMAGE      @"SPREAD_TOP_IMG"
#define YYK_SYSTEM_CONFIG_SPREAD_URL            @"SPREAD_URL"

#define YYK_SYSTEM_CONFIG_SPREAD_LEFT_IMAGE     @"SPREAD_LEFT_IMG"
#define YYK_SYSTEM_CONFIG_SPREAD_LEFT_URL       @"SPREAD_LEFT_URL"
#define YYK_SYSTEM_CONFIG_SPREAD_RIGHT_IMAGE    @"SPREAD_RIGHT_IMG"
#define YYK_SYSTEM_CONFIG_SPREAD_RIGHT_URL      @"SPREAD_RIGHT_URL"

#endif /* YYKConfig_h */
