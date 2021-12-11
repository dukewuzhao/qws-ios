//
//  G100BatteryApi.h
//  G100
//
//  Created by yuhanle on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100Api.h"

@interface G100BatteryApi : NSObject

+ (instancetype)sharedInstance;

/**
 获取电池信息

 @param batteryid 电池id
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)getBatteryInfoWithBatteryid:(NSString *)batteryid callback:(API_CALLBACK)callback;

/**
 获取电池损耗

 @param batteryid 电池id
 @param quereytype 查询类型 0-按天/1-按周/2-按月
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)getBatteryLossWithBatteryid:(NSString *)batteryid quereytype:(NSInteger)quereytype callback:(API_CALLBACK)callback;

/**
 获取电池循环次数

 @param batteryid 电池id
 @param quereytype 查询类型 0-按天/1-按周/2-按月
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)getBatteryCycleWithBatteryid:(NSString *)batteryid quereytype:(NSInteger)quereytype callback:(API_CALLBACK)callback;

@end
