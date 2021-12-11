//
//  G100ThirdAuthManager.h
//  G100
//
//  Created by yuhanle on 2016/11/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMShare/UMShare.h>
@class UMSocialUserInfoResponse;

/**
 *  授权，分享，UserProfile等操作的回调
 *
 *  @param result 表示回调的结果
 *  @param error  表示回调的错误码
 */
typedef void (^G100ThirdRequestCompletionHandler) (id result, NSError *error);

typedef void (^G100ThirdAuthCallback) (UMSocialUserInfoResponse *thirdAccount, NSError *error);

@interface G100ThirdAuthManager : NSObject

+ (void)getThirdWechatAccountWithPresentVC:(UIViewController*)presentVC complete:(G100ThirdAuthCallback)callback;

+ (void)getThirdSinaAccountWithPresentVC:(UIViewController*)presentVC complete:(G100ThirdAuthCallback)callback;

+ (void)getThirdQQAccountWithPresentVC:(UIViewController*)presentVC complete:(G100ThirdAuthCallback)callback;

+ (void)cancelAuthWithPlatform:(UMSocialPlatformType)platformType completion:(G100ThirdRequestCompletionHandler)completion;

@end
