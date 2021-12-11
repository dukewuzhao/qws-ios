//
//  G100InsuranceOrder.h
//  G100
//
//  Created by yuhanle on 2016/12/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100InsuranceOrder;
@class G100InsuranceStatusPack;
@interface G100InsuranceStatusPacks : G100BaseDomain

@property (nonatomic, strong) NSArray <G100InsuranceStatusPack *> *list;

@end

@interface G100InsuranceStatusPack : G100BaseDomain

/** 保单状态 0无 1保障中 2审核中 3报案期 4丢车理赔中 5已赔付 6已作废 7将到期 8已过期 9待领取 10待支付*/
@property (nonatomic, assign) NSInteger status;
/** 保单列表*/
@property (nonatomic, strong) NSArray <G100InsuranceOrder *> *orderlist;

@end

@interface G100InsuranceOrder : G100BaseDomain

/** 保险类型 1盗抢险 2人身意外险 3三方责任险， |可以表示组合险*/
@property (nonatomic, copy) NSString *type;
/** 产品id*/
@property (nonatomic, assign) NSInteger product_id;
/** 产品名称*/
@property (nonatomic, copy) NSString *product_name;
/** 产品价格*/
@property (assign, nonatomic) CGFloat product_price;
/** 产品描述*/
@property (nonatomic, copy) NSString *product_desc;
/** 产品图片url*/
@property (nonatomic, copy) NSString *product_picture;
/** 保单状态 0无 1保障中 2审核中 3报案期 4丢车理赔中 5已赔付 6已作废 7将到期 8已过期 9待领取 10待支付*/
@property (nonatomic, assign) NSInteger status;
/** 承保人姓名*/
@property (nonatomic, copy) NSString *insured_name;
/** 被保人姓名*/
@property (nonatomic, copy) NSString *insurance_name;
/** 被保人身份证号*/
@property (nonatomic, copy) NSString *idcard;
/** 被保人手机号*/
@property (nonatomic, copy) NSString *phone_num;
/** 保险开始日期*/
@property (nonatomic, copy) NSString *begin_date;
/** 保险结束日期（包含）*/
@property (nonatomic, copy) NSString *end_date;
/** 保险公司名称*/
@property (nonatomic, copy) NSString *insurer;
/** 车架号*/
@property (nonatomic, copy) NSString *vin;
/** 车辆名称*/
@property (nonatomic, copy) NSString *bike_name;
/** 订单号 可为0*/
@property (nonatomic, assign) NSInteger order_id;
/** 详情url 可为空*/
@property (nonatomic, copy) NSString *detail_url;
/** 操作url（按钮点击，如领取、续保等操作），可为空*/
@property (nonatomic, copy) NSString *action_url;
/** 操作按钮显示文字（如免费领取、续保等操作）*/
@property (copy, nonatomic) NSString *action_button;
/** 保额*/
@property (assign, nonatomic) NSInteger insurance_amount;
/** 车辆品牌*/
@property (copy, nonatomic) NSString *bike_brand;
/** 保险剩余时间*/
@property (assign, nonatomic) NSInteger insurance_endmin;
/** 保单创建时间*/
@property (assign, nonatomic) NSInteger order_created;

@end
