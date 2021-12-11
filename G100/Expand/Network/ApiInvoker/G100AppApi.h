//
//  G100AppApi.h
//  G100
//
//  Created by yuhanle on 2017/3/16.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100AppApi : NSObject

+ (instancetype)sharedInstance;

/**
 检查软件版本

 @param platform 平台  A android I ios
 @param channel 渠道：0 通用版 1 某某专用版 2 ...
 @param version 版本号
 @param callback 接口回调
 @return 请求实例
 */
- (ApiRequest *)checkUpdateWithPlatform:(NSString *)platform channel:(NSString *)channel version:(NSString *)version callback:(API_CALLBACK)callback;

@end
