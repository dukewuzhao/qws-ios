//
//  G100InsuranceDetail.h
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100InsuranceDetail : G100BaseDomain

/** 保险类型 1盗抢险 2人身意外险 3三方责任险， |可以表示组合险*/
@property (nonatomic, copy) NSString *type;
/** 产品id*/
@property (nonatomic, assign) NSInteger *product_id;
/** 产品名称*/
@property (nonatomic, copy) NSString *product_name;
/** 产品图片url*/
@property (nonatomic, copy) NSString *product_picture;
/** 保险支付费用*/
@property (nonatomic, assign) CGFloat price_paid;
/** 保单状态 0无 1保障中 2审核中 3报案期 4丢车理赔中 5已赔付 6已作废 7将到期 8已过期 9待领取*/
@property (nonatomic, assign) NSInteger status;
/** 申请人姓名*/
@property (nonatomic, copy) NSString *applicant_name;
/** 被保人姓名*/
@property (nonatomic, copy) NSString *insured_name;
/** 被保车辆名称*/
@property (nonatomic, copy) NSString *bike_name;
/** 保单号*/
@property (nonatomic, copy) NSString *policy_no;
/** 保险开始日期*/
@property (nonatomic, copy) NSString *begin_date;
/** 保险结束日期（包含）*/
@property (nonatomic, copy) NSString *end_date;
/** 服务号码*/
@property (nonatomic, copy) NSString *service_num;
/** 保险公司名称*/
@property (nonatomic, copy) NSString *insurer;
/** 设备二维码（仅限盗抢险）*/
@property (nonatomic, copy) NSString *device_qr;
/** 车架号（仅限盗抢险）*/
@property (nonatomic, copy) NSString *Vin;
/** 订单编号*/
@property (nonatomic, assign) NSInteger order_id;
/** 详情url 可为空*/
@property (nonatomic, copy) NSString *detail_url;
/** 操作url（按钮点击，如领取、续保等操作），可为空*/
@property (nonatomic, copy) NSString *action_url;

@end
