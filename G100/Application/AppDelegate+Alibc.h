//
//  AppDelegate+Alibc.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Alibc)

/**
 配置阿里云电商业务
 */
- (void)xks_alibcConfigConfiguration;

/**
 * App 回跳处理, 适用于 iOS 9 以下的回调接口
 
 @param application application
 @param url url
 @param sourceApplication sourceApplication
 @param annotation annotation
 @return handled or nor
 */
- (BOOL)xks_alibcApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 * App 回跳处理, 适用于 iOS 9 起的回调接口
 
 @param annotation annotation
 @param url url
 @param options options
 @return handled or nor
 */
- (BOOL)xks_alibcApplication:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options NS_AVAILABLE_IOS(9_0);

@end
