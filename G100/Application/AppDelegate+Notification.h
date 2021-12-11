//
//  AppDelegate+Notification.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Notification)

/**
 启动APP 时 配置推送相关参数

 @param application APP
 @param launchOptions 启动参数
 @return YES/NO
 */
- (BOOL)xks_notiApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 APP 进入激活状态

 @param application APP
 */
- (void)xks_notiApplicationDidBecomeActive:(UIApplication *)application;

@end
