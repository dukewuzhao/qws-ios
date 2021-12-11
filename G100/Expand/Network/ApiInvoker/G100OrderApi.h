//
//  G100OrderApi.h
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"

@interface G100OrderApi : NSObject

+(instancetype) sharedInstance;

/**
 *  查询我的订单
 *
 *  @param callback   接口回调
 */
-(ApiRequest *)loadMyorderWithCallback:(API_CALLBACK)callback;

/**
 *  提交订单
 *
 *  @param  devid       设备号
 *  @param  productid   产品编号    NSInteger
 *  @param  unitprice   单价       CGFloat
 *  @param  amount      数量       NSInteger
 *  @param  discount    折扣       CGFloat
 *  @param  coupon      优惠券 
 *  @param  price       总价
 *  @param  insurance   保险相关
 *  {
         "channel" : "pingan"      渠道
         "name": "zhangsan"      姓名
         "gender" : "1"     性别 1男 2女
         "idtype" : "01"      证件类型 01身份证
         "idno"  : "qwfjlasf"  证件号码
         "birthday" : "2010-01-01"   生日
         "pn" : "123423"   手机号码
     }
 *  @param  callback    接口回调
 */
-(ApiRequest *)submitOrderWithDevid:(NSString *)devid
                  productid:(NSInteger)productid
                  unitprice:(CGFloat)unitprice
                     amount:(NSInteger)amount
                   discount:(CGFloat)discount
                     coupon:(NSString *)coupon
                      price:(CGFloat)price
                  insurance:(NSDictionary *)insurance
                   callback:(API_CALLBACK)callback;

/**
 *  服务订单支付完成
 *
 *  @param  orderid     订单编号
 *  @param  callback    接口回调
 */
-(ApiRequest *)servicePayFinishedWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback;

/**
 *  取消订单
 *
 *  @param orderid      订单编号
 *  @param callback     接口回调
 */
-(ApiRequest *)cancelOrderWithOrderid:(NSInteger)orderid callback:(API_CALLBACK)callback;

/**
 *  提交订单 V2.0
 *
 *  @param  devid       设备号
 *  @param  productid   产品编号    NSInteger
 *  @param  unitprice   单价       CGFloat
 *  @param  amount      数量       NSInteger
 *  @param  discount    折扣       CGFloat
 *  @param  coupon      优惠券
 *  @param  price       总价
 *  @param  insurance   保险相关
 *  {
         "channel" : "pingan"      渠道
         "name": "zhangsan"      姓名
         "gender" : "1"     性别 1男 2女
         "idtype" : "01"      证件类型 01身份证
         "idno"  : "qwfjlasf"  证件号码
         "birthday" : "2010-01-01"   生日
         "pn" : "123423"   手机号码
     }
 *  @param  callback    接口回调
 */
-(ApiRequest *)sv_submitOrderWithBikeid:(NSString *)bikeid
                          devid:(NSString *)devid
                      productid:(NSInteger)productid
                      unitprice:(CGFloat)unitprice
                         amount:(NSInteger)amount
                       discount:(CGFloat)discount
                         coupon:(NSString *)coupon
                          price:(CGFloat)price
                      insurance:(NSDictionary *)insurance
                       callback:(API_CALLBACK)callback;

/**
 根据订单id获取订单详情
 
 @param orderid 订单id
 @param callback 回调
 @return
 */
- (ApiRequest *)getOrderDetailWithOrder_id:(NSInteger)orderid callback:(API_CALLBACK)callback;

@end
