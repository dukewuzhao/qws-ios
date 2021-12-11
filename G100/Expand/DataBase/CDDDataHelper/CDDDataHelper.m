//
//  CDDDataHelper.m
//  CoreDataDemo
//
//  Created by yuhanle on 16/7/8.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "CDDDataHelper.h"

#import "MJExtension.h"
#import <MagicalRecord/MagicalRecord.h>

#import "CDDAccount+CoreDataProperties.h"
#import "CDDUser+CoreDataProperties.h"
#import "CDDBike+CoreDataProperties.h"
#import "CDDDevice+CoreDataProperties.h"

#import "G100BaseDomain.h"
#import "G100AccountDomain.h"
#import "G100UserDomain.h"
#import "G100BikeDomain.h"
#import "G100DeviceDomain.h"
#import "G100TestResultDomain.h"

NSString * const CDDDataHelperUserInfoDidChangeNotification   = @"com.cdddatahelper.userinfo.change";
NSString * const CDDDataHelperBikeListDidChangeNotification   = @"com.cdddatahelper.bikelist.change";
NSString * const CDDDataHelperBikeInfoDidChangeNotification   = @"com.cdddatahelper.bikeinfo.change";
NSString * const CDDDataHelperDeviceListDidChangeNotification = @"com.cdddatahelper.devicelist.change";
NSString * const CDDDataHelperDeviceInfoDidChangeNotification = @"com.cdddatahelper.deviceinfo.change";

static NSString *const kCDDSpecialKey_account_info      = @"account_info";
static NSString *const kCDDSpecialKey_user_info         = @"user_info";
static NSString *const kCDDSpecialKey_user_id           = @"user_id";
static NSString *const kCDDSpecialKey_bike              = @"bike";
static NSString *const kCDDSpecialKey_bikes             = @"bikes";
static NSString *const kCDDSpecialKey_bike_id           = @"bike_id";
static NSString *const kCDDSpecialKey_device            = @"device";
static NSString *const kCDDSpecialKey_devices           = @"devices";
static NSString *const kCDDSpecialKey_device_id         = @"device_id";
static NSString *const kCDDSpecialkey_bike_created_time = @"created_time";
static NSString *const kCDDSpecialkey_bike_seq = @"bike_seq";
static NSString *const kCDDSpecialkey_device_seq = @"seq";
static NSString *const kCDDSpecialkey_bike_update_type = @"bike_update_type";

@implementation CDDDataHelper

+ (instancetype)cdd_sharedInstace {
    static dispatch_once_t onceTonken;
    static CDDDataHelper * sharedInstance = nil;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[CDDDataHelper alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Add or Update
- (void)cdd_addOrUpdateAccountDataWithUser_id:(NSInteger)user_id account:(NSDictionary *)account {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    if (!account) {
        [cdd_account MR_deleteEntity];
        [self cdd_addOrUpdateUserInfoDataWithUser_id:user_id userinfo:nil];
        [self cdd_addOrUpdateBikesDataWithUser_id:user_id bikes:nil];
        return;
    }
    
    [CDDAccount mj_setupObjectClassInArray:^NSDictionary *{
        return @{kCDDSpecialKey_bikes : [CDDBike class]};
    }];
    
    // 首先设置一下特殊类型
    [CDDAccount mj_setupIgnoredPropertyNames:^NSArray *{
        return @[kCDDSpecialKey_user_info];
    }];
    [cdd_account mj_setKeyValues:account context:[NSManagedObjectContext MR_defaultContext]];
    [CDDAccount mj_setupIgnoredPropertyNames:^NSArray *{
        return @[];
    }];
    // 添加用户信息 如果有的话
    if (account[kCDDSpecialKey_user_info]) {
        [self cdd_addOrUpdateUserInfoDataWithUser_id:user_id userinfo:account[kCDDSpecialKey_user_info]];
    }
    if (account[kCDDSpecialKey_bikes]) {
        [self cdd_addOrUpdateBikesDataWithUser_id:user_id bikes:account[kCDDSpecialKey_bikes]];
    }
}

- (void)cdd_addOrUpdateUserInfoDataWithUser_id:(NSInteger)user_id userinfo:(NSDictionary *)userinfo {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    
    if (userinfo) {
        if (!cdd_account.user_info) {
            CDDUser *cdd_user = [CDDUser MR_createEntity];
            [cdd_user mj_setKeyValues:userinfo context:[NSManagedObjectContext MR_defaultContext]];
            cdd_account.user_info = cdd_user;
        }else {
            [cdd_account.user_info mj_setKeyValues:userinfo context:[NSManagedObjectContext MR_defaultContext]];
        }
    }else {
        if (cdd_account.user_info) {
            // 删除该记录
            [cdd_account.user_info MR_deleteEntity];
        }else {
            
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userinfo];
    [dict setObject:[NSString stringWithFormat:@"%@", @(user_id)] forKey:kCDDSpecialKey_user_id];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDDDataHelperUserInfoDidChangeNotification object:nil userInfo:dict];
}

- (void)cdd_addOrUpdateBikesDataWithUser_id:(NSInteger)user_id bikes:(NSArray *)bikes {
    if (0 == user_id) {
        return;
    }
    
    [self cdd_addOrUpdateBikesDataWithUser_id:user_id bikes:bikes updateType:BikeListNormalType];
}

- (void)cdd_addOrUpdateBikesDataWithUser_id:(NSInteger)user_id bikes:(NSArray *)bikes updateType:(BikeListUpdateType)updateType{
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    // 这里需要在本地数据里遍历 看是否和服务器的最新数据同步 如本地存在则更新 不存在则添加 服务器数据不存在则删除本地相关记录
    // 如果的数据为空 则清空本地数据
    if (!bikes || !bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *obj in allLocalBikesArray) {
            [obj MR_deleteEntity];
        }
        
        [cdd_account removeBikes:cdd_account.bikes];
    }
    
    // 服务器数据里查找本地是否存在
    for (NSDictionary * obj in bikes) {
        NSInteger bike_id2 = [obj[kCDDSpecialKey_bike_id] integerValue];
        BOOL not_exist = YES;
        NSDictionary *result = nil;
        for (CDDBike * bike in cdd_account.bikes) {
            if ([bike.bike_id integerValue] == bike_id2) {
                not_exist = NO;
            }
            
            result = obj;
        }
        
        if (not_exist && result) {
            // 待添加的数据
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            [cdd_account addBikesObject:cdd_bike];
            [cdd_bike mj_setKeyValues:result context:[NSManagedObjectContext MR_defaultContext]];
            if (result[kCDDSpecialKey_devices]) {
                [self cdd_addOrUpdateDevicesDataWithUser_id:user_id bike_id:[result[kCDDSpecialKey_bike_id] integerValue] devices:result[kCDDSpecialKey_devices]];
            }
        }else {
            // 待更新的数据 不用再添加到数据库
            
        }
    }
    
    // 本地数据查找服务器数据是否存在
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        BOOL exist = NO;
        NSDictionary *result = nil;
        for (NSDictionary * dict in bikes) {
            if ([dict[kCDDSpecialKey_bike_id] integerValue] == bike_id2) {
                exist = YES;
                result = dict;
            }
        }
        
        if (exist) {
            // 已经存在 则更新记录
            [obj mj_setKeyValues:result context:[NSManagedObjectContext MR_defaultContext]];
            if (result[kCDDSpecialKey_devices]) {
                [self cdd_addOrUpdateDevicesDataWithUser_id:user_id bike_id:[result[kCDDSpecialKey_bike_id] integerValue] devices:result[kCDDSpecialKey_devices]];
            }
        }else {
            // 不存在 就删除本地记录
            [cdd_account removeBikesObject:obj];
            [obj MR_deleteEntity];
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        for (NSDictionary *result in bikes) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            [cdd_account addBikesObject:cdd_bike];
            [cdd_bike mj_setKeyValues:result context:[NSManagedObjectContext MR_defaultContext]];
            if (result[kCDDSpecialKey_devices]) {
                [self cdd_addOrUpdateDevicesDataWithUser_id:user_id bike_id:[result[kCDDSpecialKey_bike_id] integerValue] devices:result[kCDDSpecialKey_devices]];
            }
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{kCDDSpecialKey_bikes : bikes ? : @""}];
    [dict setObject:[NSString stringWithFormat:@"%@", @(user_id)] forKey:kCDDSpecialKey_user_id];
    [dict setObject:@(updateType) forKey:kCDDSpecialkey_bike_update_type];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDDDataHelperBikeListDidChangeNotification object:nil userInfo:dict];
}

- (void)cdd_addOrUpdateBikeDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id bike:(NSDictionary *)bike {
    [self cdd_addOrUpdateBikeDataWithUser_id:user_id bike_id:bike_id bike:bike updateType:BikeInfoNormalType];
}

- (void)cdd_addOrUpdateBikeDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id bike:(NSDictionary *)bike updateType:(BikeInfoUpdateType)updateType {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    // 本地数据查找新的数据是否存在
    BOOL exist = NO;
    CDDBike *result = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            exist = YES;
            result = obj;
        }
    }
    
    if (exist) {
        // 已经存在 则更新记录
        if (bike) {
            [result mj_setKeyValues:bike context:[NSManagedObjectContext MR_defaultContext]];
            if (bike[kCDDSpecialKey_devices]) {
                [self cdd_addOrUpdateDevicesDataWithUser_id:user_id bike_id:bike_id devices:bike[kCDDSpecialKey_devices]];
            }
        }else {
            [cdd_account removeBikesObject:result];
            [result MR_deleteEntity];
        }
    }else {
        // 不存在 就添加新数据
        if (bike) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            [cdd_account addBikesObject:cdd_bike];
            [cdd_bike mj_setKeyValues:bike context:[NSManagedObjectContext MR_defaultContext]];
            if (bike[kCDDSpecialKey_devices]) {
                [self cdd_addOrUpdateDevicesDataWithUser_id:user_id bike_id:bike_id devices:bike[kCDDSpecialKey_devices]];
            }
        }else {
            
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        if (bike) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            [cdd_account addBikesObject:cdd_bike];
            [cdd_bike mj_setKeyValues:bike context:[NSManagedObjectContext MR_defaultContext]];
            if (bike[kCDDSpecialKey_devices]) {
                [self cdd_addOrUpdateDevicesDataWithUser_id:user_id bike_id:bike_id devices:bike[kCDDSpecialKey_devices]];
            }
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{kCDDSpecialKey_bike : bike ? : @""}];
    [dict setObject:[NSString stringWithFormat:@"%@", @(user_id)] forKey:kCDDSpecialKey_user_id];
    [dict setObject:[NSString stringWithFormat:@"%@", @(bike_id)] forKey:kCDDSpecialKey_bike_id];
    [dict setObject:@(updateType) forKey:kCDDSpecialkey_bike_update_type];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDDDataHelperBikeInfoDidChangeNotification object:nil userInfo:dict];
}

- (void)cdd_addOrUpdateDevicesDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id devices:(NSArray *)devices {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    CDDBike *cdd_bike = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            cdd_bike = obj;
        }
    }
    
    if (cdd_bike) {
        // 存在bike 则更新他的devices 信息
    }else {
        cdd_bike = [CDDBike MR_createEntity];
        cdd_bike.bike_id = @(bike_id);
        [cdd_account addBikesObject:cdd_bike];
    }
    
    // 这里需要在本地数据里遍历 看是否和服务器的最新数据同步 如本地存在则更新 不存在则添加 服务器数据不存在则删除本地相关记录
    // 如果的数据为空 则清空本地数据
    if (!devices || !devices.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
        NSArray *allLocalDevicesArray = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
        for (CDDDevice *obj in allLocalDevicesArray) {
            [obj MR_deleteEntity];
        }
        
        [cdd_bike removeDevices:cdd_bike.devices];
    }
    
    // 服务器数据里查找本地是否存在
    for (NSDictionary * obj in devices) {
        NSInteger device_id = [obj[kCDDSpecialKey_device_id] integerValue];
        BOOL not_exist = YES;
        NSDictionary *result = nil;
        for (CDDDevice * device in cdd_bike.devices) {
            if ([device.device_id integerValue] == device_id) {
                not_exist = NO;
            }
            
            result = obj;
        }
        
        if (not_exist && result) {
            // 待添加的数据
            CDDDevice *device = [CDDDevice MR_createEntity];
            [device mj_setKeyValues:result context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_bike addDevicesObject:device];
        }else {
            // 待更新的数据 不用再添加到数据库
            
        }
    }
    
    // 本地数据查找服务器数据是否存在
    NSArray *sortDesc2 = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
    NSArray *allLocalDeviceArray = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc2];
    for (CDDDevice * obj in allLocalDeviceArray) {
        NSInteger device_id2 = [obj.device_id integerValue];
        BOOL exist = NO;
        NSDictionary *result = nil;
        for (NSDictionary * dict in devices) {
            if ([dict[kCDDSpecialKey_device_id] integerValue] == device_id2) {
                exist = YES;
                result = dict;
            }
        }
        
        if (exist) {
            // 存在 上面已经更新过
            [obj mj_setKeyValues:result context:[NSManagedObjectContext MR_defaultContext]];
        }else {
            // 不存在 就删除
            [cdd_bike removeDevicesObject:obj];
            [obj MR_deleteEntity];
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_bike.devices || !cdd_bike.devices.count) {
        for (NSDictionary *result in devices) {
            CDDDevice *device = [CDDDevice MR_createEntity];
            [device mj_setKeyValues:result context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_bike addDevicesObject:device];
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{kCDDSpecialKey_devices : devices ? : @""}];
    [dict setObject:[NSString stringWithFormat:@"%@", @(user_id)] forKey:kCDDSpecialKey_user_id];
    [dict setObject:[NSString stringWithFormat:@"%@", @(bike_id)] forKey:kCDDSpecialKey_bike_id];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDDDataHelperDeviceListDidChangeNotification object:nil userInfo:dict];
}

- (void)cdd_addOrUpdateDeviceDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id device_id:(NSInteger)device_id device:(NSDictionary *)device {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    CDDBike *cdd_bike = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            cdd_bike = obj;
        }
    }
    
    if (cdd_bike) {
        // 存在bike 则更新他的devices 信息
    }else {
        cdd_bike = [CDDBike MR_createEntity];
        cdd_bike.bike_id = @(bike_id);
        [cdd_account addBikesObject:cdd_bike];
    }
    
    // 本地数据查找新的数据是否存在
    BOOL exist = NO;
    CDDDevice *result = nil;
    NSArray *sortDesc2 = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
    NSArray *allLocalDevicesArray = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc2];
    for (CDDDevice * obj in allLocalDevicesArray) {
        NSInteger device_id2 = [obj.device_id integerValue];
        if (device_id == device_id2) {
            exist = YES;
            result = obj;
        }
    }
    
    if (exist) {
        // 已经存在 则更新记录
        if (device) {
            [result mj_setKeyValues:device context:[NSManagedObjectContext MR_defaultContext]];
        }else {
            [cdd_bike removeDevicesObject:result];
            [result MR_deleteEntity];
        }
    }else {
        // 不存在 就添加新数据
        if (device) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            [cdd_bike mj_setKeyValues:device context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }else {
            
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        if (device) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            [cdd_bike mj_setKeyValues:device context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{kCDDSpecialKey_device : device ? : @""}];
    [dict setObject:[NSString stringWithFormat:@"%@", @(user_id)] forKey:kCDDSpecialKey_user_id];
    [dict setObject:[NSString stringWithFormat:@"%@", @(bike_id)] forKey:kCDDSpecialKey_bike_id];
    [dict setObject:[NSString stringWithFormat:@"%@", @(device_id)] forKey:kCDDSpecialKey_device_id];
    [[NSNotificationCenter defaultCenter] postNotificationName:CDDDataHelperDeviceInfoDidChangeNotification object:nil userInfo:dict];
}

- (void)cdd_addOrUpdateBikeTestResultWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id test_result:(NSDictionary *)test_result {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    // 本地数据查找新的数据是否存在
    BOOL exist = NO;
    CDDBike *result = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            exist = YES;
            result = obj;
        }
    }
    
    if (exist) {
        // 已经存在 则更新记录
        if (test_result) {
            [result mj_setKeyValues:test_result context:[NSManagedObjectContext MR_defaultContext]];
        }else {
            [cdd_account removeBikesObject:result];
            [result MR_deleteEntity];
        }
    }else {
        // 不存在 就添加新数据
        if (test_result) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:test_result context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }else {
            
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        if (test_result) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:test_result context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }
    }
}

- (void)cdd_addOrUpdateBikeLastFindRecordWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id lastFindRecord:(NSDictionary *)lastFindRecord {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    // 本地数据查找新的数据是否存在
    BOOL exist = NO;
    CDDBike *result = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            exist = YES;
            result = obj;
        }
    }
    
    if (exist) {
        // 已经存在 则更新记录
        if (lastFindRecord) {
            [result mj_setKeyValues:lastFindRecord context:[NSManagedObjectContext MR_defaultContext]];
        }else {
            [cdd_account removeBikesObject:result];
            [result MR_deleteEntity];
        }
    }else {
        // 不存在 就添加新数据
        if (lastFindRecord) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:lastFindRecord context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }else {
            
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        if (lastFindRecord) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:lastFindRecord context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }
    }
}

- (void)cdd_addOrUpdateBikeInfoWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id infokey:(NSString *)infokey infovalue:(id)infovalue {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    // 本地数据查找新的数据是否存在
    BOOL exist = NO;
    CDDBike *result = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            exist = YES;
            result = obj;
        }
    }
    
    NSDictionary *add_result = [[NSDictionary alloc] init];
    
    if (!infokey || !infokey.length) {
        return;
    }
    
    if (!infovalue) {
        return;
    }
    
    // 拼成一个记录值
    add_result = @{ infokey : infovalue };
    
    if (exist) {
        // 已经存在 则更新记录
        if (add_result) {
            [result mj_setKeyValues:add_result context:[NSManagedObjectContext MR_defaultContext]];
        }else {
            [cdd_account removeBikesObject:result];
            [result MR_deleteEntity];
        }
    }else {
        // 不存在 就添加新数据
        if (add_result) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:add_result context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }else {
            
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        if (add_result) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:add_result context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }
    }
}

#pragma mark - Find
- (G100AccountDomain *)cdd_findAccountDataWithUser_id:(NSInteger)user_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    G100AccountDomain *g_account = [[G100AccountDomain alloc] init];
    // 首先忽略掉这两个字段
    [g_account mj_setKeyValues:[cdd_account mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_user_info, kCDDSpecialKey_bikes]]];
    
    // 拼接用户信息
    CDDUser *cdd_user = cdd_account.user_info;
    if (cdd_user) {
        G100UserDomain *g_user = [[G100UserDomain alloc] init];
        [g_user mj_setKeyValues:[cdd_user mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_account_info]]];
        g_account.user_info = g_user;
    }
    
    // 拼接车辆列表
    NSMutableArray *bikes = [NSMutableArray arrayWithCapacity:cdd_account.bikes.count];
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            // 拼接设备列表
            NSMutableArray *devieces = [NSMutableArray arrayWithCapacity:cdd_bike.devices.count];
            if (cdd_bike.devices.count) {
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
                NSArray *cdd_devices = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
                for (CDDDevice *cdd_device in cdd_devices) {
                    G100DeviceDomain *g_device = [[G100DeviceDomain alloc] init];
                    [g_device mj_setKeyValues:[cdd_device mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_bike]]];
                    [devieces addObject:g_device];
                }
            }
            g_bike.devices = [devieces copy];
            [bikes addObject:g_bike];
        }
        
        g_account.bikes = [bikes copy];
    }
    
    return g_account;
}

- (G100UserDomain *)cdd_findUserinfoDataWithUser_id:(NSInteger)user_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    CDDUser *cdd_user = cdd_account.user_info;
    if (cdd_user) {
        G100UserDomain *g_user = [[G100UserDomain alloc] init];
        [g_user mj_setKeyValues:[cdd_user mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_account_info]]];
        return g_user;
    }
    
    return nil;
}

- (G100UserDomain *)cdd_findUserinfoDataWithPhone_num:(NSString *)phone_num {
    NSArray *cdd_accounts = [CDDAccount MR_findAll];
    if (!cdd_accounts) {
        return nil;
    }
    
    for (CDDAccount *cdd_account in cdd_accounts) {
        CDDUser *cdd_user = cdd_account.user_info;
        if (cdd_user && [cdd_user.phone_num isEqualToString:phone_num]) {
            G100UserDomain *g_user = [[G100UserDomain alloc] init];
            [g_user mj_setKeyValues:[cdd_user mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_account_info]]];
            return g_user;
        }
    }
    
    return nil;
}

- (NSArray<G100BikeDomain *> *)cdd_findAllBikesDataWithUser_id:(NSInteger)user_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    // 拼接车辆列表
    NSMutableArray *bikes = [NSMutableArray arrayWithCapacity:cdd_account.bikes.count];
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            // 拼接设备列表
            NSMutableArray *devieces = [NSMutableArray arrayWithCapacity:cdd_bike.devices.count];
            if (cdd_bike.devices.count) {
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
                NSArray *cdd_devices = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
                for (CDDDevice *cdd_device in cdd_devices) {
                    G100DeviceDomain *g_device = [[G100DeviceDomain alloc] init];
                    [g_device mj_setKeyValues:[cdd_device mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_bike]]];
                    [devieces addObject:g_device];
                }
            }
            g_bike.devices = [devieces copy];
            [bikes addObject:g_bike];
        }
        
        return [bikes copy];
    }
    
    return nil;
}

- (NSArray <G100BikeDomain *> *)cdd_findAllNormalBikesDataWithUser_id:(NSInteger)user_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    // 拼接车辆列表
    NSMutableArray *bikes = [NSMutableArray arrayWithCapacity:cdd_account.bikes.count];
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            if ([g_bike isNormalBike]) {
                // 拼接设备列表
                NSMutableArray *devieces = [NSMutableArray arrayWithCapacity:cdd_bike.devices.count];
                if (cdd_bike.devices.count) {
                    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
                    NSArray *cdd_devices = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
                    for (CDDDevice *cdd_device in cdd_devices) {
                        G100DeviceDomain *g_device = [[G100DeviceDomain alloc] init];
                        [g_device mj_setKeyValues:[cdd_device mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_bike]]];
                        if ([g_device isNormalDevice]) {
                            [devieces addObject:g_device];
                        }
                    }
                }
                g_bike.devices = [devieces copy];
                [bikes addObject:g_bike];
            }
        }
        
        return [bikes copy];
    }
    
    return nil;
}

- (G100BikeDomain *)cdd_findBikeDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            // 拼接设备列表
            NSMutableArray *devieces = [NSMutableArray arrayWithCapacity:cdd_bike.devices.count];
            if (cdd_bike.devices.count) {
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
                NSArray *cdd_devices = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
                for (CDDDevice *cdd_device in cdd_devices) {
                    G100DeviceDomain *g_device = [[G100DeviceDomain alloc] init];
                    [g_device mj_setKeyValues:[cdd_device mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_bike]]];
                    [devieces addObject:g_device];
                }
            }
            g_bike.devices = [devieces copy];
            
            if (g_bike.bike_id == bike_id) {
                return g_bike;
            }
        }
    }
    
    return nil;
}

- (NSArray<G100DeviceDomain *> *)cdd_findAllDevicesDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            // 拼接设备列表
            NSMutableArray *devieces = [NSMutableArray arrayWithCapacity:cdd_bike.devices.count];
            if (cdd_bike.devices.count) {
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
                NSArray *cdd_devices = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
                for (CDDDevice *cdd_device in cdd_devices) {
                    G100DeviceDomain *g_device = [[G100DeviceDomain alloc] init];
                    [g_device mj_setKeyValues:[cdd_device mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_bike]]];
                    [devieces addObject:g_device];
                }
            }
            g_bike.devices = [devieces copy];
            
            if (g_bike.bike_id == bike_id) {
                return g_bike.devices;
            }
        }
    }
    
    return nil;
}

- (G100DeviceDomain *)cdd_findDeviceDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id device_id:(NSInteger)device_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            if (cdd_bike.devices.count) {
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_device_seq ascending:YES]];
                NSArray *cdd_devices = [cdd_bike.devices sortedArrayUsingDescriptors:sortDesc];
                for (CDDDevice *cdd_device in cdd_devices) {
                    G100DeviceDomain *g_device = [[G100DeviceDomain alloc] init];
                    [g_device mj_setKeyValues:[cdd_device mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_bike]]];
                    
                    if (g_bike.bike_id == bike_id && g_device.device_id == device_id) {
                        return g_device;
                    }
                }
            }
        }
    }
    
    return nil;
}

- (G100TestResultDomain *)cdd_findBikeTestResultWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            if (g_bike.bike_id == bike_id) {
                return g_bike.test_result;
            }
        }
    }
    
    return nil;
}

- (NSDictionary *)cdd_findBikeLastFindRecordWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id{
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            if (g_bike.bike_id == bike_id) {
                return g_bike.lastFindRecord;
            }
        }
    }
    
    return nil;
}

- (void)cdd_addOrUpdateBikeRuntimeWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id bikeRuntime:(NSDictionary *)bikeRuntime {
    if (0 == user_id) {
        return;
    }
    
    CDDAccount *cdd_account = [CDDAccount MR_findFirstOrCreateByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)];
    // 本地数据查找新的数据是否存在
    BOOL exist = NO;
    CDDBike *result = nil;
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
    NSArray *allLocalBikesArray = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
    for (CDDBike * obj in allLocalBikesArray) {
        NSInteger bike_id2 = [obj.bike_id integerValue];
        if (bike_id == bike_id2) {
            exist = YES;
            result = obj;
        }
    }
    
    if (exist) {
        // 已经存在 则更新记录
        if (bikeRuntime) {
            [result mj_setKeyValues:@{@"bikeRuntime" : bikeRuntime} context:[NSManagedObjectContext MR_defaultContext]];
        }else {
            [cdd_account removeBikesObject:result];
            [result MR_deleteEntity];
        }
    }else {
        // 不存在 就添加新数据
        if (bikeRuntime) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:@{@"bikeRuntime" : bikeRuntime} context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }else {
            
        }
    }
    
    // 如果本地数据仍然为空 则和服务器数据同步
    if (!cdd_account.bikes || !cdd_account.bikes.count) {
        if (bikeRuntime) {
            CDDBike *cdd_bike = [CDDBike MR_createEntity];
            [CDDBike mj_setupObjectClassInArray:^NSDictionary *{
                return @{kCDDSpecialKey_devices : [CDDDevice class]};
            }];
            cdd_bike.bike_id = @(bike_id);
            [cdd_bike mj_setKeyValues:bikeRuntime context:[NSManagedObjectContext MR_defaultContext]];
            [cdd_account addBikesObject:cdd_bike];
        }
    }
}

- (NSDictionary *)cdd_findBikeRuntimeWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id {
    if (0 == user_id) {
        return nil;
    }
    
    CDDAccount *cdd_account = [[CDDAccount MR_findByAttribute:kCDDSpecialKey_user_id withValue:@(user_id)] firstObject];
    if (!cdd_account) {
        return nil;
    }
    
    if (cdd_account.bikes.count) {
        NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_seq ascending:YES], [[NSSortDescriptor alloc] initWithKey:kCDDSpecialkey_bike_created_time ascending:YES]];
        NSArray *cdd_bikes = [cdd_account.bikes sortedArrayUsingDescriptors:sortDesc];
        for (CDDBike *cdd_bike in cdd_bikes) {
            G100BikeDomain *g_bike = [[G100BikeDomain alloc] init];
            [g_bike mj_setKeyValues:[cdd_bike mj_keyValuesWithIgnoredKeys:@[kCDDSpecialKey_devices, kCDDSpecialKey_account_info]]];
            
            if (g_bike.bike_id == bike_id) {
                return g_bike.bikeRuntime;
            }
        }
    }
    
    return nil;
}

@end
