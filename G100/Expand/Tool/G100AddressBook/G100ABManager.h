//
//  G100ABManager.h
//  G100
//
//  Created by yuhanle on 2017/2/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ABCheckUpdateComplete)(BOOL update, id res, NSError *error);
typedef void(^ABWriteComplete)(NSError *error);

typedef enum : NSUInteger {
    AB_CheckUpdateTypeAll = 0,
    AB_CheckUpdateTypeKefu,
    AB_CheckUpdateTypeAlarm,
} AB_CheckUpdateType;

@class ABListDomain;
@class ABPhoneDomain;
@class ABManagerDomain;
@interface G100ABManager : NSObject

+ (instancetype)sharedInstance;

/**
 检查通讯录权限

 @param block 通讯录权限回调
 */
- (void)checkAddressBookAuthorization:(void (^)(bool isAuthorized))block;

/**
 检查云端通讯录是否有变化
 */
- (void)ab_checkUpdate:(ABCheckUpdateComplete)checkComplete;

/**
 检查云端通讯录是否有变化

 @param type 标识检查通讯录类型
 @param checkComplete 检查结果回调
 */
- (void)ab_checkUpdateWithType:(AB_CheckUpdateType)type checkComplete:(ABCheckUpdateComplete)checkComplete;

/**
 开始写入更新后的通讯录
 */
- (void)ab_startWrite:(ABWriteComplete)writeComplete;

/**
 开始写入更新后的通讯录
 
 @param type 标识检查通讯录类型 如果type == 2 写入时无需检查用户是否开通报警提醒功能
 @param checkComplete 检查结果回调
 */
- (void)ab_startWriteWithType:(AB_CheckUpdateType)type writeComplete:(ABWriteComplete)writeComplete;

@end

@interface ABListDomain : NSObject

@property (nonatomic, strong) NSArray <ABPhoneDomain *> *list; //!< 包含客服电话和告警电话两类，如有别的类型可添加

- (instancetype)initWithLocalRes:(NSDictionary *)res;

@end

@interface ABPhoneDomain : NSObject

@property (nonatomic, copy) NSString *md5; //!< 通讯录 md5，用于简单校验电话号码是否有变更
@property (nonatomic, copy) NSString *phone; //!< 电话号码
@property (nonatomic, strong) NSArray *phones; //!< 电话号码数组
@property (nonatomic, assign) NSInteger type; //!< 号码类型，1-客服电话 2-报警电话
@property (nonatomic, copy) NSString *name; //!< 名称

@end
