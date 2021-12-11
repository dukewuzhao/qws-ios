//
//  G100StartPageDomain.h
//  G100
//
//  Created by 温世波 on 15/12/15.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100StartPageDomain : G100BaseDomain

@property (nonatomic, copy) NSString * picture; //!< 图片url
@property (nonatomic, copy) NSString * begintime; //!< 起始时间
@property (nonatomic, copy) NSString * endtime; //!< 结束时间
@property (nonatomic, copy) NSString * channel; //!< APP渠道
@property (nonatomic, copy) NSString * location; //!< 区域
@property (nonatomic, copy) NSString * priority; //!< 优先级(1~100)，数值越低优先级越高
@property (nonatomic, assign) NSInteger displaytime; //!< 显示时间（1s~10s之间，默认3s，超出有效范围使用默认值）
@property (nonatomic, copy) NSString *url; //!< 跳转url 为空则不跳转

@end
