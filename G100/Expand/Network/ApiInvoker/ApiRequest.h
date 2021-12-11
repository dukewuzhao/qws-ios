//
//  ApiRequest.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiResponse.h"

#define MAXRETRYCOUNT 3

/**
 *  关于请求实例的说明
 *
 *  在某个业务中调用了网络请求后
 *  从该业务中的容器中保存这个request
 *  请求完成后 容器中remove 掉这个request
 *  如果在请求没有完成之前 业务dealloc 释放的时候
 *  保证同时将容器中暂存request cancel 释放
 */

//api 异步调用回调Block
typedef void (^API_CALLBACK)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess);
//进度回调
typedef void (^Progress_Callback)(float progress);

@interface ApiRequest : NSObject

@property (nonatomic, copy) NSString *api; //!< 接口地址 不包含baseUrl
//数据签名，防篡改
@property (nonatomic, copy) NSString *token; //!< 附带token
@property (nonatomic, assign) BOOL hasToken; //!< 是否带token
@property (nonatomic, assign) BOOL isHttps; //!< 是否https请求
@property (nonatomic, assign) BOOL needRetry; //!< 是否需要重新请求
@property (nonatomic, assign) BOOL needAddTask; //!< 是否需要重新请求
@property (nonatomic, assign) NSInteger retryCount; //!< 重传次数
@property (nonatomic, copy) API_CALLBACK callback; //!< 接口回调
@property (nonatomic, assign) NSUInteger timeoutInSeconds; //!< 请求超时秒数，默认为30s

//业务请求参数
@property (nonatomic, strong) NSDictionary *bizDataDict;
@property (nonatomic, strong) NSURLSessionTask * task;

/**
 *  快速创建请求实例
 *
 *  @param dictionary 请求参数
 *
 *  @return 请求实例
 */
+ (id)requestWithBizData:(NSDictionary *)dictionary;

/**
 取消该请求
 */
- (void)cancelRequest;

@end

@interface ApiImageRequest : ApiRequest

@property (nonatomic, strong) NSArray * imageDataArray;
@property (nonatomic, strong) NSArray * imageNameArray;

@property (nonatomic, copy) Progress_Callback progressCallback;

@end

/**
 *  网络请求实例 容器
 *  
 *  所有在调用网络请求的业务方
 *  在 调用请求以后 将request 存放于此
 *  完成以后remove 掉即可
 */
@interface UIViewController (ApiRequest)

/** 请求容器 */
@property (nonatomic, strong) NSMutableArray *apiRequestList;

/**
 新增新的请求

 @param apiRequest 请求实例
 */
- (void)api_addApiRequest:(ApiRequest *)apiRequest;

/**
 移除某个请求

 @param apiRequest 请求实例
 */
- (void)api_removeApiRequest:(ApiRequest *)apiRequest;

/**
 移除容器中所有的请求 用于请求完成后移除
 */
- (void)api_removeAllApiRequest;

/**
 取消某个请求
 
 @param apiRequest 请求实例
 */
- (void)api_cancelApiRequest:(ApiRequest *)apiRequest;


/**
 取消容器中所有的请求 用户请求未完成时意外造成的cancel 并移除请求
 */
- (void)api_cancelAllApiRequest;

@end
