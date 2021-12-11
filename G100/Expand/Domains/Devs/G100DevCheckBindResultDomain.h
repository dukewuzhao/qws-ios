//
//  G100DevCheckBindResultDomain.h
//  G100
//
//  Created by William on 16/4/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevCheckBindResultDomain : G100BaseDomain

/** 服务结束日期 */
@property (nonatomic, copy) NSString * serviceenddate;
/** 硬件保修期截止日期 */
@property (nonatomic, copy) NSString * locwarranty;
/** 赠送盗抢险标识 0无 1有效 2已过期 3已领取 */
@property (nonatomic, assign) NSInteger gifttheftinsurance;
/** 赠送盗抢险领取url */
@property (nonatomic, copy) NSString * gtipickupurl;
/** 赠送盗抢险填写url */
@property (nonatomic, copy) NSString * gtifillurl;

@end
