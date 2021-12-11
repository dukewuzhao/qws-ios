//
//  AppDelegate+Alibc.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Alibc.h"
#import <AlibcTradeSDK/AlibcTradeSDK.h>
#import <AlibabaAuthSDK/ALBBSDK.h>
#import <AlibcLinkPartnerSDK/ALPTBLinkPartnerSDK.h>

@implementation AppDelegate (Alibc)

- (void)xks_alibcConfigConfiguration {
    // 百川平台基础SDK初始化，加载并初始化各个业务能力插件
    [[AlibcTradeSDK sharedInstance] asyncInitWithSuccess:^{
        
    } failure:^(NSError *error) {
        NSLog(@"Init failed: %@", error.description);
    }];
    
    //默认调试模式打开日志,release关闭,可以不调用下面的函数
#if DEBUG
    [[AlibcTradeSDK sharedInstance] setDebugLogOpen:YES];
#elif ADHOC
    [[AlibcTradeSDK sharedInstance] setDebugLogOpen:YES];
#endif
    
    // 设置全局配置，是否强制使用h5
    [[AlibcTradeSDK sharedInstance] setIsForceH5:YES];
    [[AlibcTradeSDK sharedInstance] setShouldUseAlipayNative:YES];
    
    [[AlibcTradeSDK sharedInstance] setIsvVersion:[G100InfoHelper shareInstance].appVersion];
    [[AlibcTradeSDK sharedInstance] setISVCode:@"360qws"];
    
    [[ALBBSDK sharedInstance] setAppkey:@"23379061"];
    [[ALBBSDK sharedInstance] setAuthOption:NormalAuth];
    
    [ALPTBLinkPartnerSDK initWithAppkey:@"23379061"];
    //[ALPTBLinkPartnerSDK setAuthSecret:@"4d5d80ee21347262bad57da0cacbd019"];
}

- (BOOL)xks_alibcApplication:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[AlibcTradeSDK sharedInstance] application:application openURL:url options:options];
}

- (BOOL)xks_alibcApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[AlibcTradeSDK sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

@end
