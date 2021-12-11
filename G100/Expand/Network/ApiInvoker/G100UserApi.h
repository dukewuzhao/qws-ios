//
//  G100UserApi.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"

typedef enum : NSUInteger {
    G100VerificationCodeUsageDefault = 0,//!<默认
    G100VerificationCodeUsageToRegister, //!< 注册
    G100VerificationCodeUsageToFindPw, //!< 找回密码
    G100VerificationCodeUsageToChangePn, //!< 更改手机
    G100VerificationCodeUsageToLogin    //!< 登录
} G100VerificationCodeUsage;

@interface G100UserApi : NSObject

+(instancetype) sharedInstance;

/**
 *  检查用户token有效性
 *
 *  @param token    旧token
 *  @param devid    手机唯一编号
 *  @paran callback 接口回调
 */
-(ApiRequest *)validateTokenWithToken:(NSString *)token devid:(NSString *)devid callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_validateTokenWithToken:token devid:devid callback:callback");

/**
 *  用户登录历史查询
 *
 *  @param token    旧token
 *  @param userid   用户id    普通用户必须忽略，管理员必填
 *  @paran callback 接口回调
 */
-(ApiRequest *)userLoginHistoryWithUserid:(NSString *)userid callback:(API_CALLBACK)callback;

/**
 *  登录
 *
 *  @param loginName 用户名
 *  @param password  密码
 *  @param partner  三方登录途径
 *  @param partneraccount   三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param logintrigger 登录方式触发  0 用户触发  1 APP触发
 *  @param partneruseruid   三方帐号用户id
 *  @param partnerappid     三方平台对应的appid 0骑卫士应用 1三方平台内部应用 2骑卫士web
 *  @param callback  接口回调
 */
-(ApiRequest *) loginUserWithLoginName:(NSString *)loginName
                   andPassword:(NSString *)password
                       puserid:(NSString *)puserid
                    pchannelid:(NSString *)pchannelid
                       partner:(NSString *)partner
                partneraccount:(NSString *)partneraccount
           partneraccounttoken:(NSString *)partneraccounttoken
                partneruseruid:(NSString *)partneruseruid
                  logintrigger:(NSInteger)logintrigger
                      callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use -sv_loginUserWithLoginName:andPassword:partner:partneraccount:partneraccounttoken:partneruseruid:logintrigger:picurl:picid:inputbar:sessionid:usage:callback:");

/**
 *  登录
 *
 *  @param loginName           用户名
 *  @param password            密码
 *  @param puserid             push userid
 *  @param pchannelid          push channelid
 *  @param partner             三方登录途径
 *  @param partneraccount      三方帐号
 *  @param partneraccounttoken 三方帐号临时密码
 *  @param partneruseruid      三方帐号用户的唯一id(为其他系统接入使用，如微信的unionid)
 *  @param logintrigger        登录方式触发  0 用户触发  1 APP触发
 *  @param picvc               图像验证码
 *  @param sessionid           图像验证码url后面的sessionid参数值
 *  @param callback            接口回调
 */
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
                      callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use -sv_loginUserWithLoginName:andPassword:partner:partneraccount:partneraccounttoken:partneruseruid:logintrigger:picurl:picid:inputbar:sessionid:usage:callback:");

/**
 *  上传push
 *
 *  @param puserid     用户id
 *  @param pchannelid  渠道id
 *  @param pushchannel 推送渠道
 *  @param devid       默认系统信息
 *  @param callback    接口回调
 */
-(ApiRequest *) pushRemoteNotificationInstallWithPuserid:(NSString *)puserid
                                   andPchannelid:(NSString *)pchannelid
                                     pushchannel:(NSString *)pushchannel
                                        callback:(API_CALLBACK)callback;

/**
 *  退出登录
 *
 *  @param callback 接口回调
 */
-(ApiRequest *) logoutWithCallback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_logoutWithCallback:callback");

/**
 *  注册用户
 *
 *  @param mobile   手机号码
 *  @param password 密码
 *  @param vcode    验证码
 *  @param partner  三方登录途径
 *  @param partneraccount   三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param partneruseruid   三方帐号用户id
 *  @param partnerappid     三方平台对应的appid 0骑卫士应用 1三方平台内部应用 2骑卫士web
 *  @param callback 接口回调
 */
-(ApiRequest *)registerUserWithMobile:(NSString *)mobile
                     password:(NSString *)password
                        vcode:(NSString *)vcode
                      partner:(NSString *)partner
               partneraccount:(NSString *)partneraccount
          partneraccounttoken:(NSString *)partneraccounttoken
               partneruseruid:(NSString *)partneruseruid
                     callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_registerUserWithMobile:password:vcode:partner:partneraccount:partneraccounttoken:partneruseruid:callback:");

/**
 *  检查三方帐号是否已注册过
 *  
 *  @param partner              三方登录途径
 *  @param partneraccount       三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param partneruseruid   三方帐号用户id
 *  @param callback             接口回调
 */
-(ApiRequest *)checkThirdAccountWithpPartner:(NSString *)partner
                      partneraccount:(NSString *)partneraccount
                 partneraccounttoken:(NSString *)partneraccounttoken
                      partneruseruid:(NSString *)partneruseruid
                            callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_checkThirdAccountWithpPartner:partner partneraccount:partneraccount partneraccounttoken:partneraccounttoken partneruseruid:partneruseruid callback:callback");
/**
 *  检查手机号是否绑定登录渠道
 *  
 *  @param  partner 三方登录途径
 *  @param  pn      三方帐号
 *  @param  callback    接口回调
 */

-(ApiRequest *)checkPhoneNumIsBindtWithpPartner:(NSString *)partner
                                     pn:(NSString *)pn
                               callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_checkPhoneNumIsBindtWithpPartner:partner pn:pn callback:callback");

/**
 *  获取用户的第三方帐号关系 （token即可）
 *  
 *  @param  callback    接口回调
 */
-(ApiRequest *)getPartnerRelationWithCallback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_getPartnerRelationWithCallback:callback");

/**
 *  用户解除与第三方帐号的关系
 *
 *  @param  partner         三方登录类型
 *  @param  partnerAccount  三方登录帐号
 *  @param  callback        接口回调
 */
-(ApiRequest *)unbindPartnerRelationWithPartner:(NSString *)partner
                         partnerAccount:(NSString *)partnerAccount
                               callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_unbindPartnerRelationWithPartner:partner partnerAccount:partnerAccount callback:callback");

/**
 *  用户绑定三方帐号关系
 *
 *  @param partner              三方登录途径
 *  @param partneraccount       三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param partneruseruid       三方帐号用户id
 *  @param partnerappid         三方平台对应的appid 0骑卫士应用 1三方平台内部应用 2骑卫士web
 *  @param callback             接口回调
 */
-(ApiRequest *)bindPartnerRelationPartner:(NSString *)partner
                   partneraccount:(NSString *)partneraccount
              partneraccounttoken:(NSString *)partneraccounttoken
                   partneruseruid:(NSString *)partneruseruid
                         callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_bindPartnerRelationPartner:partner partneraccount:partneraccount callback:callback");

/**
 *  检查手机号是否注册(1.0)
 *
 *  @param  mobile   手机号码
 *  @param  callback 接口回调
 */
-(ApiRequest *) checkPhoneNumberisRegisterWithMobile:(NSString *)mobile callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_checkPhoneNumberisRegisterWithMobile:mobile callback:callback");

/**
 *  请求短信验证码
 *  
 *  @param  mobile   手机号码
 *  @param  callback 接口回调
 */
-(ApiRequest *) requestSmsVerificationWithMobile:(NSString *)mobile callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_requestSmsVerificationWithMobile:mobile PictureCaptcha:pictureCaptcha callback:callback");

/**
 *  核对验证码
 *
 *  @param  mobile   手机号码
 *  @param  vcode    验证码
 *  @param  callback 接口回调
 */
-(ApiRequest *) checkVerificationCodeWithMobile:(NSString *)mobile
                                  vcode:(NSString *)vcode
                               callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_checkVerificationCodeWithMobile:mobile vcode:vcode callback:callback");

/**
 *  查询用户信息
 *  
 *  @param  userid   用户id数组
 *  @param  callback 接口回调
 */
-(ApiRequest *) queryUserinfoWithUserid:(NSArray *)userid callback:(API_CALLBACK)callback;

/**
 *  更新用户资料
 *
 *  @param  userinfo    用户信息    字典形式
 *  @param  callback    接口回调
 */
-(ApiRequest *) updateUserdataWithUserinfo:(NSDictionary *)userinfo callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_updateUserdataWithUserinfo:userinfo callback:callback");

/**
 *  修改用户密码
 *  
 *  @param  currpwd  旧密码
 *  @param  newpwd   新密码
 *  @param  callback 接口回调
 */

-(ApiRequest *) modifyUserPasswordWithCurrpwd:(NSString *)currpwd
                               newpwd:(NSString *)newpwd
                             callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_modifyUserPasswordWithCurrpwd:currpwd newpwd:newpwd callback:callback");

/**
 *  重置用户密码
 *
 *  @param  mobile   手机号
 *  @param  vcode    验证码
 *  @param  newpwd   新密码
 *  @param  callback 接口回调
 */
-(ApiRequest *)resetUserPasswordWithMobile:(NSString *)mobile
                             vcode:(NSString *)vcode
                            newpwd:(NSString *)newpwd
                          callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_resetUserPasswordWithMobile:mobile vcode:vcode newpwd:newpwd callback:callback");

/**
 *  修改手机号码
 *
 *  @param  oldvc    旧验证码
 *  @param  newpn    新手机号
 *  @param  newvc    新验证码
 *  @param  callback 接口回调
 */
-(ApiRequest *)modifyMobileNumberWithOldvc:(NSString *)oldvc
                            newpn:(NSString *)newpn
                            newvc:(NSString *)newvc
                          callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_modifyMobileNumberWithOldvc:oldvc newpn:newpn newvc:newvc callback:callback");

/**
 *  检查软件版本  从官网
 *  
 *  @param  platform    平台  A android I ios
 *  @param  channel     渠道：0 通用版 1 某某专用版 2 ...
 *  @param  version     版本号
 *  @param  callback    接口对调
 */
-(ApiRequest *)checkUpdateWithPlatform:(NSString *)platform
                       channel:(NSString *)channel
                       version:(NSString *)version
                      callback:(API_CALLBACK)callback;

/**
 *  获取页面提示信息
 *
 *  @param page     页面名称
 *  @param channel  渠道
 *  @param callback 接口回调
 */
-(ApiRequest *)getPagePromptInfoWithPage:(NSString *)page
                         channel:(NSString *)channel
                        callback:(API_CALLBACK)callback;

/**
 *  获取app启动页面
 *
 *  @param devid    手机唯一id
 *  @param devname  手机型号
 *  @param devos    手机系统版本
 *  @param location 定位位置
 *  @param callback 接口回调
 */
- (ApiRequest *)getStartupPageWithLocation:(NSString *)location callback:(API_CALLBACK)callback;

/**
 *  上传用户的位置信息
 *
 *  @param location 用户位置信息 字典形式
 *  @param callback 接口回调
 */
- (ApiRequest *)uploadUserlocationWithLocation:(NSDictionary *)location callback:(API_CALLBACK)callback;

/**
 *  上报用户对链接分享的结果
 *
 *  @param eventid  事件编号
 *  @param shareto  1 微信    2 朋友圈   3 QQ    4 QQ空间  5 新浪微博
 *  @param result   分享结果 0 取消   1 成功
 *  @param callback 接口回调
 */
- (ApiRequest *)uploadSocialShareResultWithEventid:(NSInteger)eventid
                                   shareto:(NSInteger)shareto
                                    result:(NSInteger)result
                                  callback:(API_CALLBACK)callback;

/**
 *  检查当前的活动
 *  @param callback 接口回调
 */
- (ApiRequest *)checkCurrentEventWithCallback:(API_CALLBACK)callback;
/**
 *  检查当前车辆的活动
 *
 *  @param bikeid   车辆id
 *  @param callback 接口回调
 */
- (ApiRequest *)checkCurrentEventWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;
/**
 *  检查当前设备的活动
 *
 *  @param bikeid   车辆id
 *  @param devid    设备id
 *  @param callback 接口回调
 */
- (ApiRequest *)checkCurrentEventWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback;
/**
 *  获取分享信息
 *
 *  @param shareid  分享id
 *  @param callback 接口回调
 */
- (ApiRequest *)getShareWithShareid:(NSInteger)shareid callback:(API_CALLBACK )callback;

/**
 *  请求短信验证码
 *
 *  @param mobile    手机号码
 *  @param picvc     图像验证码，可选
 *  @param sessionid 图像验证码url后面的sessionid参数值
 *  @param usage     用途 1注册 2找回密码 3更换手机
 *  @param callback  接口回调
 */
- (ApiRequest *) requestSmsVerificationWithMobile:(NSString *)mobile picvc:(NSString *)picvc sessionid:(NSString *)sessionid usage:(G100VerificationCodeUsage)usage callback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_requestSmsVerificationWithMobile:mobile PictureCaptcha:pictureCaptcha callback:callback");

/**
 *  申请图像验证码
 *
 *  @param usage    用途 1注册 2找回密码 3更换手机
 *  @param callback 接口回调
 */
- (ApiRequest *) requestPicvcVerificationWithUsage:(G100VerificationCodeUsage)usage callback:(API_CALLBACK)callback;
/**
 *  检查是否关注骑卫士微信公众号
 *
 *  @param callback 接口回调
 */
- (ApiRequest *) checkWxmpWithCallback:(API_CALLBACK)callback G100Deprecated("2.0 建议使用 Use - sv_checkWxmpWithCallback:callback");


                        /*                         2.0接口
                         ########################################################################
                         ########################################################################
                         ########################################################################
                         */

/**
 *  检查手机号是否注册(2.0)
 *
 *  @param mobilePhone 手机号码
 *  @param callback    接口回调
 */
-(ApiRequest *) sv_checkPhoneNumberisRegisterWithMobile:(NSString *)mobile callback:(API_CALLBACK)callback;

/**
 *  注册用户 (2.0)
 *
 *  @param mobile   手机号码
 *  @param password 密码
 *  @param vcode    验证码
 *  @param partner  三方登录途径
 *  @param partneraccount   三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param partneruseruid   三方帐号用户id
 *  @param partnerappid     三方平台对应的appid 0骑卫士应用 1三方平台内部应用 2骑卫士web
 *  @param callback 接口回调
 */
-(ApiRequest *)sv_registerUserWithMobile:(NSString *)mobile
                     password:(NSString *)password
                        vcode:(NSString *)vcode
                      partner:(NSString *)partner
               partneraccount:(NSString *)partneraccount
          partneraccounttoken:(NSString *)partneraccounttoken
               partneruseruid:(NSString *)partneruseruid
                     callback:(API_CALLBACK)callback;

/**
 *  检查用户token有效性
 *
 *  @param token    旧token
 *  @param devid    手机唯一编号
 *  @paran callback 接口回调
 */
-(ApiRequest *)sv_validateTokenWithToken:(NSString *)token devid:(NSString *)devid callback:(API_CALLBACK)callback;

/**
 *  登录
 *
 *  @param loginName           用户名
 *  @param password            密码
 *  @param puserid             push userid
 *  @param pchannelid          push channelid
 *  @param partner             三方登录途径
 *  @param partneraccount      三方帐号
 *  @param partneraccounttoken 三方帐号临时密码
 *  @param partneruseruid      三方帐号用户的唯一id(为其他系统接入使用，如微信的unionid)
 *  @param logintrigger        登录方式触发  0 用户触发  1 APP触发
 *  @param picvc               图像验证码
 *  @param sessionid           图像验证码url后面的sessionid参数值
 *  @param callback            接口回调
 */
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
                      callback:(API_CALLBACK)callback;

/**
 *  检查手机号是否绑定登录渠道
 *
 *  @param  partner 三方登录途径
 *  @param  pn      三方帐号
 *  @param  callback    接口回调
 */
-(ApiRequest *)sv_checkPhoneNumIsBindtWithpPartner:(NSString *)partner
                                     pn:(NSString *)pn
                               callback:(API_CALLBACK)callback;

/**
 *  检查三方帐号是否已注册过
 *
 *  @param partner              三方登录途径
 *  @param partneraccount       三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param partneruseruid   三方帐号用户id
 *  @param callback             接口回调
 */
-(ApiRequest *)sv_checkThirdAccountWithpPartner:(NSString *)partner
                      partneraccount:(NSString *)partneraccount
                 partneraccounttoken:(NSString *)partneraccounttoken
                      partneruseruid:(NSString *)partneruseruid
                            callback:(API_CALLBACK)callback;

/**
 *  检查是否关注骑卫士微信公众号
 *
 *  @param callback 接口回调
 */
- (ApiRequest *) sv_checkWxmpWithCallback:(API_CALLBACK)callback;

/**
 *  退出登录
 *
 *  @param callback 接口回调
 */
-(ApiRequest *) sv_logoutWithCallback:(API_CALLBACK)callback;

/**
 *  请求短信验证码
 *
 *  @param mobile    手机号码
 *  @param picvc     图像验证码，可选
 *  @param sessionid 图像验证码url后面的sessionid参数值
 *  @param usage     用途 1注册 2找回密码 3更换手机
 *  @param callback  接口回调
 */
- (ApiRequest *) sv_requestSmsVerificationWithMobile:(NSString *)mobile PictureCaptcha:(NSDictionary *)pictureCaptcha callback:(API_CALLBACK)callback;

/**
 *  请求语音验证码
 *
 *  @param mobile    手机号码
 *  @param picvc     图像验证码，可选
 *  @param callback  接口回调
 */
- (ApiRequest *) sv_requestVoiVerificationWithMobile:(NSString *)mobile PictureCaptcha:(NSDictionary *)pictureCaptcha callback:(API_CALLBACK)callback;

/**
 *  核对验证码
 *
 *  @param  mobile   手机号码
 *  @param  vcode    验证码
 *  @param  callback 接口回调
 */
-(ApiRequest *) sv_checkVerificationCodeWithMobile:(NSString *)mobile
                                  vcode:(NSString *)vcode
                               callback:(API_CALLBACK)callback;

/**
 *  申请图像验证码
 *
 *  @param usage    用途 1注册 2找回密码 3更换手机
 *  @param callback 接口回调
 */
- (ApiRequest *) sv_requestPicvcVerificationWithUsage:(G100VerificationCodeUsage)usage callback:(API_CALLBACK)callback;

/**
 *  更新用户资料
 *
 *  @param  userinfo    用户信息    字典形式
 *  @param  callback    接口回调
 */
-(ApiRequest *) sv_updateUserdataWithUserinfo:(NSDictionary *)userinfo callback:(API_CALLBACK)callback;

/**
 *  修改用户密码
 *
 *  @param  currpwd  旧密码
 *  @param  newpwd   新密码
 *  @param  callback 接口回调
 */

-(ApiRequest *) sv_modifyUserPasswordWithCurrpwd:(NSString *)currpwd
                               newpwd:(NSString *)newpwd
                             callback:(API_CALLBACK)callback;

/**
 *  重置用户密码
 *
 *  @param  mobile   手机号
 *  @param  vcode    验证码
 *  @param  newpwd   新密码
 *  @param  callback 接口回调
 */
-(ApiRequest *)sv_resetUserPasswordWithMobile:(NSString *)mobile
                             vcode:(NSString *)vcode
                            newpwd:(NSString *)newpwd
                          callback:(API_CALLBACK)callback;

/**
 *  修改手机号码
 *
 *  @param  oldvc    旧验证码
 *  @param  newpn    新手机号
 *  @param  newvc    新验证码
 *  @param  callback 接口回调
 */
-(ApiRequest *)sv_modifyMobileNumberWithOldvc:(NSString *)oldvc
                             newpn:(NSString *)newpn
                             newvc:(NSString *)newvc
                          callback:(API_CALLBACK)callback;

/**
 *  获取用户的第三方帐号关系 （token即可）
 *
 *  @param  callback    接口回调
 */
-(ApiRequest *)sv_getPartnerRelationWithCallback:(API_CALLBACK)callback;

/**
 *  用户解除与第三方帐号的关系
 *
 *  @param  partner         三方登录类型
 *  @param  partnerAccount  三方登录帐号
 *  @param  callback        接口回调
 */
-(ApiRequest *)sv_unbindPartnerRelationWithPartner:(NSString *)partner
                         partnerAccount:(NSString *)partnerAccount
                              partnertoken:(NSString *)partnertoken
                          partner_user_uid:(NSString *)partner_user_uid
                               callback:(API_CALLBACK)callback;

/**
 *  用户绑定三方帐号关系
 *
 *  @param partner              三方登录途径
 *  @param partneraccount       三方帐号
 *  @param partneraccounttoken  三方帐号临时密码
 *  @param partneruseruid       三方帐号用户id
 *  @param partnerappid         三方平台对应的appid 0骑卫士应用 1三方平台内部应用 2骑卫士web
 *  @param callback             接口回调
 */
-(ApiRequest *)sv_bindPartnerRelationPartner:(NSString *)partner
                   partneraccount:(NSString *)partneraccount
                        partnertoken:(NSString *)partnertoken
                        partner_user_uid:(NSString *)partner_user_uid
                         callback:(API_CALLBACK)callback;

/**
 *   备注副用户

 @param userid 被备注的用户id
 @param bikeid 备注的车辆id
 @param comment 备注内容
 @return 接口回调
 */
-(ApiRequest *)sv_commentUserWithUserid:(NSString *)userid
                                 bikeid:(NSString *)bikeid
                                 comment:(NSString *)comment
                                 callback:(API_CALLBACK)callback;

/**
 *   设置家的位置
 
 @param userid 设置家的用户id
 @param longi 家的经度
 @param lati 家的纬度
 @param address 家的详细地址
 @return 接口回调
 */
-(ApiRequest *)sv_addUserHomeWithUserid:(NSString *)userid
                                 longi:(CGFloat)longi
                                 lati:(CGFloat)lati
                                address:(NSString *)address
                               callback:(API_CALLBACK)callback;
@end
