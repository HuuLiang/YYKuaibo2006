//
//  HaiTunPay.m
//  HaiTunPay
//
//  Created by TKJF on 16/7/5.
//  Copyright © 2016年 TKJF. All rights reserved.
//

#import "HaiTunPay.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "SPayClient.h"

@implementation HaiTunPay

+ (HaiTunPay *)shareInstance {
    static HaiTunPay *request = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!request) {
            request = [[HaiTunPay alloc]init];
        }
    });
    return request;
}

- (void)requestWithUrl:(NSString *)urlSting viewcontroller:(UIViewController *)viewcontroller requestType:(RequestType)requestType parDic:(NSDictionary *)parDic application:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions finish:(Finish)finish error:(Error)error failure:(Failure)failuer {
    
    self.finish = finish;
    self.error = error;
    self.failure = failuer;
    
    // 判断url
    NSString *phoneRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //判断订单
    NSString *order = @"^[0-9a-zA-Z_]{1,}$";
    NSPredicate *orderTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",order];
    //判断金额
    NSString *regex = @"^[0-9]+(.[0-9]{2})?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (_merId == nil || _merId == NULL || [_merId isKindOfClass:[NSNull class]] || [[_merId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [_merId isEqualToString:@""]) {
        self.failure(@"商户编号不能为空");
        return;
    }else if(![orderTest evaluateWithObject:parDic[@"p2_Order"]]){
        self.failure(@"商户订单号只能是数字字母下划线!");
        return;
    } else if([parDic[@"p2_Order"] length] > 32){
        self.failure(@"商户订单号长度最多32位!");
        return;
    }else if (parDic[@"p3_Amt"] == nil || parDic[@"p3_Amt"] == NULL || [parDic[@"p3_Amt"] isKindOfClass:[NSNull class]] || [[parDic[@"p3_Amt"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [parDic[@"p3_Amt"] isEqualToString:@""]) {
        self.failure(@"订单金额不能为空");
        return;
    }else if (_haiTunPaySignVal == nil || _haiTunPaySignVal == NULL || [_haiTunPaySignVal isKindOfClass:[NSNull class]] || [[_haiTunPaySignVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [_haiTunPaySignVal isEqualToString:@""]) {
        self.failure(@"商户密钥不能为空");
        return;
    }else if(![pred evaluateWithObject:parDic[@"p3_Amt"]]){
        self.failure(@"请输入正确的金额!");
        return;
    }else if (parDic[@"p8_Url"] == nil || parDic[@"p8_Url"] == NULL || [parDic[@"p8_Url"] isKindOfClass:[NSNull class]] || [[parDic[@"p8_Url"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [parDic[@"p8_Url"] isEqualToString:@""]) {
        self.failure(@"商户通知地址不能为空");
        return;
    }else if(![phoneTest evaluateWithObject:parDic[@"p8_Url"]]){
        self.failure(@"商户通知地址格式不正确!");
        return;
    }else {
        
        NSString *p7_Pdesc = parDic[@"p7_Pdesc"];
        /*
         if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
         p7_Pdesc = [parDic[@"p7_Pdesc"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         } else {
         p7_Pdesc = [parDic[@"p7_Pdesc"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
         }
         
         p7_Pdesc = [self utf8ToUnicode:p7_Pdesc];
         */
        NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@",@"Buy",_merId,parDic[@"p2_Order"],parDic[@"p3_Amt"],@"CNY",@"0",@"0",p7_Pdesc,parDic[@"p8_Url"],@"0",@"0",@"gsyh",@"1"];
        //        NSLog(@"%@",str);
        NSString *key =  [self myMD5String:str];
        //        NSLog(@"%@",key);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"Buy" forKey:@"p0_Cmd"];
        [dic setValue:_merId forKey:@"p1_MerId"];
        [dic setValue:parDic[@"p2_Order"] forKey:@"p2_Order"];
        [dic setValue:parDic[@"p3_Amt"] forKey:@"p3_Amt"];
        [dic setValue:@"CNY" forKey:@"p4_Cur"];
        [dic setValue:@"0" forKey:@"p5_Pid"];
        [dic setValue:@"0" forKey:@"p6_Pcat"];
        [dic setValue:parDic[@"p7_Pdesc"] forKey:@"p7_Pdesc"];
        [dic setValue:parDic[@"p8_Url"] forKey:@"p8_Url"];
        [dic setValue:@"0" forKey:@"p9_SAF"];
        [dic setValue:@"0" forKey:@"pa_MP"];
        [dic setValue:@"gsyh" forKey:@"pd_FrpId"];
        [dic setValue:@"1" forKey:@"pr_NeedResponse"];
        if (parDic[@"Sjt_UserName"] == nil || parDic[@"Sjt_UserName"] == NULL || [parDic[@"Sjt_UserName"] isKindOfClass:[NSNull class]] || [[parDic[@"Sjt_UserName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [parDic[@"Sjt_UserName"] isEqualToString:@""]) {
            [dic setValue:@"0" forKey:@"Sjt_UserName"];
        }else {
            [dic setValue:parDic[@"Sjt_UserName"] forKey:@"Sjt_UserName"];
        }
        
        if (_Sjt_Paytype == nil || _Sjt_Paytype == NULL || [_Sjt_Paytype isKindOfClass:[NSNull class]] || [[_Sjt_Paytype stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || [_Sjt_Paytype isEqualToString:@""]) {
            self.Sjt_Paytype = [NSString stringWithFormat:@"%@",@"b"];
            [dic setValue:_Sjt_Paytype forKey:@"Sjt_Paytype"];
        }else {
            [dic setValue:_Sjt_Paytype forKey:@"Sjt_Paytype"];
        }
        
        [dic setObject:key forKey:@"hmac"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlSting]];
        if (requestType == RequestTypePOST) {
            [request setHTTPMethod:@"POST"];
            if (dic.count != 0) {
                [request setHTTPBody:[self dicToDataWithDic:dic]];
            }
        }
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                self.error(error);
            } dispatch_async(dispatch_get_main_queue(), ^{
                self.finish(data);
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(dic) {
                    if ([dic[@"error"] intValue] == 9999) {
                        
                          SPayClientWechatConfigModel *wechatConfigModel = [[SPayClientWechatConfigModel alloc] init];
                          wechatConfigModel.appScheme = dic[@"appid"];
                          wechatConfigModel.wechatAppid = dic[@"appid"];
//                        NSLog(@"%@",dic[@"appid"]);
////                        //配置微信APP支付
                          [[SPayClient sharedInstance] wechatpPayConfig:wechatConfigModel];
                          [[SPayClient sharedInstance] application:application
                                                     didFinishLaunchingWithOptions:launchOptions];
                        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:dic[@"message"]]];
                        //if (!isSwift) {
                        
                        //调起SPaySDK支付
                        [[SPayClient sharedInstance] pay:viewcontroller
                                                  amount:parDic[@"p3_Amt"]
                                       spayTokenIDString:dic[@"message"]
                                       payServicesString:@"pay.weixin.app"
                                                  finish:^(SPayClientPayStateModel *payStateModel,
                                                           SPayClientPaySuccessDetailModel *paySuccessDetailModel) {
                                                      
                                                      if (payStateModel.payState == SPayClientConstEnumPaySuccess) {
                                                          self.failure([NSString stringWithFormat:@"%u",payStateModel.payState]);
                                                          //NSLog(@"支付成功");
                                                          //NSLog(@"支付订单详情-->>\n%@",[paySuccessDetailModel description]);
                                                      }else{
                                                          self.failure([NSString stringWithFormat:@"%u",payStateModel.payState]);
                                                          //NSLog(@"支付失败，错误号:%d",payStateModel.payState);
                                                      }
                                                      
                                                  }];
                        
                        /*
                         }else{
                         
                         [viewcontroller swiftlyPay:parDic[@"p3_Amt"] spayTokenIDString:dic[@"message"] payServicesString:@"pay.weixin.app"];
                         
                         };
                         
                         }*/
                    } else {
                        self.failure([NSString stringWithFormat:@"%d",[dic[@"error"] intValue]]);
                    }
                }else {
                    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                    self.failure(result);
                }
                
            });
        }];
        [task resume];
        
        
    }
    
}

- (NSData *)dicToDataWithDic:(NSDictionary *)dic{
    //把字典里的简直对按照 Key＝Value 拼接成字符串，最后用&符号连接所有拼接好的字符串
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in dic) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", key, dic[key]];
        [array addObject:string];
    }
    NSString *dataString = [array componentsJoinedByString:@"&"];
    return [dataString dataUsingEncoding:NSUTF8StringEncoding];
}
/*
//订单状态查询
- (void)requestWithUrl:(NSString *)urlSting requestType:(RequestType)requestType parDic:(NSDictionary *)parDic finish:(Finish)finish error:(Error)error result:(Result)result;
//查询订单信息方法
- (void)requestWithUrl:(NSString *)urlSting requestType:(RequestType)requestType parDic:(NSDictionary *)parDic finish:(Finish)finish error:(Error)error result:(Result)result{
    self.finish = finish;
    self.error = error;
    self.result = result;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlSting]];
    if (requestType == RequestTypePOST) {
        [request setHTTPMethod:@"POST"];
        if (parDic.count != 0) {
            [request setHTTPBody:[self dicToDataWithDic:parDic]];
        }
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            
            self.error(error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.finish(data);
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.result(dic[@"status"]);
                
            });
        }
    }];
    [task resume];
    
}
*/
//
-(instancetype)initWithHaiTunPaySignVal:(NSString *)haiTunPaySignVal haiTunPayBaseUrl:(NSString *)haiTunPayBaseUrl merId:(NSString *)merId  Sjt_Paytype:(NSString *)Sjt_Paytype{
    self = [super init];
    if (self) {
        self.haiTunPaySignVal = haiTunPaySignVal;
        self.haiTunPayBaseUrl = haiTunPayBaseUrl;
        self.merId = merId;
        self.Sjt_Paytype = Sjt_Paytype;
    }
    return self;
}

+ (instancetype)RequestManagerWithHaiTunPaySignVal:(NSString *)haiTunPaySignVal haiTunPayBaseUrl:(NSString *)haiTunPayBaseUrl merId:(NSString *)merId Sjt_Paytype:(NSString *)Sjt_Paytype {
    
    return [[HaiTunPay shareInstance] initWithHaiTunPaySignVal:haiTunPaySignVal haiTunPayBaseUrl:haiTunPayBaseUrl merId:merId  Sjt_Paytype:Sjt_Paytype];
    
}
//转码
- (NSString *)utf8ToUnicode:(NSString *)string {
    NSUInteger length = [string length];
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    for (int i = 0;i < length; i++) {
        unichar _char = [string characterAtIndex:i];
        //判断是否为英文和数字
        if (_char <= '9' && _char >='0') {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
        }else if(_char >='a' && _char <= 'z') {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
        }else if(_char >='A' && _char <= 'Z') {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
        } else {
            [s appendFormat:@"\\u%x",[string characterAtIndex:i]];
        }
    }
    return s;
}
#pragma mark - 加密方法
- (NSString *)myMD5String:(NSString *)string
{
    NSString *str = [NSString stringWithFormat:@"%@%@", string, self.haiTunPaySignVal];
    
    return [self MD5String:str];
}

#pragma mark 使用MD5加密字符串
- (NSString *)MD5String:(NSString *)srcString
{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, strlen(cStr), digest);
    //    CC_MD5( cStr, (CC_LONG)self.length, digest );
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

@end
