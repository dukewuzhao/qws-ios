//
//  G100WeatherManager.m
//  G100
//
//  Created by sunjingjing on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100WeatherManager.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "G100LocationResultManager.h"
#import "NSDate+TimeString.h"

@implementation G100WeatherModel

@end

@interface G100WeatherManager () <AMapSearchDelegate, AMapLocationManagerDelegate>

@property (strong, nonatomic) AMapSearchAPI *aMapSearch;
@property (strong, nonatomic) AMapLocationManager *locationManager;
@property (strong, nonatomic) AMapWeatherSearchRequest *aMapRequest;

@property (copy, atomic)      G100WeatherRequestCallback weatherBlock;
@property (copy, atomic)      G100ForecastWeatherRequestCallback forecastWeatherBlock;

@property (copy, nonatomic)   NSError *weaError;
@property (copy, nonatomic)   NSDate *lastUpdateTime;

@property (assign, nonatomic) BOOL isLoaded;
@property (copy, nonatomic) NSMutableArray <G100WeatherRequestCallback>*updateWeathBlock;

@end

@implementation G100WeatherManager

#pragma mark - Lazy load
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        _locationManager.delegate = (id<AMapLocationManagerDelegate>)self;
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    }
    return _locationManager;
}

- (AMapSearchAPI *)aMapSearch {
    if (!_aMapSearch) {
        _aMapSearch = [[AMapSearchAPI alloc] init];
        _aMapSearch.delegate = self;
    }
    return _aMapSearch;
}

- (AMapWeatherSearchRequest *)aMapRequest {
    if (!_aMapRequest) {
        _aMapRequest = [[AMapWeatherSearchRequest alloc] init];
        _aMapRequest.type = AMapWeatherTypeForecast;
    }
    return _aMapRequest;
}

-(NSMutableArray <G100WeatherRequestCallback>*)updateWeathBlock {
    if (!_updateWeathBlock) {
        _updateWeathBlock = [NSMutableArray array];
    }
    return _updateWeathBlock;
}

#pragma mark - Singleton
+ (instancetype)sharedInstance {
    static G100WeatherManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Public Method
/// 获取用户定位信息
- (void)getCurrentLoactionInfoWithCallback:(G100MapServiceLocationCallback)callback {
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    self.locationManager.locationTimeout = 10.0;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
            callback(error, nil);
            return;
        }
        if (regeocode && location) {
            // 保存定位信息
            [[G100LocationResultManager sharedInstance] saveUserLocationWithLocation:location result:regeocode];
            NSDictionary *jsonDic = @{ @"lati" : @(location.coordinate.latitude),
                                       @"longi" : @(location.coordinate.longitude),
                                       @"adcode" :regeocode.adcode };
            callback(nil, jsonDic);
        }
    }];
}

/// 获取天气预报实时天气
- (void)getWeatherModelByManual:(BOOL)isManual withUpdateCallback:(G100WeatherRequestCallback)updateCallback complete:(G100WeatherRequestCallback)callback {
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    self.locationManager.locationTimeout = 10.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isManual == NO) {
            if (updateCallback) {
                [self.updateWeathBlock addObject:updateCallback];
            }
            if (self.isLoaded == YES) {
                NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
                if (timeInterval < 3600 *3) {
                    NSDictionary *weather = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXWeatherReportResult];
                    G100WeatherModel *weatherModel = [[G100WeatherModel alloc] init];
                    weatherModel.locAddress = weather[@"city"] ? weather[@"city"] : weather[@"province"];
                    weatherModel.temperature = weather[@"temperature"];
                    weatherModel.weather = weather[@"weather"];
                    weatherModel.reportTime = weather[@"reportTime"];
                    if (self.updateWeathBlock.count > 0) {
                        for (int i = 0; i< self.updateWeathBlock.count; i++) {
                            G100WeatherRequestCallback callback = self.updateWeathBlock[i];
                            if (callback) {
                                callback(nil, weatherModel);
                            }
                        }
                    }
                    return;
                }
            }
        }
        
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error) {
                self.weaError = error;
                if (self.updateWeathBlock.count > 1 && !isManual) {
                    for (int i = 0; i < self.updateWeathBlock.count; i++) {
                        G100WeatherRequestCallback callback = self.updateWeathBlock[i];
                        callback(error, nil);
                    }
                }else if (self.updateWeathBlock.count > 1 && isManual)
                {
                    for (int i = 0; i < self.updateWeathBlock.count; i++) {
                        G100WeatherRequestCallback callback = self.updateWeathBlock[i];
                        callback(error, nil);
                    }
                }
                
                if (callback) {
                    callback(self.weaError, nil);
                }
                return;
            }
            
            self.weaError = nil;
            if (regeocode && location) {
                // 保存定位信息
                [[G100LocationResultManager sharedInstance] saveUserLocationWithLocation:location result:regeocode];
                
                NSString *city;
                if (!regeocode.city) {
                    city = regeocode.province;
                }else{
                    city = regeocode.city;
                }
                self.aMapRequest.city = city;
                [self.aMapSearch AMapWeatherSearch:self.aMapRequest];
            }
            self.weatherBlock = callback;
        }];
        
    });
}

/// 获取预报天气
- (void)getForecastWeatherModeComplete:(G100ForecastWeatherRequestCallback)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if (error) {
                self.weaError = error;
                if (callback) {
                    callback(self.weaError, nil);
                }
                return;
            }
            
            self.weaError = nil;
            if (regeocode && location) {
                // 保存定位信息
                [[G100LocationResultManager sharedInstance] saveUserLocationWithLocation:location result:regeocode];
                
                NSString *city;
                if (!regeocode.city) {
                    city = regeocode.province;
                }else {
                    city = regeocode.city;
                }
                
                self.aMapRequest.city = city;
                [self.aMapSearch AMapWeatherSearch:self.aMapRequest];
                if (callback) {
                    self.forecastWeatherBlock = callback;
                }
            }
        }];
    });
}

#pragma mark - AMapSearchDelegate
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response {
    if(request.type == AMapWeatherTypeLive) {
        if(response.lives.count == 0) {
            return;
        }
        
        AMapLocalWeatherLive * live = [response.lives lastObject];
        NSDictionary * weather = [live mj_keyValues];
        
        G100WeatherModel *weatherModel = [[G100WeatherModel alloc] init];
        weatherModel.locAddress = live.city.length ? live.city : live.province;
        weatherModel.temperature = live.temperature;
        weatherModel.weather = live.weather;
        weatherModel.reportTime = live.reportTime;
        // 保存天气预报结果至本地
        [[G100InfoHelper shareInstance] setAsynchronous:weather withKey:kGXWeatherReportResult];
        
        self.lastUpdateTime = [NSDate date];
        if (self.weatherBlock) {
            if (self.weaError) {
                self.weatherBlock(self.weaError, weatherModel);
                self.weaError = nil;
            }else
            {
                self.weatherBlock(nil, weatherModel);
            }
            self.weatherBlock = nil;
        }
        if (self.updateWeathBlock.count >= 1) {
            for (int i = 0; i < self.updateWeathBlock.count; i++) {
                G100WeatherRequestCallback callback = self.updateWeathBlock[i];
                callback(nil, weatherModel);
            }
        }
        
        self.isLoaded = YES;
    }else if (request.type == AMapWeatherTypeForecast) {
        if(response.forecasts.count == 0) {
            return;
        }
        
        AMapLocalWeatherForecast *forecast = [response.forecasts lastObject];
        NSMutableArray *weaModels = [NSMutableArray array];
        for (AMapLocalDayWeatherForecast *dayForecast in [forecast.casts subarrayWithRange:NSMakeRange(0, 2)]) {
            G100WeatherModel *weatherModel = [[G100WeatherModel alloc] init];
            weatherModel.windPower = [NSString stringWithFormat:@"风力-%@",dayForecast.dayPower];
            weatherModel.weather = dayForecast.dayWeather;
            weatherModel.reportTime = forecast.reportTime;
            weatherModel.temperature = [NSString stringWithFormat:@"%@/%@°",dayForecast.nightTemp,dayForecast.dayTemp];
            [weaModels addObject:weatherModel];
        }
        
        if (self.forecastWeatherBlock) {
            self.forecastWeatherBlock(nil, weaModels);
            self.forecastWeatherBlock = nil;
        }
    }
}

@end
