//
//  G100UrlManager.m
//  G100
//
//  Created by 曹晓雨 on 2016/11/16.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100UrlManager.h"

@implementation G100UrlManager

+ (instancetype)sharedInstance {
    static G100UrlManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[G100UrlManager alloc]init];
    });
    return manager;
}

- (NSString *)getFindCarTipsUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid
{
    NSString *url = [NSString stringWithFormat:@"%@/lost/tips", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&devid=%@&bikeid=%@", userid, devid, bikeid]] mutableCopy];
    return url;
}

- (NSString *)getThiefInsurancePolicyUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid
{
    NSString *url = [NSString stringWithFormat:@"%@/notice/clause.html", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&orderid=%@", userid, orderid]] mutableCopy];
    return url;
}

- (NSString *)getThiefInsuranceUsersInformedUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid
{
    NSString *url = [NSString stringWithFormat:@"%@/notice/userinformed.html", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&orderid=%@", userid, orderid]] mutableCopy];
    return  url;
}

- (NSString *)getThiefInsuranceDetailsUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid
{
    NSString *url = [NSString stringWithFormat:@"%@/notice/policy.html", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&orderid=%@", userid, orderid]] mutableCopy];
    return url;
}

- (NSString *)getThiefInsuranceClaimsDataAndProcessesUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid
{
    NSString *url = [NSString stringWithFormat:@"%@/notice/claimprocess.html", kWebUrlHost];
     url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&orderid=%@", userid, orderid]] mutableCopy];
    return url;
}

- (NSString *)getThiefInsuranceDataReviewUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid orderid:(NSString *)orderid devid:(NSString *)devid
{
    NSString *url = [NSString stringWithFormat:@"%@/insurance/review", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&devid=%@&orderid=%@&bikeid=%@", userid, devid, orderid, bikeid]] mutableCopy];
    return url;
}

- (NSString *)getAppAlarmHelpUrl
{
    return [NSString stringWithFormat:@"%@/alarm/app_help.html", kWebUrlHost];
}

- (NSString *)getWeChatAlarmHelpUrl
{
    return [NSString stringWithFormat:@"%@/alarm/weixin_help.html", kWebUrlHost];
}

- (NSString *)getPhoneAlarmHelpUrl
{
    return [NSString stringWithFormat:@"%@/alarm/phone_help.html", kWebUrlHost];
}

- (NSString *)getWeChatAlarmProtocolUrl:(int)preview
{
    NSString *url = [NSString stringWithFormat:@"%@/alarm/weixin_alarm.html", kWebUrlHost];
    if (preview) {
        url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"preview=%@", @(preview)]] mutableCopy];
    }
    return url;
}

- (NSString *)getPhoneAlarmProtocolUrl:(NSInteger)preview
{
    NSString *url = [NSString stringWithFormat:@"%@/alarm/phone_alarm.html", kWebUrlHost];
    if (preview) {
        url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"preview=%@", @(preview)]] mutableCopy];
    }
    return url;
}

- (NSString *)getRemoteLockCarUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid
{
    NSString *url = [NSString stringWithFormat:@"%@/g500/deslock", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&devid=%@&bikeid=%@", userid, devid, bikeid]] mutableCopy];
    return url;
}

- (NSString *)getBatteryAndVoltageUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid isMaster:(NSString *)isMaster devid:(NSString *)devid model_id:(NSInteger)model_id
{
    NSString *url = [NSString stringWithFormat:@"%@/battdetail", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&ismaster=%@&bikeid=%@&devid=%@&model_id=%@", userid, isMaster, bikeid, devid, @(model_id)]] mutableCopy];
    return url;
}
- (NSString *)getBatteryAndVoltageUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid isMaster:(NSString *)isMaster devid:(NSString *)devid battvol:(int)battvol comdays:(int)comdays
{
    NSString *url = [NSString stringWithFormat:@"%@/battdetail", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&ismaster=%@&bikeid=%@&devid=%@battvol=%@comdays=%@", userid, isMaster, bikeid, devid, @(battvol), @(comdays)]] mutableCopy];
    return url;
}

- (NSString *)getFunctionAlarmUrlWithSn:(NSString *)sn
{
    NSString *url =  @"https://m.qiweishi.com/aboutalertor.html";
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"sn=%@",sn]] mutableCopy];
    return url;
}

- (NSString *)getBindCommonFAQWithUserid:(NSString *)userid devid:(NSString *)devid locmodeltype:(NSString *)locmodeltype
{
    NSString *url = @"https://m.qiweishi.com/ub.html";
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&devid=%@&locmodeltype=%@", userid, devid, locmodeltype]] mutableCopy];
    return url;
}
- (NSString *)getMsgsHelp
{
    NSString *url = [NSString stringWithFormat:@"%@/msgs/help.html", kWebUrlHost];
    return url;
}

- (NSString *)getInsuranceOrderDetailWithUserid:(NSString *)userid bikeid:(NSString *)bikeid orderid:(NSString *)orderid {
    NSString *url = [NSString stringWithFormat:@"%@/insurancev2/policy", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&bikeid=%@&orderid=%@", userid, bikeid, orderid]] mutableCopy];
    return url;
}

- (NSString *)getMapServiceDetailWithUserid:(NSString *)userid type:(NSString *)type{
    NSString *url = [NSString stringWithFormat:@"%@/lbs/storelist", kWebMapUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&type=%@",userid,type]] mutableCopy];
    return url;
}

- (NSString *)getHelpWithAnchor:(NSString *)anchor mid:(NSInteger)mid mtid:(NSInteger)mtid
{
    NSString *url = @"https://m.qiweishi.com/service";
       url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"mid=%ld&mtid=%ld&anchor=%@", (long)mid,(long)mtid, anchor]] mutableCopy];
    return url;
}

- (NSString *)getClaimProcessUrlWithUserid:(NSString *)userid{
    NSString *url = [NSString stringWithFormat:@"%@/insurance/claim", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@", userid]] mutableCopy];
    return url;
}

- (NSString *)getServicePayWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid type:(int)type productid:(NSString *)productid{
    NSString *url = [NSString stringWithFormat:@"%@/flow/renew", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&type=%d", userid,type]] mutableCopy];
    if (bikeid.length) {
        url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"&bikeid=%@", bikeid]] mutableCopy];
    }
    if (devid.length) {
        url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"&devid=%@", devid]] mutableCopy];
    }
    if (productid) {
        url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"&productid=%@", productid]] mutableCopy];
    }
    return url;
}

- (NSString *)getPayResultWithUserid:(NSString *)userid orderid:(NSString *)orderid result:(NSString *)result code:(int)code {
    NSString *url = [NSString stringWithFormat:@"%@/flow/payresult", kWebUrlHost];
    url = [[url appendUrlWithParamter:[NSString stringWithFormat:@"userid=%@&orderid=%@&result=%@&code=%d", userid, orderid, result, code]] mutableCopy];
    return url;
}

@end
