//
//  PingAnInsuranceModel.h
//  G100
//
//  Created by Tilink on 15/4/11.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100ExtraoptionDomain.h"
#import "G100GoodDomain.h"
@class G100InsuranceInfo;
@interface PingAnInsuranceModel : G100BaseDomain

/** 保险价格 */
@property (assign, nonatomic) CGFloat price;
/** 保险折扣 */
@property (assign, nonatomic) CGFloat discount;
/** 保险id */
@property (assign, nonatomic) NSInteger productid;
/** 服务时长 月 */
@property (assign, nonatomic) NSInteger servicemonths;
/** 保险详情 */
@property (copy, nonatomic) NSString * desc;
/** 保险名称 */
@property (copy, nonatomic) NSString * name;
/** 保险类型 */
@property (copy, nonatomic) NSString * type;
/** 保险类型 */
@property (copy, nonatomic) NSString * insurancetype;
/** 保险属性结构 */
@property (copy, nonatomic) NSString * extraoption;
@property (strong, nonatomic) G100ExtraoptionDomain * kextraoption;

/*产品图片url*/
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, strong) NSDictionary *insurance;
/*保险相关信息*/
@property (nonatomic, strong) G100InsuranceInfo *kinsurance;
/** 产品图片url*/
@property (nonatomic, copy) NSString *icon;
/** 点击按钮文案 如空 没有按钮 有值 则显示按钮*/
@property (nonatomic, copy) NSString *action_button;
/** 点击按钮链接*/
@property (nonatomic, copy) NSString *action_url;
/** 产品详情链接*/
@property (nonatomic, copy) NSString *detail_url;

/** 保险贴图 */
@property (nonatomic, copy) NSString * imageUrl;
/** 保险主标题 */
@property (nonatomic, copy) NSString * descTitle;
/** 保险副标题 */
@property (nonatomic, copy) NSString * descContent;
/** 保险描述 */
@property (nonatomic, copy) NSString * descDesc;

@end
