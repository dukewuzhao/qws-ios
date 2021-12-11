//
//  AppDelegate+Notification.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Notification.h"
#import "NotificationHelper.h"

@implementation AppDelegate (Notification)

- (BOOL)xks_notiApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NotificationHelper shareInstance] registerRemoteNotification:application launchingWithOptions:launchOptions];
    return YES;
}

- (void)xks_notiApplicationDidBecomeActive:(UIApplication *)application {
    [[NotificationHelper shareInstance] nh_handleOfflineNotis:application];
}

#pragma mark - Super Method
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NotificationHelper shareInstance] application:application didRegisterForJPushRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NotificationHelper shareInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NotificationHelper shareInstance] application:application didReceiveJPushRemoteNotification:userInfo];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    
}

// Called when your app has been activated by the user selecting an action from a remote notification.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:NHRemoteNotiActionIdentifierSeriousAlarmIgnore]) {
        
    }else if ([identifier isEqualToString:NHRemoteNotiActionIdentifierSeriousAlarmCheckDetail]) {
        [[NotificationHelper shareInstance] application:application didReceiveJPushRemoteNotification:userInfo];
    }else {
        [[NotificationHelper shareInstance] application:application didReceiveJPushRemoteNotification:userInfo];
    }
    completionHandler();
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[NotificationHelper shareInstance] application:application didReceiveJPushRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
#endif

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSString *identifier = [notification.userInfo objectForKey:@"id"];
    
    if ([identifier hasContainString:@"com.tilink.360qws"]) {
        [[NotificationHelper shareInstance] application:application didReceiveJPushLocalNotification:notification];
    } else {
        
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        
    }
    return YES;
}

@end
