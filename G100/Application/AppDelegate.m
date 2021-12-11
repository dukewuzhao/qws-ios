//
//  AppDelegate.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Config.h"

#import "WSGuidePage.h"
#import "G100UserApi.h"
#import "ADPageModule.h"
#import "EBCheckVersion.h"
#import "G100LocationUploader.h"
#import "G100MainViewController.h"

@interface AppDelegate () {
    BOOL _appRootHasActived;
}

@end

@implementation AppDelegate

#pragma mark - Lazy Load
- (G100MainViewController *)mainViewController {
    if (!_mainViewController) {
        _mainViewController = [[G100MainViewController alloc] init];
    }
    return _mainViewController;
}

#pragma mark - Main Entreny
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self xks_configurationApplication:application launchingOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *viewController = [[UIViewController alloc] init];
    self.mainNavc = [[TLNavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.mainNavc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 预加载主页
    [self mainViewController];
    [[ADPageModule pageModule] loadADPage];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self xks_configurationApplicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self xks_configurationApplicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    G100ApiHelper.allowNetRequest = YES;
    if (!_appRootHasActived) {
        return;
    }
    
    if (IsLogin() && ![UserManager shareManager].remoteLogin) {
        [self validateToken:(^(BOOL isSuccess) {
            if (![UserManager shareManager].remoteLogin && isSuccess) {
                [[UserManager shareManager] startPostPush];
                [[UserManager shareManager] startUpdateInfo];
            }
        })];
    }
    
    [self xks_configurationApplicationDidBecomeActive:application];
}

#pragma mark - 检查版本更新
- (void)AppCheckVersion {
    [EBCheckVersion setAppId:APP_ID];
    [EBCheckVersion appLaunched:YES];
}

#pragma mark - 判断token有效性
-(void)validateToken:(void (^)(BOOL isSuccess))scallback {
    if (!IsLogin() && ![UserManager shareManager].remoteLogin) {
        return;
    }
    
    NSString *token = [[UserManager shareManager] token];
    NSString *devid = DeviceAndOSInfo;
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (scallback) {
            scallback(requestSuccess);
        }
    };
    
    [[G100UserApi sharedInstance] sv_validateTokenWithToken:token devid:devid callback:callback];
}

#pragma mark - 监听消息处理
- (void)noti_showGuideView {
    WSGuidePage *guidePage = [[WSGuidePage alloc] init];
    [guidePage showGuidePageViewOnViewController:self.window.rootViewController animated:YES immediatly:NO];
}

- (void)noti_enterMainView {
    [UserManager shareManager].appHasActived = YES;
    
    if (!_appRootHasActived) {
        _appRootHasActived = YES;
        [self validateToken:^(BOOL isSuccess) {
            if (![UserManager shareManager].remoteLogin && isSuccess) {
                [[UserManager shareManager] startPostPush];
                [[UserManager shareManager] startUpdateInfo];
            }
        }];
    }
    
    NSMutableArray *vcs = [[self.mainNavc viewControllers] mutableCopy];
    [vcs removeAllObjects];
    [vcs addObject:self.mainViewController];
    [self.mainNavc setViewControllers:vcs animated:NO];
    
    // 启动时隐藏状态栏，进入app后显示
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // 请求位置信息
    [[G100LocationUploader uploader] lmu_updateLocation];
    // 检查软件版本号
    [self AppCheckVersion];
}

@end
