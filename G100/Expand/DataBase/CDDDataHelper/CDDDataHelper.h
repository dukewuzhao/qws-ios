//
//  CDDDataHelper.h
//  CoreDataDemo
//
//  Created by yuhanle on 16/7/8.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MagicalRecord/MagicalRecord.h>

extern NSString * const CDDDataHelperUserInfoDidChangeNotification;
extern NSString * const CDDDataHelperBikeListDidChangeNotification;
extern NSString * const CDDDataHelperBikeInfoDidChangeNotification;
extern NSString * const CDDDataHelperDeviceListDidChangeNotification;
extern NSString * const CDDDataHelperDeviceInfoDidChangeNotification;

typedef enum : NSUInteger {
    BikeListNormalType,
    BikeListAddType,
    BikeListDeleteType,
} BikeListUpdateType;

typedef enum : NSUInteger {
    BikeInfoNormalType,
    BikeInfoAddType,
    BikeInfoDeleteType,
} BikeInfoUpdateType;

@class G100BaseDomain, G100AccountDomain, G100UserDomain, G100BikeDomain, G100DeviceDomain, G100TestResultDomain;

@interface CDDDataHelper : NSObject

/**
 *  实例化管理器
 *
 *  @return 管理器实例
 */
+ (instancetype)cdd_sharedInstace;



/********************************************************* 存储更新删除 本地数据库中的信息*****************************************************/
/**
 *  存储和更新类似 传入对应的的id helper会自己判断新增记录还是更新记录
 *  需要删除某条记录的话对应数据字段值传空
 *  没有字段的记录不修改
 */
/**
 *  添加或更新帐号信息
 *
 *  @param user_id 帐号id
 *  @param account 帐号信息
 */
- (void)cdd_addOrUpdateAccountDataWithUser_id:(NSInteger)user_id account:(NSDictionary *)account;
/**
 *  添加或更新用户信息
 *
 *  @param user_id  用户id
 *  @param userinfo 用户信息
 */
- (void)cdd_addOrUpdateUserInfoDataWithUser_id:(NSInteger)user_id userinfo:(NSDictionary *)userinfo;
/**
 *  添加或更新车辆列表信息
 *
 *  @param user_id 用户id
 *  @param bikes   车辆列表
 */
- (void)cdd_addOrUpdateBikesDataWithUser_id:(NSInteger)user_id bikes:(NSArray *)bikes;
/**
 *  添加或更新车辆列表信息
 *
 *  @param user_id 用户id
 *  @param bikes   车辆列表
 *  @updateType    车辆列表更新类型
 */
- (void)cdd_addOrUpdateBikesDataWithUser_id:(NSInteger)user_id bikes:(NSArray *)bikes updateType:(BikeListUpdateType)updateType;
/**
 *  添加或更新车辆信息
 *
 *  @param user_id 用户id
 *  @param bike_id 车辆id
 *  @param bike    车辆信息
 */
- (void)cdd_addOrUpdateBikeDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id bike:(NSDictionary *)bike;
- (void)cdd_addOrUpdateBikeDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id bike:(NSDictionary *)bike updateType:(BikeInfoUpdateType)updateType;
/**
 *  添加或更新设备列表信息
 *
 *  @param user_id 用户id
 *  @param bike_id 车辆id
 *  @param devices 设备列表
 */
- (void)cdd_addOrUpdateDevicesDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id devices:(NSArray *)devices;
/**
 *  添加或更新设备信息
 *
 *  @param user_id   用户id
 *  @param bike_id   车辆id
 *  @param device_id 设备id
 *  @param device    设备信息
 */
- (void)cdd_addOrUpdateDeviceDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id device_id:(NSInteger)device_id device:(NSDictionary *)device;
/**
 *  添加或更新车辆的评测结果
 *
 *  @param user_id     用户id
 *  @param bike_id     车辆id
 *  @param test_result 评测结果
 */
- (void)cdd_addOrUpdateBikeTestResultWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id test_result:(NSDictionary *)test_result;

/**
 *  添加或更新车辆的最新寻车记录
 *
 *  @param user_id     用户id
 *  @param bike_id     车辆id
 *  @param lastFindRecord 寻车最新记录
 */
- (void)cdd_addOrUpdateBikeLastFindRecordWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id lastFindRecord:(NSDictionary *)lastFindRecord;
/**
 添加或更新车辆的实时数据信息

 @param user_id 用户id
 @param bike_id 车辆id
 @param bikeRuntime 实时数据信息
 */
- (void)cdd_addOrUpdateBikeRuntimeWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id bikeRuntime:(NSDictionary *)bikeRuntime;
/**
 添加或更新车辆的某个数据

 @param user_id 用户id
 @param bike_id 车辆id
 @param infokey 数据key
 @param infovalue 数据值 （NSNumber || 基础类型）
 */
- (void)cdd_addOrUpdateBikeInfoWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id infokey:(NSString *)infokey infovalue:(id)infovalue;

/************************************************************* 查找 本地数据库中的信息*******************************************************/
/** 
 *  接口中的字段必填 否则默认第一条记录
 *  暂不提供键值过滤的功能
 *  需要某条记录的特定字段 可以直接从记录的模型中提取
 */
/**
 *  查找某帐号信息
 *
 *  @param user_id 帐号id
 *
 *  @return 帐号信息模型
 */
- (G100AccountDomain *)cdd_findAccountDataWithUser_id:(NSInteger)user_id;
/**
 *  查找某用户信息
 *
 *  @param user_id 用户id
 *
 *  @return 用户信息模型
 */
- (G100UserDomain *)cdd_findUserinfoDataWithUser_id:(NSInteger)user_id;
/**
 *  根据手机号查找用户信息
 *
 *  @param phoneNumber 手机号
 *
 *  @return 用户信息模型
 */
- (G100UserDomain *)cdd_findUserinfoDataWithPhone_num:(NSString *)phone_num;
/**
 *  查找某用户的所有车辆列表
 *
 *  @param user_id 用户id
 *
 *  @return 车辆列表 <G100BaseDomain>
 */
- (NSArray <G100BikeDomain *> *)cdd_findAllBikesDataWithUser_id:(NSInteger)user_id;
/**
 *  查找某用户的所有正常状态车辆列表
 *
 *  @param user_id 用户id
 *
 *  @return 车辆列表 <G100BaseDomain>
 */
- (NSArray <G100BikeDomain *> *)cdd_findAllNormalBikesDataWithUser_id:(NSInteger)user_id;
/**
 *  查找莫用户的某辆车信息
 *
 *  @param user_id 用户id
 *  @param bike_id 车辆id
 *
 *  @return 车辆信息模型
 */
- (G100BikeDomain *)cdd_findBikeDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id;
/**
 *  查找某用户某辆车的设备列表
 *
 *  @param user_id 用户id
 *  @param bike_id 车辆id
 *
 *  @return 设备列表 <G100BaseDomain>
 */
- (NSArray <G100DeviceDomain *> *)cdd_findAllDevicesDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id;
/**
 *  查找某用户的某辆车某设备信息
 *
 *  @param user_id   用户id
 *  @param bike_id   车辆id
 *  @param device_id 设备id
 *
 *  @return 设备信息模型
 */
- (G100DeviceDomain *)cdd_findDeviceDataWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id device_id:(NSInteger)device_id;
/**
 *  查找某用户的某辆车评测结果
 *
 *  @param user_id 用户id
 *  @param bike_id 车辆id
 *
 *  @return 评测结果模型
 */
- (G100TestResultDomain *)cdd_findBikeTestResultWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id;
/**
 *  查找某用户的某辆车最新寻车记录
 *
 *  @param user_id 用户id
 *  @param bike_id 车辆id
 *
 *  @return 最新寻车记录字典
 */
- (NSDictionary *)cdd_findBikeLastFindRecordWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id;
/**
 查找某用户的某辆车实时数据

 @param user_id 用户id
 @param bike_id 车辆id
 @return 实时数据
 */
- (NSDictionary *)cdd_findBikeRuntimeWithUser_id:(NSInteger)user_id bike_id:(NSInteger)bike_id;

@end
