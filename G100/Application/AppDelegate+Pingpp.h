//
//  AppDelegate+Pingpp.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate.h"
#import "Pingpp.h"

@interface AppDelegate (Pingpp)

/**
 配置Ping++ 支付业务
 */
- (void)xks_pingppConfigConfiguration;

/**
 告知 Ping++ 支付结果

 @param url 支付数据
 @param completion 回调
 @return YES/NO
 */
- (BOOL)xks_pingppHandleOpenURL:(NSURL *)url withCompletion:(PingppCompletion)completion;

@end
