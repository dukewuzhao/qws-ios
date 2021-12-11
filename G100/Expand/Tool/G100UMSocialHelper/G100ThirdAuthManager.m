//
//  G100ThirdAuthManager.m
//  G100
//
//  Created by yuhanle on 2016/11/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100ThirdAuthManager.h"

@implementation G100ThirdAuthManager

+ (void)getThirdWechatAccountWithPresentVC:(UIViewController *)presentVC complete:(G100ThirdAuthCallback)callback {
    [G100ThirdAuthManager getThirdAccountWithPlatform:UMSocialPlatformType_WechatSession presentVC:presentVC complete:callback];
}
+ (void)getThirdSinaAccountWithPresentVC:(UIViewController *)presentVC complete:(G100ThirdAuthCallback)callback {
    [G100ThirdAuthManager getThirdAccountWithPlatform:UMSocialPlatformType_Sina presentVC:presentVC complete:callback];
}

+ (void)getThirdQQAccountWithPresentVC:(UIViewController *)presentVC complete:(G100ThirdAuthCallback)callback {
    [G100ThirdAuthManager getThirdAccountWithPlatform:UMSocialPlatformType_QQ presentVC:presentVC complete:callback];
}

+ (void)getThirdAccountWithPlatform:(UMSocialPlatformType)platformType presentVC:(UIViewController *)presentVC complete:(G100ThirdAuthCallback)callback {
    [[UMSocialManager defaultManager] cancelAuthWithPlatform:platformType completion:^(id result, NSError *error) {
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:presentVC completion:^(id result, NSError *error) {
            if (error) {
                
            } else {
                UMSocialUserInfoResponse *resp = result;
                
                // 授权信息
                NSLog(@"uid: %@", resp.uid);
                NSLog(@"openid: %@", resp.openid);
                NSLog(@"accessToken: %@", resp.accessToken);
                NSLog(@"expiration: %@", resp.expiration);
                
                // 用户信息
                NSLog(@"name: %@", resp.name);
                NSLog(@"iconurl: %@", resp.iconurl);
                NSLog(@"gender: %@", resp.gender);
                
                // 第三方平台SDK源数据
                NSLog(@"originalResponse: %@", resp.originalResponse);
            }
            
            if (callback) {
                callback(result, error);
            }
        }];
    }];
}

+ (void)cancelAuthWithPlatform:(UMSocialPlatformType)platformType completion:(G100ThirdRequestCompletionHandler)completion {
    [[UMSocialManager defaultManager] cancelAuthWithPlatform:(UMSocialPlatformType)platformType completion:completion];
}

@end
