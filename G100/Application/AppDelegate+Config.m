//
//  AppDelegate+Config.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Config.h"
#import "AppDelegate+iRater.h"
#import "AppDelegate+Notification.h"
#import "AppDelegate+Umeng.h"
#import "AppDelegate+Pingpp.h"
#import "AppDelegate+Alibc.h"
#import "AppDelegate+AMap.h"
#import "AppDelegate+DataBase.h"
#import "AppDelegate+Monitor.h"
#import "RSSwizzler.h"
#import "G100PopBoxHelper.h"
@implementation AppDelegate (Config)

- (void)xks_configurationApplication:(UIApplication *)application launchingOptions:(NSDictionary *)launchOptions {
    [RSSwizzler rs_swizzle];
    
    [IQKeyHelper setShouldPlayInputClicks:YES];
    [IQKeyHelper setShouldResignOnTouchOutside:YES];
    [IQKeyHelper setEnableAutoToolbar:NO];
    
    [self xks_dataBaseConfigConfiguration];
    [self xks_umengConfigConfiguration];
    [self xks_alibcConfigConfiguration];
    [self xks_pingppConfigConfiguration];
    [self xks_amapConfigConfiguration];
    [self xks_appiRaterConfiguration];
    [self xks_monitorConfigConfiguration];
    [self xks_notiApplication:application didFinishLaunchingWithOptions:launchOptions];
    [[UserManager shareManager] setupUa];
    [[G100SchemeHelper shareInstance] addQwsScheme];
    [[G100PopBoxHelper sharedInstance] startupPopBoxService];
    
    [[UIButton appearance] setExclusiveTouch:YES];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [UINavigationBar appearance].titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                                          NSFontAttributeName : [UIFont boldSystemFontOfSize:17] };
    
#if DEBUG
    // [self showOverLay];
#endif
}

- (void)xks_configurationApplicationDidEnterBackground:(UIApplication *)application {
    [[UserManager shareManager] stopPostPush];
    [[UserManager shareManager] stopUpdateInfo];
    
    /** 后台持续运行 -> 暂不使用后台权限
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
     */
}

- (void)xks_configurationApplicationDidBecomeActive:(UIApplication *)application {
    [self xks_notiApplicationDidBecomeActive:application];
}

- (void)xks_configurationApplicationWillEnterForeground:(UIApplication *)application {
    [self xks_appiRaterEnteredForeground];
    [[G100PopBoxHelper sharedInstance] startupPopBoxService];
}

#pragma mark - Super Method
- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGNStartNotificationTest object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    G100ApiHelper.allowNetRequest = YES;
    
    if (![self xks_alibcApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation]) {
        [self xks_pingppHandleOpenURL:url withCompletion:nil];
        [self xks_umengHandleOpenURL:url];
        if ([G100Router canOpenURL:url.absoluteString]) {
            [G100Router openURL:url.absoluteString];
        }
    }
    
    return YES;
}

// iOS 9 以上请用这个
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    G100ApiHelper.allowNetRequest = YES;
    
    if (![self xks_alibcApplication:app openURL:url options:options]) {
        [self xks_pingppHandleOpenURL:url withCompletion:nil];
        [self xks_umengHandleOpenURL:url];
        
        if ([G100Router canOpenURL:url.absoluteString]) {
            [G100Router openURL:url.absoluteString];
        }
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    G100ApiHelper.allowNetRequest = YES;
    
    [self xks_pingppHandleOpenURL:url withCompletion:nil];
    [self xks_umengHandleOpenURL:url];
    if ([G100Router canOpenURL:url.absoluteString]) {
        [G100Router openURL:url.absoluteString];
    }
    
    return YES;
}

#pragma mark - Private Method
- (void)showOverLay {
    Class class = NSClassFromString(@"UIDebuggingInformationOverlay");
    SEL selector = NSSelectorFromString(@"prepareDebuggingOverlay");
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [class performSelector:selector];
    SEL overlaySelector = NSSelectorFromString(@"overlay");
    SEL toggleVisibilitySelector = NSSelectorFromString(@"toggleVisibility");
    
    [[class performSelector:overlaySelector] performSelector:toggleVisibilitySelector];
#pragma clang diagnostic pop
}

@end
