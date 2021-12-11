//
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSThreadSafeMutableArray.h"
#import "ApiResponse.h"
#import "ApiRequest.h"

#define kApiLoginUrl         @"user/login"
#define kApiValidateTokenUrl @"user/validatetoken"

//api 异步调用回调Block
typedef void (^API_CALLBACK)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess);
//进度回调
typedef void (^Progress_Callback)(float progress);

@protocol AFIdonglerApiInvokerDelegate;
@interface AFIdonglerApiInvoker : NSObject

- (void)requestImage:(ApiRequest *)request imageArray:(NSArray*)imageArray nameArray:(NSArray*)nameArray progress:(Progress_Callback)progressCallback callback:(API_CALLBACK)callback;
/**
 *  发起请求
 *
 *  @param request    请求Request
 *  @param apiRequest 请求实例
 *  @param callback   接口回调
 */
- (void)request:(NSURLRequest *)request apiRequest:(ApiRequest *)apiRequest callback:(API_CALLBACK)callback;

/**
 *  快速创建请求管理实例(http)
 *
 *  @param baseUrl 基地址
 *
 *  @return 请求管理实例
 */
+ (id)apiInvokerWithBaseUrl:(NSString *)baseUrl httpsBaseUrl:(NSString *)httpsBaseUrl;

/**
 *  添加新的请求
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
- (void)removeRequest:(ApiRequest *)apiRequest normal:(BOOL)normal;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;

@property (nonatomic, strong) QSThreadSafeMutableArray *apiRequestArray;
@property (nonatomic, weak) id<AFIdonglerApiInvokerDelegate> delegate;
@end

@protocol AFIdonglerApiInvokerDelegate<NSObject>
@optional
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse;
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse error:(NSError *)error;

@end
