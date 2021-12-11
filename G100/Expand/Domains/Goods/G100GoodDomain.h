//
//  G100GoodDomain.h
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100ExtraoptionDomain.h"

@class G100InsuranceInfo;
@interface G100GoodDomain : G100BaseDomain

/** 商品价格 */
@property (assign, nonatomic) CGFloat price;
/** 商品折扣 */
@property (assign, nonatomic) CGFloat discount;
/** 商品id */
@property (assign, nonatomic) NSInteger product_id;
/** 服务期限 月 */
@property (assign, nonatomic) NSInteger service_months;
/** 商品描述 */
@property (copy, nonatomic) NSString * desc;
/** 商品名称 */
@property (copy, nonatomic) NSString * name;
/** 商品类型 1流量服务 2保险*/
@property (copy, nonatomic) NSString * type;
/** 保险类型 1盗抢险 2人身意外险 3三方责任险 或者组合使用|分割 */
@property (copy, nonatomic) NSString * insurancetype;
/** 商品详情结构 */
@property (copy, nonatomic) NSString * extraoption;
@property (strong, nonatomic) G100ExtraoptionDomain /*G100ExtraoptionDomain*/ * kextraoption;
/** 服务时间 */
@property (copy, nonatomic) NSString * serviceenddate;
/** 车辆名称 */
@property (copy, nonatomic) NSString * bike_name;
/** 产品图片url*/
@property (nonatomic, copy) NSString *picture;
/** 保险相关信息*/
@property (nonatomic, strong) G100InsuranceInfo *insurance;
/** 保险类型 1盗抢险 2人身意外险 3三方责任险 或者组合使用|分割 */
@property (copy, nonatomic) NSString * insurance_type;

@end

@interface G100InsuranceInfo : G100BaseDomain

/** 保险公司名称*/
@property (copy, nonatomic) NSString *insurer;
/** 服务号码*/
@property (copy, nonatomic) NSString *service_num;
/** 保额*/
@property (assign, nonatomic) NSInteger insured_amount;

@end
