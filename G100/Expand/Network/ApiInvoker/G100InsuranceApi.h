//
//  G100InsuranceApi.h
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Api.h"

@interface G100InsuranceApi : NSObject

+ (instancetype)sharedInstance;

/**
 查询保险活动列表
 
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)queryInsuranceActivity:(API_CALLBACK)callback;

/**
 查询首页卡片所有保险活动列表
 
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)queryAllInsuranceActivityWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 查询我的保险所有保险活动列表
 
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)queryMyInsuranceActivity:(API_CALLBACK)callback;

/**
 查询保险提示

 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)queryInsurancePrompt:(API_CALLBACK)callback;

/**
 查询可免费领取保险列表

 @param userid 用户id
 @param bikeid 车辆id
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)queryInsuranceFreeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;

/**
 查询特定用户的保险保单

 @param userid 用户id
 @param status 保单状态 [0无 1保障中 2审核中 3报案期 4丢车理赔中 5已赔付 6已作废 7将到期 8已过期 9待领取 10待支付]
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)queryInsuranceOrderWithUserid:(NSString *)userid status:(NSArray <NSNumber *> *)status callback:(API_CALLBACK)callback;

/**
 *  保险订单支付完成
 *
 *  @param  orderid     订单编号
 *  @param  callback    接口回调
 */
-(ApiRequest *)insurancePayFinishedWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback;

/**
 *  查询保单详细情况
 *
 *  @param  orderid     订单编号（只有完成的保险订单才有意义）
 *  @param  callback    接口回调
 */
-(ApiRequest *)checkInsuranceOrderDetailWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback;

/**
 *  查询特定用户的各种保险信息
 *
 *  @param  userid      用户id    可选  管理员使用 用户忽略
 *  @param  callback    接口回调
 */
-(ApiRequest *)queryInsuranceStatusWithUserid:(NSString *)userid callback:(API_CALLBACK)callback;

@end
