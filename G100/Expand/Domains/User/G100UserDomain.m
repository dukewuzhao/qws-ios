//
//  G100UserDomain.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100UserDomain.h"
#import "G100DeviceDomainExpand.h"

@implementation G100UserDomain

- (NSString *)nickname {
    return self.nick_name;
}

- (NSString *)phonenum {
    return self.phone_num;
}

- (NSInteger)isMaster {
    if ([self.is_master isEqualToString:@"1"]) {
        return 1;
    }
    return 0;
}

- (BOOL)isOpenWxAlarmPush {
    NSArray *bikes = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:[NSString stringWithFormat:@"%@", @(self.user_id)]];
    for (G100BikeDomain *bike in bikes) {
        for (G100DeviceDomain *device in bike.gps_devices) {
            if (device.security.wx_notify.switch_on) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isOpenPhoneAlarm {
    NSArray *bikes = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:[NSString stringWithFormat:@"%@", @(self.user_id)]];
    for (G100BikeDomain *bike in bikes) {
        for (G100DeviceDomain *device in bike.gps_devices) {
            if (device.security.phone_notify.switch_on) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSString *)userid {
    return [NSString stringWithFormat:@"%@", @(self.user_id)];
}

@end

@implementation UserHomeInfo

@end
