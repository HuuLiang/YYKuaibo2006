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
#define YYK_REST_APP_ID          @"QUBA_2006"
#define YYK_REST_PV              @190
#define YYK_PAYMENT_PV           @214
#define YYK_PACKAGE_CERTIFICATE  @"iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd."
#define YYK_PAYMENT_RESERVE_DATA [NSString stringWithFormat:@"%@$%@", YYK_REST_APP_ID, YYK_CHANNEL_NO]

#define YYK_BASE_URL             @"http://iv.ihuiyx.com"//@"http://120.24.252.114:8093" //
#define YYK_UMENG_APP_ID         @"56e653d767e58e0eb7002156"

#define YYK_HOME_VIDEO_URL              @"/iosvideo/homePage.htm"
//#define YYK_VIDEO_LIB_URL               @"/iosvideo/hotVideo.htm"
#define YYK_HOT_VIDEO_URL               @"/iosvideo/hotFilm.htm"
#define YYK_VIDEO_DETAIL_URL            @"/iosvideo/detailssl.htm"

#define YYK_CHANNEL_URL                 @"/iosvideo/channelRanking.htm"
#define YYK_CHANNEL_PROGRAM_URL         @"/iosvideo/program.htm"

#define YYK_VIP_CHANNEL_URL             @"/iosvideo/channel.htm"
#define YYK_VIP_VIDEO_URL               @"/iosvideo/vipvideo.htm"
#define YYK_APP_SPREAD_LIST_URL         @"/iosvideo/appSpreadList.htm"
#define YYK_APP_SPREAD_BANNER_URL       @"/iosvideo/appSpreadBanner.htm"

#define YYK_HOT_TAG_URL                 @"/iosvideo/hotTag.htm"
#define YYK_SEARCH_URL                  @"/iosvideo/search.htm"

#define YYK_ACTIVATE_URL                @"/iosvideo/activat.htm"
#define YYK_SYSTEM_CONFIG_URL           @"/iosvideo/systemConfig.htm"
#define YYK_USER_ACCESS_URL             @"/iosvideo/userAccess.htm"
#define YYK_AGREEMENT_NOTPAID_URL       @"/iosvideo/agreement.html"
#define YYK_AGREEMENT_PAID_URL          @"/iosvideo/agreement-paid.html"

#define YYK_VERSION_UPDATE_URL          @"http://channel.iqu8.cn/channel/versionCheck.htm" //@"http://120.24.252.114:8095/channel/versionCheck.htm" //

#define YYK_STATS_BASE_URL              @"http://stats.iqu8.cn"
#define YYK_STATS_CPC_URL               @"/stats/cpcs.service"
#define YYK_STATS_TAB_URL               @"/stats/tabStat.service"
#define YYK_STATS_PAY_URL               @"/stats/payRes.service"

#define YYK_PAYMENT_COMMIT_URL          @"http://pay.iqu8.net/paycenter/qubaPr.json" //@"http://120.24.252.114:8084/paycenter/qubaPr.json" //
#define YYK_PAYMENT_CONFIG_URL          @"http://pay.iqu8.net/paycenter/appPayConfig.json"//@"http://120.24.252.114:8084/paycenter/appPayConfig.json"//
#define YYK_STANDBY_PAYMENT_CONFIG_URL  @"http://appcdn.mqu8.com/static/iosvideo/payConfig_%@.json"
#define YYK_ORDER_QUERY_URL             @"http://phas.ihuiyx.com/pd-has/successOrderIds.json"
#define YYK_PAYMENT_SIGN_KEY            @"qdge^%$#@(sdwHs^&"
#define YYK_PAYMENT_ENCRYPTION_PASSWORD @"wdnxs&*@#!*qb)*&qiang"

#define YYK_STANDBY_BASE_URL                @"http://appcdn.mqu8.com"
#define YYK_STANDBY_HOME_VIDEO_URL          @"/static/iosvideo/homePage.json"

//#define YYK_STANDBY_VIDEO_LIB_URL           @"/static/iosvideo/hotVideo.json"
#define YYK_STANDBY_HOT_VIDEO_URL           @"/static/iosvideo/hotFilm.json"
#define YYK_STANDBY_VIP_VIDEO_URL           @"/static/iosvideo/vipvideo.json"
#define YYK_STANDBY_CHANNEL_URL             @"/static/iosvideo/channelRanking.json"
#define YYK_STANDBY_CHANNEL_PROGRAM_URL     @"/static/iosvideo/program_%@_%@.json"
#define YYK_STANDBY_APP_SPREAD_LIST_URL     @"/static/iosvideo/appSpreadList.json"
#define YYK_STANDBY_APP_SPREAD_BANNER_URL   @"/static/iosvideo/appSpreadBanner.json"
#define YYK_STANDBY_SYSTEM_CONFIG_URL       @"/static/iosvideo/systemConfig.json"
#define YYK_STANDBY_AGREEMENT_NOTPAID_URL   @"/static/iosvideo/agreement.html"
#define YYK_STANDBY_AGREEMENT_PAID_URL      @"/static/iosvideo/agreement-paid.html"

#define YYK_SYSTEM_CONFIG_PAY_AMOUNT            @"PAY_AMOUNT"
#define YYK_SYSTEM_CONFIG_SVIP_PAY_AMOUNT       @"SVIP_PAY_AMOUNT"
#define YYK_SYSTEM_CONFIG_ORIGINAL_PAY_AMOUNT   @"ORIGINAL_PAY_AMOUNT"
#define YYK_SYSTEM_CONFIG_ORIGINAL_SVIP_PAY_AMOUNT @"ORIGINAL_SVIP_PAY_AMOUNT"
#define YYK_SYSTEM_CONFIG_ALLVIP_PAY_AMOUNT     @"ALL_VIP_PAY_AMOUNT"
//#define YYK_SYSTEM_CONFIG_CONTACT               @"CONTACT"
#define YYK_SYSTEM_CONFIG_CONTACT_NAME          @"CONTACT_NAME"
#define YYK_SYSTEM_CONFIG_CONTACT_TIME          @"CONTACT_TIME"
#define YYK_SYSTEM_CONFIG_CONTACT_SCHEME        @"CONTACT_SCHEME"
#define YYK_SYSTEM_CONFIG_PAY_IMG               @"PAY_IMG"
#define YYK_SYSTEM_CONFIG_SVIP_PAY_IMG          @"SVIP_PAY_IMG"
#define YYK_SYSTEM_CONFIG_DISCOUNT_IMG          @"DISCOUNT_IMG"
#define YYK_SYSTEM_CONFIG_PAYMENT_TOP_IMAGE     @"CHANNEL_TOP_IMG"
#define YYK_SYSTEM_CONFIG_STARTUP_INSTALL       @"START_INSTALL"
#define YYK_SYSTEM_CONFIG_SPREAD_TOP_IMAGE      @"SPREAD_TOP_IMG"
#define YYK_SYSTEM_CONFIG_SPREAD_URL            @"SPREAD_URL"
#define YYK_SYSTEM_CONFIG_STATS_TIME_INTERVAL   @"STATS_TIME_INTERVAL"
#define YYK_SYSTEM_CONFIG_H5_REGION             @"H5_REGION"
//价格区间
#define YYK_SYSTEM_CONFIG_PRICE_MIN @"PAY_AMOUNT_RANGE_MIN"
#define YYK_SYSTEM_CONFIG_PRICE_MAX @"PAY_AMOUNT_RANGE_MAX"
#define YYK_SYSTEM_CONFIG_PRICE_EXCLUDE @"PAY_AMOUNT_RANGE_EXCLUDE"
//SVIP价格区间
#define YYK_SYSTEM_CONFIG_SVIPPRICE_MIN @"SVIP_PAY_AMOUNT_RANGE_MIN"
#define YYK_SYSTEM_CONFIG_SVIPPRICE_MAX @"SVIP_PAY_AMOUNT_RANGE_MAX"
#define YYK_SYSTEM_CONFIG_SVIPPRICE_EXCLUDE @"SVIP_PAY_AMOUNT_RANGE_EXCLUDE"

#define YYK_SYSTEM_CONFIG_ALLVIP_PRICE_MIN @"ALL_VIP_PAY_AMOUNT_RANGE_MIN"
#define YYK_SYSTEM_CONFIG_ALLVIP_PRICE_MAX @"ALL_VIP_PAY_AMOUNT_RANGE_MAX"
#define YYK_SYSTEM_CONFIG_ALLVIP_EXCLUDE    @"ALL_VIP_PAY_AMOUNT_RANGE_EXCLUDE"

//#define YYK_SYSTEM_CONFIG_HALF_PAY_SEQ          @"HALF_PAY_LAUNCH_SEQ"
//#define YYK_SYSTEM_CONFIG_HALF_PAY_DELAY        @"HALF_PAY_LAUNCH_DELAY"
//#define YYK_SYSTEM_CONFIG_HALF_PAY_NOTIFICATION @"HALF_PAY_LAUNCH_NOTIFICATION"
//#define YYK_SYSTEM_CONFIG_HALF_PAY_NOTI_REPEAT_TIMES @"HALF_PAY_NOTI_REPEAT_TIMES"

#define YYK_SYSTEM_CONFIG_DISCOUNT_AMOUNT               @"DISCOUNT_AMOUNT"
#define YYK_SYSTEM_CONFIG_DISCOUNT_LAUNCH_SEQ           @"DISCOUNT_LAUNCH_SEQ"
#define YYK_SYSTEM_CONFIG_NOTIFICATION_LAUNCH_SEQ       @"NOTIFICATION_LAUNCH_SEQ"
#define YYK_SYSTEM_CONFIG_NOTIFICATION_BACKGROUND_DELAY @"NOTIFICATION_BACKGROUND_DELAY"
#define YYK_SYSTEM_CONFIG_NOTIFICATION_TEXT             @"NOTIFICATION_TEXT"
#define YYK_SYSTEM_CONFIG_NOTIFICATION_REPEAT_TIMES     @"NOTIFICATION_REPEAT_TIMES"

#define YYK_IAPPPAY_PLUGIN_TYPE                 (1009)
#endif /* YYKConfig_h */
