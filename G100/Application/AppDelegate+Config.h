//
//  AppDelegate+Config.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Config)

/**
 基础配置
 */
- (void)xks_configurationApplication:(UIApplication *)application launchingOptions:(NSDictionary *)launchOptions;

/**
 APP 进入后台

 @param application APP
 */
- (void)xks_configurationApplicationDidEnterBackground:(UIApplication *)application;

/**
 APP 进入前台

 @param application APP
 */
- (void)xks_configurationApplicationDidBecomeActive:(UIApplication *)application;

/**
 APP 即将进入前台

 @param application APP
 */
- (void)xks_configurationApplicationWillEnterForeground:(UIApplication *)application;

@end
