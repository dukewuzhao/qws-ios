//
//  G100LocationResultManager.m
//  G100
//
//  Created by 温世波 on 15/12/16.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100LocationResultManager.h"
#import "G100InfoHelper.h"

NSString * const kGXUserLocationResult = @"userlocationresult";
NSString * const kGXDiscoveryLocatedCity  = @"discoveryLocatedCity";
NSString * const kGXDiscoverySelectedCity  = @"discoverySelectedCity";

@implementation G100LocationResultManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static G100LocationResultManager * instance = nil;
    
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        
        NSDictionary * locationDict = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXUserLocationResult];
        
        if (locationDict) {
            instance.locationInfo = [[G100LocationInfoModel alloc] initWithDictionary:locationDict];
            instance.locationResult = [[G100LocationResultModel alloc] initWithDictionary:locationDict];
        }
        
        NSDictionary * locatedDict = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXDiscoveryLocatedCity];
        if (locatedDict) {
            instance.discoveryLocatedCity = [[G100DiscoveryLocationModel alloc]initWithDictionary:locatedDict];
        }
        
        NSDictionary * selectedDict = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXDiscoverySelectedCity];
        if (selectedDict) {
            instance.discoverySelectedCity = [[G100DiscoveryLocationModel alloc]initWithDictionary:selectedDict];
        }
        
    });
    return instance;
}

- (void)saveUserLocationWithLocation:(CLLocation *)location result:(AMapLocationReGeocode *)result {
    // 存储定位信息至userdefault 并更新实例
    if (!_locationResult) {
        _locationResult = [[G100LocationResultModel alloc] init];
    }
    
    if (!_locationInfo) {
        _locationInfo = [[G100LocationInfoModel alloc] init];
    }

    // handle
    NSDictionary * locationDict = @{
                                    @"coordinate" : @[[NSNumber numberWithDouble:location.coordinate.longitude], [NSNumber numberWithDouble:location.coordinate.latitude]],
                                    @"altitude" : [NSNumber numberWithDouble:location.altitude],
                                    @"accuracy" : [NSNumber numberWithDouble:location.horizontalAccuracy],
                                    @"course" : [NSNumber numberWithInteger:(NSInteger)location.course],
                                    @"speed" : [NSNumber numberWithDouble:location.speed],
                                    @"ts" : [NSNumber numberWithInteger:[location.timestamp timeIntervalSince1970]],
                                    @"citycode" : EMPTY_IF_NIL(result.citycode),
                                    @"adcode" : EMPTY_IF_NIL(result.adcode),
                                    @"address" : EMPTY_IF_NIL(result.formattedAddress),
                                    @"town" : @"高德地图不提供",
                                    @"road" : EMPTY_IF_NIL(result.street),
                                    @"province" : EMPTY_IF_NIL(result.province),
                                    @"city" : result.city.length ? result.city : EMPTY_IF_NIL(result.province),
                                    @"district" : EMPTY_IF_NIL(result.district),
                                    @"neighborhood" : @"高德地图不提供",
                                    @"number" : EMPTY_IF_NIL(result.number)
                                    };
    
    [_locationInfo setValuesForKeysWith_MyDict:locationDict];
    [_locationResult setValuesForKeysWith_MyDict:locationDict];
    [[G100InfoHelper shareInstance] setAsynchronous:locationDict withKey:kGXUserLocationResult];
}

- (void)saveDiscoveryLocatedCityModelWithResult:(AMapLocationReGeocode *)result {
    if (!_discoveryLocatedCity) {
        _discoveryLocatedCity = [[G100DiscoveryLocationModel alloc]init];
    }
    NSDictionary * locatedDict = @{
                                             @"adcode" : EMPTY_IF_NIL(result.adcode),
                                             @"city" : result.city.length ? result.city : EMPTY_IF_NIL(result.province)
                                             };
    [_discoveryLocatedCity setValuesForKeysWith_MyDict:locatedDict];
    [[G100InfoHelper shareInstance] setAsynchronous:locatedDict withKey:kGXDiscoveryLocatedCity];
}

- (void)saveDiscoverySelectedCityModelWithResult:(G100ServiceCityDomain *)result {
    if (!_discoverySelectedCity) {
        _discoverySelectedCity = [[G100DiscoveryLocationModel alloc]init];
    }
    NSDictionary * selectedDict = @{
                                    @"adcode" : EMPTY_IF_NIL(result.adcode),
                                    @"city" : result.city
                                    };
    [_discoverySelectedCity setValuesForKeysWith_MyDict:selectedDict];
    [[G100InfoHelper shareInstance] setAsynchronous:selectedDict withKey:kGXDiscoverySelectedCity];
}

- (G100DiscoveryLocationModel *)discoverySelectedCity {
    if (!_discoverySelectedCity) {
        NSDictionary * selectedDict = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXDiscoverySelectedCity];
        if (selectedDict) {
            _discoverySelectedCity = [[G100DiscoveryLocationModel alloc]initWithDictionary:selectedDict];
        }else {
            _discoverySelectedCity = [[G100DiscoveryLocationModel alloc] init];
        }
    }
    
    return _discoverySelectedCity;
}

- (G100DiscoveryLocationModel *)discoveryLocatedCity {
    if (!_discoveryLocatedCity) {
        NSDictionary * locatedCity = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXDiscoveryLocatedCity];
        if (locatedCity) {
            _discoveryLocatedCity = [[G100DiscoveryLocationModel alloc]initWithDictionary:locatedCity];
        }else {
            _discoveryLocatedCity = [[G100DiscoveryLocationModel alloc] init];
        }
    }
    
    return _discoveryLocatedCity;
}

@end
