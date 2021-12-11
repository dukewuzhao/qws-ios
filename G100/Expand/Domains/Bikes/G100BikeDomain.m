//
//  G100BikeDomain.m
//  G100
//
//  Created by yuhanle on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeDomain.h"
#import "G100DeviceDomain.h"
#import "G100BikeUpdateInfoDomain.h"

@implementation G100BikeDomain

- (BOOL)isMaster {
    if ([self.is_master isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isMOTOBike {
    if (self.bike_type == 1) {
        return YES;
    }
    return NO;
}

- (G100DeviceDomain *)mainDevice {
    for (G100DeviceDomain *device in self.devices) {
        if (device.main_device) {
            return device;
        }
    }
    
    if (self.devices.count) {
        return [self.devices firstObject];
    }
    
    return nil;
}

- (BOOL)isNormalBike {
    if (self.state == 1 || self.state == 4) {
        return YES;
    }
    return NO;
}

- (BOOL)isLostBike {
    if (self.state == 4) {
        return YES;
    }
    return NO;
}

- (G100DeviceDomain *)ableRemote_ctrlDevice {
    for (G100DeviceDomain *result in self.devices) {
        if (result.func.alertor.remote_ctrl == 1) {
            return result;
        }
    }
    return nil;
}

- (G100DeviceDomain *)hasSmartBatteryDevice {
    for (G100DeviceDomain *result in self.devices) {
        if (result.isSmartBatteryDevice) {
            return result;
        }
    }
    return nil;
}

- (NSInteger)guardDays {
    NSInteger days = 0;
    
    if (!self.gps_devices.count) {
        days = 0;
    } else {
        for (G100DeviceDomain *device in self.gps_devices) {
            days = days < device.service.binded_days ? device.service.binded_days : days;
        }
    }
    
    return days;
}

- (NSArray<G100DeviceDomain *> *)devices {
    _devices = [_devices sortedArrayUsingComparator:^NSComparisonResult(G100DeviceDomain * preDevice, G100DeviceDomain * nextDevice) {
        // 先按照主副设备排序 若相同则按照seq 排序
        NSComparisonResult result = [[NSNumber numberWithInteger:nextDevice.isMainDevice] compare:[NSNumber numberWithInteger:preDevice.isMainDevice]];
        if (result == NSOrderedSame) {
            result = [[NSNumber numberWithInteger:preDevice.seq] compare:[NSNumber numberWithInteger:nextDevice.seq]];
        }
        
        return result;
    }];
    
    for (NSInteger i = 0; i < _devices.count; i++) {
        _devices[i].index = i;
    }
    
    return _devices;
}

- (NSArray<G100DeviceDomain *> *)gps_devices {
    NSMutableArray <G100DeviceDomain *> *result = [NSMutableArray array];
    
    for (G100DeviceDomain *device in self.devices) {
        if (device.isGPSDevice) {
            [result addObject:device];
        }
    }
    
    for (NSInteger i = 0; i < result.count; i++) {
        result[i].index = i;
    }
    
    return result;
}

- (NSArray<G100DeviceDomain *> *)battery_devices {
    NSMutableArray <G100DeviceDomain *> *result = [NSMutableArray array];
    
    for (G100DeviceDomain *device in self.devices) {
        if (device.isSmartBatteryDevice) {
            [result addObject:device];
        }
    }
    
    for (NSInteger i = 0; i < result.count; i++) {
        result[i].index = i;
    }
    
    return result;
}

- (G100BikeUpdateInfoDomain *)bikeUpdateInfo
{
    G100BikeUpdateInfoDomain *updateInfo = [[G100BikeUpdateInfoDomain alloc] init];
    updateInfo.bike_id = self.bike_id;
    updateInfo.name = self.name;
    updateInfo.brand = self.brand;
    updateInfo.feature = self.feature;
    return updateInfo;
}

@end

@implementation G100BrandInfoDomain

@end

@implementation G100ModelInfoDomain

@end

@implementation G100BikeFeatureDomain
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"voltageInfo" : @"batt_vol",
              @"batteryInfo" : @"batt_class_id",
            };
}

@end

