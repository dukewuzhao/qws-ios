//
//  G100ExtraoptionDomain.h
//  G100
//
//  Created by Tilink on 15/6/25.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100ExtraoptionDomain : G100BaseDomain

/** 商品是否可用 1可用 0不可用 */
@property (assign, nonatomic) BOOL enable;
/** 水印类型 1已购买 2已购买未支付 */
@property (copy, nonatomic) NSString *watermark;
/** 购买情况 0未购买 1已购买 2已购买未支付 */
@property (assign, nonatomic) NSInteger status;
/** 最近购买的订单id 可用做跳转参数 */
@property (assign, nonatomic) NSInteger recentorderid;
/** 订单id */
@property (assign, nonatomic) NSInteger order;
/** 选中状态*/
@property (assign, nonatomic) BOOL selected;
/** 保险公司名称*/
@property (copy, nonatomic) NSString *insurer;
/** 服务号码*/
@property (copy, nonatomic) NSString *servicenum;
/** 保额*/
@property (assign, nonatomic) NSInteger insuredamount;
/** 原价*/
@property (nonatomic, strong) NSString *original_price;
/** 限制特卖标识*/
@property (nonatomic, copy) NSString *sale_tag;
/** 已销售数量 定时刷新*/
@property (nonatomic, assign) NSInteger sold_count;

@end
