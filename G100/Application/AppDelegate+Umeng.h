//
//  AppDelegate+Umeng.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Umeng)

/**
 配置友盟相关服务
 */
- (void)xks_umengConfigConfiguration;

/**
 调用处理参数

 @param url 处理链接
 @return YES/NO
 */
- (BOOL)xks_umengHandleOpenURL:(NSURL *)url;

@end
