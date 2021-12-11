//
//  G100CityDataManager.m
//  G100
//
//  Created by 温世波 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100CityDataManager.h"
#import "G100InfoHelper.h"

static NSString * const kGXServiceCitysDataKey     = @"servicecitys";
static NSString * const kGXServiceCityDistrictsKey = @"servicecitydistricts";

@implementation G100CityDataManager

+ (instancetype)sharedInstance {
    static G100CityDataManager * instance;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (BOOL)hasLocalData {
    if ([self localCityData]) {
        return YES;
    }
    return NO;
}

- (NSString *)localCityListts {
    if ([self localCityData]) {
        return self.localCityData.listts;
    } // 否则返回一个很早的时间
    return @"2001-01-01 00:00:00";
}

- (NSArray *)loadAllCity {
    NSArray *allCitys = self.localCityData.cities.copy;
    
    if (allCitys) {
        [allCitys mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100ServiceCityDomain alloc] initWithDictionary:item];
            }else if (INSTANCE_OF(item, G100ServiceCityDomain)) {
                return item;
            }
            return nil;
        }];
    }
    
    return allCitys;
}

- (G100ServiceCityDataDomain *)localCityData {
    NSDictionary *cityData = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXServiceCitysDataKey];
    G100ServiceCityDataDomain * data = nil;
    if (cityData) {
        data = [[G100ServiceCityDataDomain alloc] initWithDictionary:cityData];
    }
    
    return data;
}

- (NSArray *)loadLocalCityDistrictsWithAdcode:(NSString *)adcode {
    NSDictionary *allDistricts = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXServiceCityDistrictsKey];
    NSArray *districts = nil;
    if (allDistricts) {
        districts = allDistricts[adcode];
        if (districts) {
            [districts mapWithBlock:^id(id item, NSInteger idx) {
                if (INSTANCE_OF(item, NSDictionary)) {
                    return [[G100ServiceCityDistrictDomain alloc] initWithDictionary:item];
                }else if (INSTANCE_OF(item, G100ServiceCityDistrictDomain)) {
                    return item;
                }
                return nil;
            }];
        }
    }
    
    return districts;
}

- (void)updateLocalCityDataWithData:(NSDictionary *)data {
    if (data) {
        [[G100InfoHelper shareInstance] setAsynchronous:data withKey:kGXServiceCitysDataKey];
    }
}

- (void)updateLocalCityDistrictWithDistricts:(NSArray *)districts adcode:(NSString *)adcode {
    NSDictionary *allDistricts = [[G100InfoHelper shareInstance] getAsynchronousWithKey:kGXServiceCityDistrictsKey];
    NSMutableDictionary *originalData = allDistricts.mutableCopy;
    if (!originalData) {
        originalData = [[NSMutableDictionary alloc] init];
    }
    
    if (districts && adcode) {
        [originalData setObject:districts forKey:adcode];
        
        if (originalData) {
            [[G100InfoHelper shareInstance] setAsynchronous:originalData.copy withKey:kGXServiceCityDistrictsKey];
        }
    }
}

@end
