//
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AFIdonglerApiInvoker.h"
#import "ApiResponse.h"
#import "ApiRequest.h"

@interface ApiInvoker : NSObject

@property (nonatomic, copy) NSString *token;    //!< token

/**
 *  设置请求http地址 &https 地址
 *
 *  @param apiBaseUrl      http 地址
 *  @param apiHttpsBaseUrl https 地址
 */
- (void)setupApiBaseUrl:(NSString *)apiBaseUrl apiHttpsBaseUrl:(NSString *)apiHttpsBaseUrl;

/**
 *  发起请求
 *
 *  @param api        请求地址
 *  @param httpMethod 请求方式
 *  @param apiRequest 请求实例
 *  @param callback   接口回调
 */
- (void)requestApi:(NSString *)api withMethod:(NSString *)httpMethod andRequest:(ApiRequest *)apiRequest callback:(API_CALLBACK)callback;

/**
 *  发起请求
 *
 *  @param api        请求地址
 *  @param httpMethod 请求方式
 *  @param apiRequest 请求实例
 *  @param callback   接口回调
 */
- (void)requestApi:(NSString *)api andRequest:(ApiRequest *)apiRequest imageArray:(NSArray*)imageArray nameArray:(NSArray*)nameArray progress:(Progress_Callback)progressCallback callback:(API_CALLBACK)callback;

// 公共的处理错误信息
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse;
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse error:(NSError *)error;

/**
 *  添加请求
 *
 *  @param apiRequest 请求实例
 */
- (void)addRequest:(ApiRequest *)apiRequest;
/**
 *  移除队列中所有请求
 */
- (void)removeAllRequest;
/**
 *  是否正常移除队列中某个请求
 *
 *  @param apiRequest 请求实例
 *  @param normal     是否正常操作
 */
- (void)removeRequest:(ApiRequest *)apiRequest;
/**
 *  取消所有请求
 */
- (void)cancelAllRequest;
/**
 *  重新发送某个请求
 *
 *  @param apiRequest 某个请求实例
 */
- (void)reRequest:(ApiRequest *)apiRequest;
/**
 *  重新发送所有请求
 */
- (void)reRequestAllRequest;

@end
