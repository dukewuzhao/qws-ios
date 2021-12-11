//
//  AppDelegate+iRater.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (iRater)

/**
 配置引导用户评分模块
 */
- (void)xks_appiRaterConfiguration;

/**
 应用切入至前台 -> 通知引导评分
 */
- (void)xks_appiRaterEnteredForeground;

@end
