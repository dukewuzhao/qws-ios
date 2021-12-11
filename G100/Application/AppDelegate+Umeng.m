//
//  AppDelegate+Umeng.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Umeng.h"
#import "G100UMSocialHelper.h"
//#import <UMCommon/UMConfigure.h>
@implementation AppDelegate (Umeng)

- (void)xks_umengConfigConfiguration {
    //[UMConfigure initWithAppkey:UmengKey channel:ISProduct ? @"APPS_A001" : @"BETA_A001"];
    //[UMConfigure setEncryptEnabled:YES];
#if DEBUG
    //[UMConfigure setLogEnabled:YES];
#elif ADHOC
    //[UMConfigure setLogEnabled:YES];
#endif
    
    // 友盟社会化组件
    [G100UMSocialHelper socialConfiguration];
}

- (BOOL)xks_umengHandleOpenURL:(NSURL *)url {
    return [[G100UMSocialHelper shareInstance] handleOpenURL:url];
}

@end
