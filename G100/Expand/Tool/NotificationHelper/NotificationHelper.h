//
//  NotificationHelper.h
//  G100
//
//  Created by Tilink on 15/9/16.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100PushMsgDomain.h"
#import "JPUSHService.h"

extern NSString * const NHRemoteNotiCategoryIdentifierSeriousAlarm;
extern NSString * const NHRemoteNotiActionIdentifierSeriousAlarmIgnore;
extern NSString * const NHRemoteNotiActionIdentifierSeriousAlarmCheckDetail;

@interface NotificationHelper : NSObject

+ (instancetype)shareInstance;

/**
 *  @brief  判断用户是否开启应用的消息推送
 *
 *  @return YES/NO  YES 接受  NO 拒绝
 */
- (BOOL)notificationServicesEnabled;

/**
 跳转系统推送设置页面
 
 @return YES/NO
 */
+ (BOOL)openSystemNotificationSettingPage;

/**
 判断是否可以打开推送设置页面
 
 @return YES/NO
 */
+ (BOOL)canOpenSystemNotificationSettingPage;

/**
 *  @brief   根据key移除本地通知
 *  @param notificationKey   对应的通知标识符
 *
 */
- (void)removeLocalNotificationByKey:(NSString *)notificationKey;
/**
 *  @brief  移除所有本地通知
 */
- (void)removeAllLocalNotification;
/**
 *  @brief  注册本地通知
 */
- (void)registerLocalNotification:(UIApplication *)application;

/**
 *  @brief  注册远程推送
 *
 *  @param application
 */
- (void)registerRemoteNotification:(UIApplication *)application launchingWithOptions:(NSDictionary *)launchOptions;

/**
 *  @brief  上传token极光服务器
 *
 *  @param application 当前应用程序
 *  @param deviceToken 注册推送token
 */
- (void)application:(UIApplication *)application didRegisterForJPushRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 *  @brief  注册推送token失败
 *
 *  @param application 当前应用程序
 *  @param error       错误代码
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 *  @brief  收到远程推送消息
 *
 *  @param application 当前应用程序
 *  @param userInfo    推送消息内容
 */
- (void)application:(UIApplication *)application didReceiveJPushRemoteNotification:(NSDictionary *)userInfo;

/**
 *  @brief  收到极光离线消息
 *
 *  @param application 当前应用程序
 *  @param userInfo    离线消息内容
 */
- (void)application:(UIApplication *)application didReceiveJPushOfflineMessage:(NSNotification *)notification;

/**
 *  @brief  收到极光本地通知
 *
 *  @param application 当前应用程序
 *  @param userInfo    本地通知内容
 */
- (void)application:(UIApplication *)application didReceiveJPushLocalNotification:(UILocalNotification *)notification;

// 设置角标数字
- (void)nh_newBadge:(NSInteger)badge;

/**
 *  角标数减一
 */
- (void)nh_quickDecreaseBadge;

/**
 处理暂未处理的离线消息
 */
- (void)nh_handleOfflineNotis:(UIApplication *)application;

@end
