//
//  AppDelegate+Pingpp.m
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "AppDelegate+Pingpp.h"

@implementation AppDelegate (Pingpp)

- (void)xks_pingppConfigConfiguration {
    [Pingpp setAppId:kPingPPPayAppKey];
    
#if DEBUG
    [Pingpp setDebugMode:YES];
#elif ADHOC
    [Pingpp setDebugMode:YES];
#endif
}

- (BOOL)xks_pingppHandleOpenURL:(NSURL *)url withCompletion:(PingppCompletion)completion {
    return [Pingpp handleOpenURL:url withCompletion:^(NSString *result, PingppError *error) {
        if ([result isEqualToString:@"success"]) {
            // 支付成功
            
        } else {
            // 支付失败或取消
            NSLog(@"Error: code=%lu msg=%@", (unsigned long)error.code, [error getMsg]);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNPingPPPayResult object:self userInfo:@{ @"result" : result }];
    }];
}

@end
