//
//  G100UserApi.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100UserApi.h"

@implementation G100UserApi

+(instancetype) sharedInstance {
    static G100UserApi *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(ApiRequest *)validateTokenWithToken:(NSString *)token devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"token" : EMPTY_IF_NIL(token), @"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"user/validatetoken" andRequest:request token:NO callback:callback];
}
-(ApiRequest *)userLoginHistoryWithUserid:(NSString *)userid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"userid" : EMPTY_IF_NIL(userid)}];
    return [G100ApiHelper postApi:@"app/userloginhis" andRequest:request token:YES callback:callback];
}
-(ApiRequest *)loginUserWithLoginName:(NSString *)loginName
                  andPassword:(NSString *)password
                      puserid:(NSString *)puserid
                   pchannelid:(NSString *)pchannelid
                      partner:(NSString *)partner
               partneraccount:(NSString *)partneraccount
          partneraccounttoken:(NSString *)partneraccounttoken
               partneruseruid:(NSString *)partneruseruid
                 logintrigger:(NSInteger)logintrigger
                     callback:(API_CALLBACK)callback {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [NSString stringWithFormat:@"V%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"pn" : EMPTY_IF_NIL(loginName),
                                                           @"pw" : EMPTY_IF_NIL(password),
                                                           @"devid" : EMPTY_IF_NIL(DeviceAndOSInfo),
                                                           @"channel" : !ISProduct ? @"BETA_A001" : @"APPS_A001",
                                                           @"appversion" : EMPTY_IF_NIL(app_Version),
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partneraccount" : EMPTY_IF_NIL(partneraccount),
                                                           @"partneraccounttoken" : EMPTY_IF_NIL(partneraccounttoken),
                                                           @"puserid" : EMPTY_IF_NIL(puserid),
                                                           @"pchannelid" : EMPTY_IF_NIL(pchannelid),
                                                           @"accesstype" : @"APP",
                                                           @"logintrigger" : [NSNumber numberWithInteger:logintrigger],
                                                           @"partneruseruid" : EMPTY_IF_NIL(partneruseruid),
                                                           @"partnerappid" : [NSNumber numberWithInteger:0]
                                                           }];
    
    return [G100ApiHelper postApi:@"app/login" andRequest:request token:NO https:YES callback:callback];
}

-(ApiRequest *) loginUserWithLoginName:(NSString *)loginName
                   andPassword:(NSString *)password
                       puserid:(NSString *)puserid
                    pchannelid:(NSString *)pchannelid
                       partner:(NSString *)partner
                partneraccount:(NSString *)partneraccount
           partneraccounttoken:(NSString *)partneraccounttoken
                partneruseruid:(NSString *)partneruseruid
                  logintrigger:(NSInteger)logintrigger
                         picvc:(NSString *)picvc
                     sessionid:(NSString *)sessionid
                      callback:(API_CALLBACK)callback {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [NSString stringWithFormat:@"V%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"pn" : EMPTY_IF_NIL(loginName),
                                                           @"pw" : EMPTY_IF_NIL(password),
                                                           @"devid" : EMPTY_IF_NIL(DeviceAndOSInfo),
                                                           @"channel" : !ISProduct ? @"BETA_A001" : @"APPS_A001",
                                                           @"appversion" : EMPTY_IF_NIL(app_Version),
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partneraccount" : EMPTY_IF_NIL(partneraccount),
                                                           @"partneraccounttoken" : EMPTY_IF_NIL(partneraccounttoken),
                                                           @"puserid" : EMPTY_IF_NIL(puserid),
                                                           @"pchannelid" : EMPTY_IF_NIL(pchannelid),
                                                           @"accesstype" : @"APP",
                                                           @"logintrigger" : [NSNumber numberWithInteger:logintrigger],
                                                           @"partneruseruid" : EMPTY_IF_NIL(partneruseruid),
                                                           @"partnerappid" : [NSNumber numberWithInteger:0],
                                                           @"picvc" : EMPTY_IF_NIL(picvc),
                                                           @"sessionid" : EMPTY_IF_NIL(sessionid)
                                                           }];
    
    return [G100ApiHelper postApi:@"user/login" andRequest:request token:NO https:YES callback:callback];
}

-(ApiRequest *)pushRemoteNotificationInstallWithPuserid:(NSString *)puserid
                                  andPchannelid:(NSString *)pchannelid
                                    pushchannel:(NSString *)pushchannel
                                       callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"puserid" : EMPTY_IF_NIL(puserid),
                                                           @"pchannelid" : EMPTY_IF_NIL(pchannelid),
                                                           @"pushchannel" : EMPTY_IF_NIL(pushchannel),
                                                           @"devid" : EMPTY_IF_NIL(DeviceAndOSInfo)}];
    return [G100ApiHelper postApi:@"user/postpush" andRequest:request callback:callback];
}

-(ApiRequest *)logoutWithCallback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(DeviceAndOSInfo)}];
    return [G100ApiHelper postApi:@"user/logout" andRequest:request callback:callback];
}

-(ApiRequest *)registerUserWithMobile:(NSString *)mobile
                     password:(NSString *)password
                        vcode:(NSString *)vcode
                      partner:(NSString *)partner
               partneraccount:(NSString *)partneraccount
          partneraccounttoken:(NSString *)partneraccounttoken
               partneruseruid:(NSString *)partneruseruid
                     callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"pn" : EMPTY_IF_NIL(mobile),
                                                           @"pw" : EMPTY_IF_NIL(password),
                                                           @"vc" : EMPTY_IF_NIL(vcode),
                                                           @"devid" : EMPTY_IF_NIL(DeviceAndOSInfo),
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partneraccount" : EMPTY_IF_NIL(partneraccount),
                                                           @"partneraccounttoken" : EMPTY_IF_NIL(partneraccounttoken),
                                                           @"partneruseruid" : EMPTY_IF_NIL(partneruseruid),
                                                           @"partnerappid" : [NSNumber numberWithInt:0]
                                                           }];
    return [G100ApiHelper postApi:@"app/register" andRequest:request token:NO https:YES callback:callback];
}

-(ApiRequest *)checkThirdAccountWithpPartner:(NSString *)partner
                      partneraccount:(NSString *)partneraccount
                 partneraccounttoken:(NSString *)partneraccounttoken
                      partneruseruid:(NSString *)partneruseruid
                            callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partneraccount" : EMPTY_IF_NIL(partneraccount),
                                                           @"partneraccounttoken" : EMPTY_IF_NIL(partneraccounttoken),
                                                           @"partneruseruid" : EMPTY_IF_NIL(partneruseruid)
                                                           }];
    return [G100ApiHelper postApi:@"app/checktpa" andRequest:request token:NO callback:callback];
}

/**
 *  检查手机号是否绑定登录渠道
 *
 *  @param  partner 三方登录途径
 *  @param  pn      三方帐号
 *  @param  callback    接口回调
 */

-(ApiRequest *)checkPhoneNumIsBindtWithpPartner:(NSString *)partner
                                     pn:(NSString *)pn
                               callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"pn" : EMPTY_IF_NIL(pn),
                                                           }];
    return [G100ApiHelper postApi:@"app/checkphonetp" andRequest:request token:NO callback:callback];
}

/**
 *  获取用户的第三方帐号关系 （token即可）
 *
 *  @param  callback    接口回调
 */
-(ApiRequest *)getPartnerRelationWithCallback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"app/getpartnerrelation" andRequest:request callback:callback];
}

/**
 *  用户解除与第三方帐号的关系
 *
 *  @param  partner         三方登录类型
 *  @param  partnerAccount  三方登录帐号
 *  @param  callback        接口回调
 */
-(ApiRequest *)unbindPartnerRelationWithPartner:(NSString *)partner
                         partnerAccount:(NSString *)partnerAccount
                               callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partnerAccount" : EMPTY_IF_NIL(partnerAccount)
                                                           }];
    return [G100ApiHelper postApi:@"app/unbindpartnerrelation" andRequest:request callback:callback];
}

/**
 *  用户绑定三方帐号关系
 *
 *  @param partner              三方登录途径
 *  @param partneraccount       三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param callback             接口回调
 */
-(ApiRequest *)bindPartnerRelationPartner:(NSString *)partner
                   partneraccount:(NSString *)partneraccount
              partneraccounttoken:(NSString *)partneraccounttoken
                   partneruseruid:(NSString *)partneruseruid
                         callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partneraccount" : EMPTY_IF_NIL(partneraccount),
                                                           @"partneraccounttoken" : EMPTY_IF_NIL(partneraccounttoken),
                                                           @"partneruseruid" : EMPTY_IF_NIL(partneruseruid),
                                                           @"partnerappid" : [NSNumber numberWithInteger:0]
                                                           }];
    return [G100ApiHelper postApi:@"app/bindpartnerrelation" andRequest:request callback:callback];
}

-(ApiRequest *)checkPhoneNumberisRegisterWithMobile:(NSString *)mobile callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"pn" : EMPTY_IF_NIL(mobile)}];
    return [G100ApiHelper postApi:@"app/checkpn" andRequest:request callback:callback];
}

-(ApiRequest *)requestSmsVerificationWithMobile:(NSString *)mobile callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"pn" : EMPTY_IF_NIL(mobile)}];
    return [G100ApiHelper postApi:@"app/requestvc" andRequest:request callback:callback];
}

-(ApiRequest *)checkVerificationCodeWithMobile:(NSString *)mobile
                                vcode:(NSString *)vcode
                             callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"pn" : EMPTY_IF_NIL(mobile),
                                                            @"vc" : EMPTY_IF_NIL(vcode)
                                                            }];
    return [G100ApiHelper postApi:@"app/validatevc" andRequest:request token:NO callback:callback];
}

-(ApiRequest *)queryUserinfoWithUserid:(NSArray *)userid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"userid" : EMPTY_IF_NIL(userid)}];
    return [G100ApiHelper postApi:@"user/getuserinfo" andRequest:request callback:callback];
}

-(ApiRequest *)updateUserdataWithUserinfo:(NSDictionary *)userinfo callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:userinfo];
    return [G100ApiHelper postApi:@"user/updateprofile" andRequest:request callback:callback];
}

-(ApiRequest *)modifyUserPasswordWithCurrpwd:(NSString *)currpwd
                              newpwd:(NSString *)newpwd
                            callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"currpwd" : EMPTY_IF_NIL(currpwd),
                                                            @"newpwd" : EMPTY_IF_NIL(newpwd)
                                                            }];
    return [G100ApiHelper postApi:@"app/changepassword" andRequest:request token:YES https:YES callback:callback];
}

-(ApiRequest *)resetUserPasswordWithMobile:(NSString *)mobile
                             vcode:(NSString *)vcode
                            newpwd:(NSString *)newpwd
                          callback:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"pn" : EMPTY_IF_NIL(mobile),
                                                            @"vc" : EMPTY_IF_NIL(vcode),
                                                            @"newpwd" : EMPTY_IF_NIL(newpwd)
                                                            }];
    return [G100ApiHelper postApi:@"app/resetpassword" andRequest:request token:YES https:YES callback:callback];
}

-(ApiRequest *)modifyMobileNumberWithOldvc:(NSString *)oldvc
                             newpn:(NSString *)newpn
                             newvc:(NSString *)newvc
                          callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"oldvc" : EMPTY_IF_NIL(oldvc),
                                                            @"newpn" : EMPTY_IF_NIL(newpn),
                                                            @"newvc" : EMPTY_IF_NIL(newvc)
                                                            }];
    return [G100ApiHelper postApi:@"app/changephone" andRequest:request callback:callback];
}

-(ApiRequest *)checkUpdateWithPlatform:(NSString *)platform
                       channel:(NSString *)channel
                       version:(NSString *)version
                      callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"platform" : EMPTY_IF_NIL(platform),
                                                            @"channel" : EMPTY_IF_NIL(channel),
                                                            @"version" : EMPTY_IF_NIL(version)
                                                            }];
    return [G100ApiHelper postApi:@"app/checkupdate" andRequest:request callback:callback];
}

-(ApiRequest *)getPagePromptInfoWithPage:(NSString *)page
                         channel:(NSString *)channel
                        callback:(API_CALLBACK)callback {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"platform" : @"I",
                                                            @"page" : EMPTY_IF_NIL(page),
                                                            @"channel" : EMPTY_IF_NIL(channel),
                                                            @"version" : EMPTY_IF_NIL(version)
                                                            }];
    return [G100ApiHelper postApi:@"app/getpageprompt" andRequest:request callback:callback];
}

- (ApiRequest *)getStartupPageWithLocation:(NSString *)location callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(DeviceAndOSInfo),
                                                           @"devname" : EMPTY_IF_NIL([DeviceManager platform]),
                                                           @"devos" : EMPTY_IF_NIL([DeviceManager osInfo]),
                                                           @"channel" : !ISProduct ? @"BETA_A001" : @"APPS_A001",
                                                           @"location" : EMPTY_IF_NIL(location)
                                                           }];
    return [G100ApiHelper postApi:@"app/startuppage" andRequest:request callback:callback];
}

- (ApiRequest *)uploadUserlocationWithLocation:(NSDictionary *)location callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(DeviceAndOSInfo),
                                                           @"location" : EMPTY_IF_NIL(location)
                                                           }];
    return [G100ApiHelper postApi:@"app/userlocation" andRequest:request callback:callback];
}

- (ApiRequest *)uploadSocialShareResultWithEventid:(NSInteger)eventid
                                   shareto:(NSInteger)shareto
                                    result:(NSInteger)result
                                  callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"eventid" : [NSNumber numberWithInteger:eventid],
                                                           @"shareto" : [NSNumber numberWithInteger:shareto],
                                                           @"result" : [NSNumber numberWithInteger:result]
                                                           }];
    return [G100ApiHelper postApi:@"app/socialshareresult" andRequest:request callback:callback];
}

- (ApiRequest *)checkCurrentEventWithCallback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"app/checkevent" andRequest:request callback:callback];
}

- (ApiRequest *)checkCurrentEventWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]]}];
    return [G100ApiHelper postApi:@"app/checkevent" andRequest:request callback:callback];
}

- (ApiRequest *)checkCurrentEventWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                           @"device_id" : [NSNumber numberWithInteger:[devid integerValue]]}];
    return [G100ApiHelper postApi:@"app/checkevent" andRequest:request callback:callback];
}

- (ApiRequest *)getShareWithShareid:(NSInteger)shareid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"shareid" : [NSNumber numberWithInteger:shareid]}];
    return [G100ApiHelper postApi:@"social/getshare" andRequest:request callback:callback];
}

- (ApiRequest *) requestSmsVerificationWithMobile:(NSString *)mobile picvc:(NSString *)picvc sessionid:(NSString *)sessionid usage:(G100VerificationCodeUsage)usage callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"pn" : EMPTY_IF_NIL(mobile),
                                                           @"picvc" : EMPTY_IF_NIL(picvc),
                                                           @"sessionid" : EMPTY_IF_NIL(sessionid),
                                                           @"usage" : [NSNumber numberWithInteger:usage]}];
    return [G100ApiHelper postApi:@"app/requestvc" andRequest:request callback:callback];
}

- (ApiRequest *) requestPicvcVerificationWithUsage:(G100VerificationCodeUsage)usage callback:(API_CALLBACK)callback {
    NSInteger requestutc = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSString *token = [[NSString stringWithFormat:@"360QWS%@PICVC", @(requestutc)] stringFromMD5];
    
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"token" : EMPTY_IF_NIL(token),
                                                           @"requestutc" : [NSNumber numberWithInteger:requestutc],
                                                           @"usage" : [NSNumber numberWithInteger:usage]}];
    // 不使用token 自定义一个token
    return [G100ApiHelper postApi:@"app/requestpicvc" andRequest:request token:NO callback:callback];
}

- (ApiRequest *) checkWxmpWithCallback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"app/checkwxmp" andRequest:request callback:callback];
}
               /*                         2.0接口实现
                  ########################################################################
                  ########################################################################
                  ########################################################################
                */

#pragma mark - 2.0接口实现
-(ApiRequest *)sv_checkPhoneNumberisRegisterWithMobile:(NSString *)mobile callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"phone_num" : EMPTY_IF_NIL(mobile)}];
    return [G100ApiHelper postApi:@"user/checkpn" andRequest:request callback:callback];
}

-(ApiRequest *)sv_registerUserWithMobile:(NSString *)mobile
                     password:(NSString *)password
                        vcode:(NSString *)vcode
                      partner:(NSString *)partner
               partneraccount:(NSString *)partneraccount
          partneraccounttoken:(NSString *)partneraccounttoken
               partneruseruid:(NSString *)partneruseruid
                     callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"phone_num" : EMPTY_IF_NIL(mobile),
                                                           @"password" : EMPTY_IF_NIL(password),
                                                           @"sms_vc" : EMPTY_IF_NIL(vcode),
                                                           @"partner" :@{
                                                                   @"partner" : EMPTY_IF_NIL(partner),
                                                                   @"partner_account" : EMPTY_IF_NIL(partneraccount),
                                                                   @"partner_account_token" : EMPTY_IF_NIL(partneraccounttoken),
                                                                   @"partner_user_uid" : EMPTY_IF_NIL(partneruseruid)
                                                                   },
                                                           @"access_channel" : [NSNumber numberWithInt:0],
                                                           @"dev_id" : EMPTY_IF_NIL(DeviceAndOSInfo)
                                                           }];
    return [G100ApiHelper postApi:@"user/register" andRequest:request token:NO https:YES callback:callback];
}

-(ApiRequest *)sv_validateTokenWithToken:(NSString *)token devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"token" : EMPTY_IF_NIL(token), @"dev_id" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"user/validatetoken" andRequest:request token:NO callback:callback];
}

-(ApiRequest *) sv_loginUserWithLoginName:(NSString *)loginName
                   andPassword:(NSString *)password
                       partner:(NSString *)partner
                partneraccount:(NSString *)partneraccount
           partneraccounttoken:(NSString *)partneraccounttoken
                partneruseruid:(NSString *)partneruseruid
                  logintrigger:(NSInteger)logintrigger
                           picurl:(NSString *)picurl
                            picid:(NSString *)picid
                         inputbar:(NSString *)inputbar
                        sessionid:(NSString *)sessionid
                            usage:(NSInteger)usage
                      callback:(API_CALLBACK)callback {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [NSString stringWithFormat:@"V%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"phone_num" : EMPTY_IF_NIL(loginName),
                                                           @"password" : EMPTY_IF_NIL(password),
                                                           @"dev_id" : EMPTY_IF_NIL(DeviceAndOSInfo),
                                                           @"channel" : ISInHouse ? @"SALE_A001" : @"APPS_A001",
                                                           @"app_version" : EMPTY_IF_NIL(app_Version),
                                                           @"partner" :@{
                                                                         @"partner" : EMPTY_IF_NIL(partner),
                                                                         @"partner_account" : EMPTY_IF_NIL(partneraccount),
                                                                         @"partner_account_token" : EMPTY_IF_NIL(partneraccounttoken),
                                                                         @"partner_user_uid" : EMPTY_IF_NIL(partneruseruid)
                                                                         },
                                                           @"access_channel" : [NSNumber numberWithInteger:0],
                                                           @"access_type" : @"APP",
                                                           @"login_trigger" : [NSNumber numberWithInteger:logintrigger],
                                                           @"picture_captcha" : @{
                                                                                   @"url" : EMPTY_IF_NIL(picurl),
                                                                                   @"id" : EMPTY_IF_NIL(picid),
                                                                                   @"input" : EMPTY_IF_NIL(inputbar),
                                                                                   @"session_id" : EMPTY_IF_NIL(sessionid),
                                                                                   @"usage" : [NSNumber numberWithInteger:usage]
                                                                                 },
                                                           }];
    
    return [G100ApiHelper postApi:@"user/login" andRequest:request token:NO https:YES callback:callback];
}

-(ApiRequest *)sv_checkPhoneNumIsBindtWithpPartner:(NSString *)partner
                                     pn:(NSString *)pn
                               callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"phone_num" : EMPTY_IF_NIL(pn),
                                                           }];
    return [G100ApiHelper postApi:@"user/checkphonetp" andRequest:request token:NO callback:callback];
}

-(ApiRequest *)sv_checkThirdAccountWithpPartner:(NSString *)partner
                      partneraccount:(NSString *)partneraccount
                 partneraccounttoken:(NSString *)partneraccounttoken
                      partneruseruid:(NSString *)partneruseruid
                            callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partner_account" : EMPTY_IF_NIL(partneraccount),
                                                           @"partner_account_token" : EMPTY_IF_NIL(partneraccounttoken),
                                                           @"partner_user_uid" : EMPTY_IF_NIL(partneruseruid)
                                                           }];
    return [G100ApiHelper postApi:@"user/checktpa" andRequest:request token:NO callback:callback];
}

- (ApiRequest *) sv_checkWxmpWithCallback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"user/checkwxmp" andRequest:request callback:callback];
}

-(ApiRequest *) sv_logoutWithCallback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"dev_id" : EMPTY_IF_NIL(DeviceAndOSInfo)}];
    return [G100ApiHelper postApi:@"user/logout" andRequest:request callback:callback];
}

- (ApiRequest *) sv_requestSmsVerificationWithMobile:(NSString *)mobile PictureCaptcha:(NSDictionary *)pictureCaptcha callback:(API_CALLBACK)callback
{
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] initWithDictionary:pictureCaptcha];
    [requestDic setObject:EMPTY_IF_NIL(mobile) forKey:@"phone_num"];
    [requestDic setObject:[NSNumber numberWithInteger:0] forKey:@"channel"];
    ApiRequest *request = [ApiRequest requestWithBizData:requestDic];
    return [G100ApiHelper postApi:@"user/requestsmsvc" andRequest:request callback:callback];

}

- (ApiRequest *) sv_requestVoiVerificationWithMobile:(NSString *)mobile PictureCaptcha:(NSDictionary *)pictureCaptcha callback:(API_CALLBACK)callback{
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] initWithDictionary:pictureCaptcha];
    [requestDic setObject:EMPTY_IF_NIL(mobile) forKey:@"phone_num"];
    [requestDic setObject:[NSNumber numberWithInteger:1] forKey:@"channel"];

    ApiRequest *request = [ApiRequest requestWithBizData:requestDic];
    return [G100ApiHelper postApi:@"user/requestsmsvc" andRequest:request callback:callback];
}

-(ApiRequest *)sv_checkVerificationCodeWithMobile:(NSString *)mobile
                                 vcode:(NSString *)vcode
                              callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"phone_num" : EMPTY_IF_NIL(mobile),
                                                            @"sms_vc" : EMPTY_IF_NIL(vcode)
                                                            }];
    return [G100ApiHelper postApi:@"user/validatesmsvc" andRequest:request token:NO callback:callback];
}

- (ApiRequest *) sv_requestPicvcVerificationWithUsage:(G100VerificationCodeUsage)usage callback:(API_CALLBACK)callback
{
    NSInteger requestutc = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSString *token = [[NSString stringWithFormat:@"360QWS%@PICVC", @(requestutc)] stringFromMD5];
    
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"token" : EMPTY_IF_NIL(token),
                                                           @"ts" : [NSNumber numberWithInteger:requestutc],
                                                           @"usage" : [NSNumber numberWithInteger:usage]}];
    // 不使用token 自定义一个token
    return [G100ApiHelper postApi:@"user/requestpicvc" andRequest:request token:NO callback:callback];
}

-(ApiRequest *) sv_updateUserdataWithUserinfo:(NSDictionary *)userinfo callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:userinfo];
    return [G100ApiHelper postApi:@"user/updateprofile" andRequest:request callback:callback];
}

-(ApiRequest *) sv_modifyUserPasswordWithCurrpwd:(NSString *)currpwd
                                  newpwd:(NSString *)newpwd
                                callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"current_password" : EMPTY_IF_NIL(currpwd),
                                                            @"new_password" : EMPTY_IF_NIL(newpwd)
                                                            }];
    return [G100ApiHelper postApi:@"user/changepassword" andRequest:request token:YES https:YES callback:callback];
}

-(ApiRequest *)sv_resetUserPasswordWithMobile:(NSString *)mobile
                                vcode:(NSString *)vcode
                               newpwd:(NSString *)newpwd
                             callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"phone_num" : EMPTY_IF_NIL(mobile),
                                                            @"sms_vc" : EMPTY_IF_NIL(vcode),
                                                            @"new_password" : EMPTY_IF_NIL(newpwd)
                                                            }];
    return [G100ApiHelper postApi:@"user/resetpassword" andRequest:request token:YES https:YES callback:callback];
}

-(ApiRequest *)sv_modifyMobileNumberWithOldvc:(NSString *)oldvc
                                newpn:(NSString *)newpn
                                newvc:(NSString *)newvc
                             callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"old_sms_vc" : EMPTY_IF_NIL(oldvc),
                                                            @"phone_num" : EMPTY_IF_NIL(newpn),
                                                            @"new_sms_vc" : EMPTY_IF_NIL(newvc)
                                                            }];
    return [G100ApiHelper postApi:@"user/changephone" andRequest:request callback:callback];
}

-(ApiRequest *)sv_getPartnerRelationWithCallback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"user/getpartnerrelation" andRequest:request callback:callback];
}

-(ApiRequest *)sv_unbindPartnerRelationWithPartner:(NSString *)partner
                            partnerAccount:(NSString *)partnerAccount
                              partnertoken:(NSString *)partnertoken
                          partner_user_uid:(NSString *)partner_user_uid
                                  callback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partner_account" : EMPTY_IF_NIL(partnerAccount),
                                                           @"partner_account_token" : EMPTY_IF_NIL(partnertoken),
                                                           @"partner_user_uid" : EMPTY_IF_NIL(partner_user_uid)
                                                           }];
    return [G100ApiHelper postApi:@"user/unbindpartnerrelation" andRequest:request callback:callback];
}
-(ApiRequest *)sv_bindPartnerRelationPartner:(NSString *)partner
                      partneraccount:(NSString *)partneraccount
                        partnertoken:(NSString *)partnertoken
                    partner_user_uid:(NSString *)partner_user_uid
                            callback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"partner" : EMPTY_IF_NIL(partner),
                                                           @"partner_account" : EMPTY_IF_NIL(partneraccount),
                                                           @"partner_account_token" : EMPTY_IF_NIL(partnertoken),
                                                           @"partner_user_uid" : EMPTY_IF_NIL(partner_user_uid),
                                                           @"access_channel" : [NSNumber numberWithInteger:0]
                                                           }];
    return [G100ApiHelper postApi:@"user/bindpartnerrelation" andRequest:request callback:callback];
}
-(ApiRequest *)sv_commentUserWithUserid:(NSString *)userid
                                 bikeid:(NSString *)bikeid
                                 comment:(NSString *)comment
                                 callback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"userid" : EMPTY_IF_NIL([NSNumber numberWithInteger:[userid integerValue]]),
                                                           @"bikeid" : EMPTY_IF_NIL([NSNumber numberWithInteger:[bikeid integerValue]]),
                                                           @"comment" : EMPTY_IF_NIL(comment)
                                                           }];
    return [G100ApiHelper postApi:@"user/commentuser" andRequest:request callback:callback];

}

-(ApiRequest *)sv_addUserHomeWithUserid:(NSString *)userid
                                  longi:(CGFloat)longi
                                   lati:(CGFloat)lati
                                address:(NSString *)address
                               callback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"lon" : [NSNumber numberWithFloat:longi],
                                                           @"lat" : [NSNumber numberWithFloat:lati],
                                                           @"desc" : EMPTY_IF_NIL(address)
                                                           }];
    return [G100ApiHelper postApi:@"user/sethomelocation" andRequest:request callback:callback];
}

@end
