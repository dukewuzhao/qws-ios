//
//  G100DeviceDomain.m
//  G100
//
//  Created by yuhanle on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DeviceDomain.h"

@implementation G100DeviceDomain

- (NSString *)name {
    if (!_name.length) {
        return @"GPS定位器";
    }
    return _name;
}

- (NSString *)firm {
    // 先判断是否是JSON 字符串
    NSDictionary *result = [_firm mj_JSONObject];
    if (result) {
        G100DeviceFirmDomain *firmDomain = [[G100DeviceFirmDomain alloc] initWithDictionary:result];
        if ([firmDomain.version hasContainString:@"Project Version"]) {
            NSArray *arr = [firmDomain.version componentsSeparatedByString:@":"];
            return [arr lastObject];
        }
        
        return firmDomain.version;
    }else {
        if ([_firm hasContainString:@"Project Version"]) {
            NSArray *arr = [_firm componentsSeparatedByString:@":"];
            return [arr lastObject];
        }
    }
    
    return _firm;
}

- (BOOL)isSpecialChinaMobileDevice {
    if (self.model_type_id == 3) {
        return YES;
    }
    return NO;
}

- (BOOL)isLostDevice {
    if (self.state == 4) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isOverdue {
    if (self.service.left_days <= 0) {
        return YES;
    }
    return NO;
}

- (BOOL)canRechargeAndOverdue {
    if (self.service.left_days <= 0 && self.service.left_days > -15) {
        return YES;
    }
    return NO;
}

- (BOOL)canRecharge {
    if (self.service.left_days > -15) {
        return YES;
    }
    return NO;
}

- (BOOL)needOverdueWarn {
    if (self.service.left_days > 0 && self.service.left_days <= 15) {
        return YES;
    }
    return NO;
}

- (NSInteger)leftdays {
    return self.service.left_days;
}

- (NSString *)securityModeResourceImageName {
    NSString *result = @"gps_standardmode";
    switch (self.security.mode) {
        case 2:
            result = @"gps_standardmode";
            break;
        case 3:
            result = @"gps_warnmode";
            break;
        case 1:
            result = @"gps_nodisturb";
            break;
        case 8:
            result = @"gps_finding";
            break;
        case 9:
            result = @"gps_offmode";
            break;
        default:
            break;
    }
    
    return result;
}

-(BOOL)isNormalDevice
{
    if (self.state == 1 || self.state == 4) {
        return YES;
    }
    return NO;
}

- (BOOL)isMainDevice {
    if (self.main_device == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)isFrontDevice {
    if (self.model_type_id == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)isG500Device {
    if (self.model_type_id == 5) {
        return YES;
    }
    return NO;
}

- (BOOL)isG800Device {
    if (self.model_type_id == 12) {
        return YES;
    }
    return NO;
}

- (BOOL)isGPSDevice {
    // 除了异常和电池设备 其他默认都是GPS 设备
    if (self.model_type_id == 0 ||
        self.model_type_id == 11) {
        return NO;
    }
    return YES;
}

- (BOOL)isSmartBatteryDevice {
    if (self.model_type_id == 11) {
        return YES;
    }
    return NO;
}

- (BOOL)isAfterInstallSingleDevice {
    if (self.model_type_id == 6) {
        return YES;
    }
    return NO;
}

- (BOOL)isChinaMobileCustomMode {
    if (self.model_id == 90000006) {
        return YES;
    }
    return NO;
}

@end

@implementation G100DeviceFunction

@end

@implementation G100DeviceSecuritySetting

@end

@implementation G100DeviceServiceInfo

@end

@implementation G100DeviceAlertorInfo

@end

@implementation G100DeviceSecurityWxNotify

@end

@implementation G100DeviceSecurityPhoneNotify

- (NSString *)callee_num {
    if (!_callee_num.length) {
        // 如果不存在该字段 则返回当前帐号的手机号
        return [[CurrentUser sharedInfo] phonenum];
    }
    return _callee_num;
}

@end

@implementation G100DeviceFirmDomain

@end
