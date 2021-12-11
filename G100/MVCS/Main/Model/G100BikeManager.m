//
//  G100BikeManager.m
//  G100
//
//  Created by sunjingjing on 16/7/22.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeManager.h"
#import "G100CardManager.h"
#import "G100ThemeManager.h"

@implementation G100BikeModel

@end

@interface G100BikeManager ()

@end

@implementation G100BikeManager

- (void)getBikeModelWithData:(G100BikeDomain *)bike compete:(G100BikeModelCallback)callback {
    G100BikeModel *bikeModel = [[G100BikeModel alloc] init];
    bikeModel.name = bike.name;
    bikeModel.is_master = bike.is_master;
    bikeModel.user_count = bike.user_count;
    bikeModel.pic_small = bike.feature.cover_picture;
    bikeModel.bike_type = bike.bike_type;
    bikeModel.isSmartDevice = bike.battery_devices.count >0 ? YES : NO;
    bikeModel.hasDevice = bike.gps_devices.count >0 ? YES : NO;
    if (bike.devices.count == 1 && bike.mainDevice.isChinaMobileCustomMode) {
        bikeModel.isChinaMobileCustom = YES;
    }else {
        bikeModel.isChinaMobileCustom = NO;
    }
    
    // 判断车辆品牌是否是预置品牌
    if (bike.brand.brand_id <= 0) {
        bikeModel.car_logo = nil;
        if (callback) {
            callback(bikeModel);
        }
    }else if (bike.brand.brand_id > 0) {
        // 预置品牌 需要从本地加载数据
        [[G100ThemeManager sharedManager] findThemeInfoDomainWithJsonUrl:bike.brand.channel_theme completeBlock:^(G100ThemeInfoDoamin *theme, BOOL success, NSError *error) {
            if (success) {
                bikeModel.car_logo = theme.theme_channel_info.logo_mid;
            }else {
                bikeModel.car_logo = nil;
            }
            if (callback) {
                callback(bikeModel);
            }
        }];
    }
}

@end
