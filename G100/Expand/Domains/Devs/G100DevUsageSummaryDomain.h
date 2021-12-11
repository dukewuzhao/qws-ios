//
//  G100DevUsageSummaryDomain.h
//  G100
//
//  Created by Tilink on 15/5/17.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevUsageSummaryDomain : G100BaseDomain

/** 日期 */
@property (copy, nonatomic) NSString * day;
/** 行驶距离 公里 */
@property (assign, nonatomic) CGFloat distance;
/** 行驶时间 秒 */
@property (assign, nonatomic) NSInteger time;
/** 平均速度 km/h */
@property (assign, nonatomic) CGFloat speed;
/** 警报次数 */
@property (assign, nonatomic) NSInteger alertcount;
/** 警报次数 V2.0 */
@property (assign, nonatomic) NSInteger alert_count;
/** 正常骑行次数 V2.0 */
@property (nonatomic, assign) NSInteger ride_count;
@end
