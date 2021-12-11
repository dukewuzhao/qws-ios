//
//  G100DevTrackDomain.h
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevTrackDomain : G100BaseDomain

/** 轨迹经度 */
@property (copy, nonatomic) NSString * longi;
/** 轨迹纬度 */
@property (copy, nonatomic) NSString * lati;
/** 轨迹位置信息 */
@property (copy, nonatomic) NSString * desc;
/** 轨迹时间 */
@property (copy, nonatomic) NSString * ts;

@end
