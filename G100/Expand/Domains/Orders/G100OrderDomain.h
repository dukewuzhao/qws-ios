//
//  G100OrderDomain.h
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100OrderDomain : G100BaseDomain

/** 订单创建者id */
@property (assign, nonatomic) NSInteger request_user_id;
/** 订单id */
@property (assign, nonatomic) NSInteger order_id;
/** 订单创建时间 */
@property (copy, nonatomic) NSString * created_time;
/** 订单所属车辆名称 */
@property (copy, nonatomic) NSString * bike_name;
/** 订单所属商品名称 */
@property (copy, nonatomic) NSString * product_name;
/** 订单服务时间 月 */
@property (assign, nonatomic) NSInteger service_months;
/** 订单服务结束时间(日期，含在服务期内) YYYY-MM-DD */
@property (copy, nonatomic) NSString * service_end_date;
/** 订单价格 */
@property (assign, nonatomic) CGFloat price;
/** 订单状态 0初始状态 1支付完成 2保单核保成功 3保单核保失败 4保单承保成功 5完成 6取消 7待支付 8 保单待审核 */
@property (copy, nonatomic) NSString * status;
/** 订单类型 1流量服务 2保险 */
@property (assign, nonatomic) NSInteger order_type;
/** 保险订单支付url */
@property (copy, nonatomic) NSString * pay_url;
/** 订单所属车辆id */
@property (copy, nonatomic) NSString * bike_id;
/** 订单所属设备id */
@property (copy, nonatomic) NSString * device_id;
/** 订单所属商品id */
@property (nonatomic, copy) NSString * product_id;
/** 保险订单类型 1盗抢险  2人身意外险 3三方责任险 或者组合使用|分隔*/
@property (nonatomic, copy) NSString * insurance_type;
/** 设备名称 */
@property (nonatomic, copy) NSString *device_name;

@end
