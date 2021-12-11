//
//  G100Api.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ApiInvoker.h"
#import "ApiRequest.h"

#define G100ApiHelper [G100Api sharedInstance]

@interface G100Api : ApiInvoker

@property (nonatomic, assign) BOOL allowNetRequest; //!< 是否允许发送请求 NO 先add 到内存中

+ (instancetype)sharedInstance;

/**
 *  默认post请求 带token 非https请求
 *
 *  @param api        接口地址
 *  @param apiRequest 请求实例
 *  @param callback   接口回调
 *  @return ApiRequest 实例
 */
- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest callback:(API_CALLBACK)callback;
/**
 *  是否带token请求接口
 *
 *  @param api        接口地址
 *  @param apiRequest 请求实例
 *  @param hasToken   是否带token
 *  @param callback   接口回调
 *  @return ApiRequest 实例
 */
- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest token:(BOOL)hasToken callback:(API_CALLBACK)callback;
/**
 *  是否带token的https请求
 *
 *  @param api        接口地址
 *  @param apiRequest 请求实例
 *  @param hasToken   是否带token
 *  @param hasHttps   是否是https
 *  @param callback   接口回调
 *  @return ApiRequest 实例
 */
- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest token:(BOOL)hasToken https:(BOOL)isHttps callback:(API_CALLBACK)callback;
/**
 *  是否带token的https请求 (控制timeout)
 *
 *  @param api              接口地址
 *  @param apiRequest       请求实例
 *  @param hasToken         是否带token
 *  @param hasHttps         是否是https
 *  @param timeoutInSeconds 请求超时设置
 *  @param callback         接口回调
 *  @return ApiRequest 实例
 */
- (ApiRequest *)postApi:(NSString *)api andRequest:(ApiRequest *)apiRequest token:(BOOL)hasToken https:(BOOL)isHttps timeoutInSeconds:(NSInteger)timeoutInSeconds callback:(API_CALLBACK)callback;
/**
 *  上传图像接口
 *
 *  @param api              接口地址
 *  @param apiRequest       请求实例
 *  @param imageArray       资源数组
 *  @param nameArray        资源名字
 *  @param progressCallback 上传中回调
 *  @param callback         接口回调
 *  @return ApiRequest 实例
 */
- (ApiRequest *)postImageApi:(NSString *)api andRequest:(ApiRequest *)apiRequest imageArray:(NSArray*)imageArray nameArray:(NSArray*)nameArray progress:(Progress_Callback)progressCallback callback:(API_CALLBACK)callback;

@end
