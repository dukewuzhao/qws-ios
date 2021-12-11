//
//  G100CityDataManager.h
//  G100
//
//  Created by 温世波 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100ServiceCityDataDomain.h"

#define G100CityDataInfoHelper [G100CityDataManager sharedInstance]

@interface G100CityDataManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  判断本地是否存在城市列表
 *
 *  @return 是/否
 */
- (BOOL)hasLocalData;

/**
 *  版本时间戳
 *
 *  @return 本地存储的时间戳
 */
- (NSString *)localCityListts;

/**
 *  本地存储的城市信息
 *
 *  @return 本地存储的城市信息
 */
- (G100ServiceCityDataDomain *)localCityData;

/**
 *  本地存储的全部城市数组
 *
 *  @return 本地存储的城市数组 G100ServiceCityDomain
 */
- (NSArray *)loadAllCity;

/**
 *  查找城市对应的区域信息
 *
 *  @param adcode 城市对应的adcode
 *
 *  @return 城市对应的区域信息 G100ServiceCityDistrictDomain
 */
- (NSArray *)loadLocalCityDistrictsWithAdcode:(NSString *)adcode;

/**
 *  根据网络数据更新本地城市信息
 *
 *  @param data 网络返回的城市信息
 */
- (void)updateLocalCityDataWithData:(NSDictionary *)data;

/**
 *  根据网络数据更新本地城市对应区域信息
 *
 *  @param districts 区域信息
 *  @param adcode    区域adcode
 */
- (void)updateLocalCityDistrictWithDistricts:(NSArray *)districts adcode:(NSString *)adcode;

@end
