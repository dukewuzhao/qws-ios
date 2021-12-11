//
//  G100BatteryApi.m
//  G100
//
//  Created by yuhanle on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BatteryApi.h"

@implementation G100BatteryApi

+ (instancetype) sharedInstance {
    static G100BatteryApi *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ApiRequest *)getBatteryInfoWithBatteryid:(NSString *)batteryid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"batteryid" : [NSNumber numberWithInteger:[batteryid integerValue]] }];
    return [G100ApiHelper postApi:@"battery/getbattery" andRequest:request callback:callback];
}

- (ApiRequest *)getBatteryLossWithBatteryid:(NSString *)batteryid quereytype:(NSInteger)quereytype callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"batteryid" : [NSNumber numberWithInteger:[batteryid integerValue]],
                                                            @"quereytype" : [NSNumber numberWithInteger:quereytype] }];
    return [G100ApiHelper postApi:@"battery/getbatteryloss" andRequest:request callback:callback];
}

- (ApiRequest *)getBatteryCycleWithBatteryid:(NSString *)batteryid quereytype:(NSInteger)quereytype callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{  @"batteryid" : [NSNumber numberWithInteger:[batteryid integerValue]],
                                                             @"quereytype" : [NSNumber numberWithInteger:quereytype] }];
    return [G100ApiHelper postApi:@"battery/getbatterycycle" andRequest:request callback:callback];
}

@end
