//
//  G100WeatherManager.h
//  G100
//
//  Created by sunjingjing on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100WeatherModel : NSObject

@property (nonatomic, copy) NSString *locAddress;
@property (nonatomic, copy) NSString *weather;
@property (nonatomic, copy) NSString *temperature;
@property (nonatomic, copy) NSString *reportTime;
@property (copy, nonatomic) NSString *windPower;
@property (copy, nonatomic) NSString *date;

@end

typedef void(^G100WeatherRequestCallback)(NSError *error, G100WeatherModel *weatherModel);
typedef void(^G100ForecastWeatherRequestCallback)(NSError *error, NSArray *forecasts);
typedef void(^G100MapServiceLocationCallback)(NSError *error, NSDictionary *locationDic);

@interface G100WeatherManager : NSObject

@property (assign, nonatomic) BOOL isNetworkReady;

/**
 *  创建天气管理单例
 *
 *  @return 天气管理单例
 */
+ (instancetype)sharedInstance;
/**
 *  获取实时天气模型
 *
 *  @return 实时天气模型
 */
- (void)getWeatherModelByManual:(BOOL)isManual withUpdateCallback:(G100WeatherRequestCallback)updateCallback complete:(G100WeatherRequestCallback)callback;
/**
 *  获取预报天气
 *
 *  @return 天气模型
 */
- (void)getForecastWeatherModeComplete:(G100ForecastWeatherRequestCallback)callback;
/**
 *  获取用户当前位置

 @return 当前位置经纬度（纬度在前，经度在后）
 */
- (void)getCurrentLoactionInfoWithCallback:(G100MapServiceLocationCallback)callback;

@end
