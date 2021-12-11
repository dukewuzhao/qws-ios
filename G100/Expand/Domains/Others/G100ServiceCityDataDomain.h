//
//  G100ServiceCityDataDomain.h
//  G100
//
//  Created by 温世波 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100ServiceCityDomain : G100BaseDomain

@property (nonatomic, copy) NSString *adcode; //!< 城市代码
@property (nonatomic, copy) NSString *city; //!< 城市名称
@property (nonatomic, assign) NSInteger serviceflag; //!< 服务标志 0未开通 1已开通 2即将开通
@property (nonatomic, copy) NSString *pinyin; //!< 拼音首字母
@property (nonatomic, assign) double longi; //!< 城市中心经度
@property (nonatomic, assign) double lati; //!< 城市中心纬度

@end

@interface G100ServiceCityDistrictDomain : G100BaseDomain

@property (nonatomic, copy) NSString *adcode; //!< 区域代码
@property (nonatomic, copy) NSString *district; //!< 区域名称
@property (nonatomic, assign) double longi; //!< 中心点经度
@property (nonatomic, assign) double lati; //!< 中心点纬度

@end

@interface G100ServiceCityDataDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger versionflag; //!< 列表版本控制 0无新版本（城市版本为空） 1有新版本
@property (nonatomic, copy) NSString *listts; //!< 列表时间戳 "2015-12-31 23:00:00"
@property (nonatomic, strong) NSArray *cities; //!< 所有城市 NSDictionary

@end
