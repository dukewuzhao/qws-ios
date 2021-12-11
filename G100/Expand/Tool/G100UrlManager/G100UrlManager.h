//
//  G100UrlManager.h
//  G100
//
//  Created by 曹晓雨 on 2016/11/16.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kWebUrlReleaseHost      @"https://appwebv2.360qws.cn"
#define kWebUrlTestHost         @"https://appweb.d.360qws.cn"
#define kWebUrlHost             ISProduct ? kWebUrlReleaseHost : kWebUrlTestHost

#define kWebMapUrlReleaseHost   @"https://lbs.360qws.cn"
#define kWebMapUrlTestHost      @"https://lbs.d.360qws.cn"
#define kWebMapUrlHost          ISProduct ? kWebMapUrlReleaseHost : kWebMapUrlTestHost

@interface G100UrlManager : NSObject

+ (instancetype)sharedInstance;

/**
 寻车提示

 @param bikeid 车辆id
 @param devid 设备id
 @return 
 */
- (NSString *)getFindCarTipsUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

/**
 盗抢险保险条款

 @param orderid 订单号
 @return 
 */
- (NSString *)getThiefInsurancePolicyUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid;

/**
 盗抢险用户告知

 @param orderid 订单号
 @return
 */
- (NSString *)getThiefInsuranceUsersInformedUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid;

/**
 
 盗抢险详情
 @param orderid 订单号
 @return
 */
- (NSString *)getThiefInsuranceDetailsUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid;

/**
 盗抢险理赔流程

 @param orderid 订单号
 @return
 */
- (NSString *)getThiefInsuranceClaimsDataAndProcessesUrlWithUserid:(NSString *)userid orderid:(NSString *)orderid;

/**
 盗抢险审核中

 @param devid 设备id
 @param orderid 订单号
 @param bikeid 车辆id
 @return
 */
- (NSString *)getThiefInsuranceDataReviewUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid orderid:(NSString *)orderid devid:(NSString *)devid;
/**
 App报警测试帮助页面

 @return
 */
- (NSString *)getAppAlarmHelpUrl;

/**
 微信报警帮助页面

 @return
 */
- (NSString *)getWeChatAlarmHelpUrl;

/**
 电话报警帮助页面

 @return
 */
- (NSString *)getPhoneAlarmHelpUrl;

/**
 微信报警协议

 @param preview 是否预览
 @return
 */
- (NSString *)getWeChatAlarmProtocolUrl:(int)preview;

/**
 电话报警协议

 @param preview 是否预览
 @return
 */
- (NSString *)getPhoneAlarmProtocolUrl:(NSInteger)preview;

/**
  远程锁车功能说明

 @param bikeid 车辆id
 @param devid 设备id
 @return 
 */
- (NSString *)getRemoteLockCarUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid;

/**
 获取电池电压

 @param isMaster 是否是主管理
 @return 
 */
- (NSString *)getBatteryAndVoltageUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid isMaster:(NSString *)isMaster devid:(NSString *)devid model_id:(NSInteger)model_id;


/**
 获取电池电压
 
 @param userid uid
 @param bikeid bikeid
 @param isMaster 主管理否
 @param devid devid
 @param battvol 电压
 @param comdays 使用天数
 @return 
 */
- (NSString *)getBatteryAndVoltageUrlWithUserid:(NSString *)userid bikeid:(NSString *)bikeid isMaster:(NSString *)isMaster devid:(NSString *)devid battvol:(int)battvol comdays:(int)comdays;
/**
 报警器帮助页面

 @param sn 设备SN号
 @return
 */
- (NSString *)getFunctionAlarmUrlWithSn:(NSString *)sn;

/**
 绑定FAQ页面

 @return
 */
- (NSString *)getBindCommonFAQWithUserid:(NSString *)userid devid:(NSString *)devid locmodeltype:(NSString *)locmodeltype;

/**
 智能电池帮助界面

 @return 
 */
- (NSString *)getMsgsHelp;

/**
 2.0 保单详情页面

 @param userid 用户id
 @param bikeid 车辆id
 @param orderid 订单号
 @return 页面url
 */
- (NSString *)getInsuranceOrderDetailWithUserid:(NSString *)userid bikeid:(NSString *)bikeid orderid:(NSString *)orderid;

/**
 2.0 行业地图服务
 
 @param type 店铺类型 0是所有列表 3是充电，5是打气，1是维修，9是救援
 @return 页面url
 */
- (NSString *)getMapServiceDetailWithUserid:(NSString *)userid type:(NSString *)type;

/**
 帮助页面

 @param anchor 跳转到帮助界面中具体某个label   (按顺序从1-8，盗抢险是9，售后是10)
 @param mtid 设备类型 model_type_id
 @param mid  设备类型 model_id
 @return
 */
- (NSString *)getHelpWithAnchor:(NSString *)anchor mid:(NSInteger)mid mtid:(NSInteger)mtid;

/**
 理赔流程页面
 
 @param userid 用户id
 @return
 */
- (NSString *)getClaimProcessUrlWithUserid:(NSString *)userid;

/**
 获取用户购买服务连接
 
 @param userid 用户id
 @param bikeid 车辆id
 @param devid 设备id
 @param type  1.保险 2.服务
 @param productid 指定商品 如果没有不加这个参数
 @return
 */
- (NSString *)getServicePayWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid type:(int)type productid:(NSString *)productid;

/**
 获取支付后结果连接
 
 @param userid uid
 @param orderid 订单id
 @param result 结果 success 成功 fail 失败
 @param code code 0 成功 1取消 2未知错误
 @return
 */
- (NSString *)getPayResultWithUserid:(NSString *)userid orderid:(NSString *)orderid result:(NSString *)result code:(int)code;

@end
