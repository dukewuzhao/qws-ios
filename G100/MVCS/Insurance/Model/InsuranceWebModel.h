//
//  InsuranceWebModel.h
//  G100
//
//  Created by Tilink on 15/4/27.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface InsuranceWebModel : G100BaseDomain

/** 车辆名称 */
@property (copy, nonatomic) NSString * bike_name;
/** 设备名称*/
@property (copy, nonatomic) NSString * device_name;
/** 创建时间 */
@property (copy, nonatomic) NSString * created_time;
/** 订单号 */
@property (assign, nonatomic) NSInteger order_id;
/** 订单类型 */
@property (assign, nonatomic) NSInteger order_type;
/** 平安支付网址 */
@property (copy, nonatomic) NSString * pay_url;
/** 保险价格 */
@property (assign, nonatomic) CGFloat price;
/** 产品名称 */
@property (copy, nonatomic) NSString * product_name;
/** 服务日期 */
@property (copy, nonatomic) NSString * service_end_date;
/** 服务时长 月 */
@property (assign, nonatomic) NSInteger service_months;
/** 订单状态 */
@property (copy, nonatomic) NSString * status;
/** 请求者id */
@property (assign, nonatomic) NSInteger request_user_id;
/** 车辆id */
@property (assign, nonatomic) NSInteger bike_id;
/** 保险类型 */
@property (copy, nonatomic) NSString * insurance_type;
/** 产品id */
@property (assign, nonatomic) NSInteger product_id;
/** 设备id*/
@property (assign, nonatomic) NSInteger device_id;

@end
