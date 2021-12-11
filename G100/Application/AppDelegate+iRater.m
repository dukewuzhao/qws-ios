//
//  AppDelegate+iRater.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+iRater.h"
#import "Appirater.h"

@implementation AppDelegate (iRater)

- (void)xks_appiRaterConfiguration {
    [Appirater setAppId:APP_ID];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:3];
    [Appirater setTimeBeforeDeclined:30];
    [Appirater setDebug:NO];
    
    [Appirater setCustomAlertTitle:@"给骑卫士打个分吧"];
    [Appirater setCustomAlertMessage:@"琪琪正在努力的为了您的安全保驾护航，赶紧为琪琪的工作打个分吧"];
    [Appirater setCustomAlertRateButtonTitle:@"去评价 骑卫士"];
    [Appirater setCustomAlertRateLaterButtonTitle:@"稍后提醒我"];
    [Appirater setCustomAlertCancelButtonTitle:@"不，谢谢"];
    // 这句一定要放在最后面
    [Appirater appLaunched:YES];
}

- (void)xks_appiRaterEnteredForeground {
    [Appirater appEnteredForeground:YES];
}

@end
