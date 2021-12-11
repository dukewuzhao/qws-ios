//
//  ApiRequest.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ApiRequest.h"
#import <UIKit/UIKit.h>

#define API_NULL_TOKEN  @""
@implementation ApiRequest {
	NSDictionary *_bizDataDict;
}

@synthesize token = _token;
@synthesize bizDataDict = _bizDataDict;

- (instancetype)init {
	if (self = [super init]) {
		self.token = [[G100InfoHelper shareInstance] token];
		if(!self.token) self.token = API_NULL_TOKEN;
        self.retryCount = MAXRETRYCOUNT;    // 重传次数
        self.timeoutInSeconds = 30;         // 默认超时30s
        self.hasToken = YES;                // 默认带token
        self.isHttps = YES;                 // 默认https请求
        self.needRetry = NO;                // 默认不需要重传
        self.needAddTask = YES;             // 默认添加
	}

	return self;
}

- (id)initWithBizData:(NSDictionary *)dictionary {
	if (self = [self init]) {
		self.bizDataDict = dictionary;
	}
    return self;
}

+ (id)requestWithBizData:(NSDictionary *)dictionary
{
	return [[ApiRequest alloc] initWithBizData:dictionary];
}

#pragma mark - Public Method
- (void)cancelRequest {
    if (self.task) {
        [self.task cancel];
    }
}

@end

@implementation ApiImageRequest

+ (id)requestWithBizData:(NSDictionary *)dictionary
{
    return [[ApiImageRequest alloc] initWithBizData:dictionary];
}

@end

#import <objc/runtime.h>

static const void *ApiRequestListKey = &ApiRequestListKey;
@implementation UIViewController (ApiRequest)

+ (void)load {
    Method originalSelector = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    Method swizzledSelector = class_getInstanceMethod(self, @selector(apiRequest_dealloc));
    method_exchangeImplementations(originalSelector, swizzledSelector);
}

- (void)apiRequest_dealloc {
    // 避免崩溃
    NSMutableArray *array = objc_getAssociatedObject(self, ApiRequestListKey);
    if ([array count]) {
        [self api_cancelAllApiRequest];
    }
    
    // 调用原来的dealloc 方法
    [self apiRequest_dealloc];
}

- (NSMutableArray *)apiRequestList {
    if (!objc_getAssociatedObject(self, ApiRequestListKey)) {
        [self setApiRequestList:[NSMutableArray array]];
    }
    
    return objc_getAssociatedObject(self, ApiRequestListKey);
}

- (void)setApiRequestList:(NSMutableArray *)apiRequestList {
    objc_setAssociatedObject(self, ApiRequestListKey, apiRequestList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)api_addApiRequest:(ApiRequest *)apiRequest {
    [self.apiRequestList addObject:apiRequest];
}

- (void)api_removeApiRequest:(ApiRequest *)apiRequest {
    [self.apiRequestList removeObject:apiRequest];
}
- (void)api_removeAllApiRequest {
    [self.apiRequestList removeAllObjects];
}

- (void)api_cancelApiRequest:(ApiRequest *)apiRequest {
    [apiRequest cancelRequest];
    [self.apiRequestList removeObject:apiRequest];
}

- (void)api_cancelAllApiRequest {
    for (ApiRequest *request in self.apiRequestList) {
        [request cancelRequest];
    }
    [self.apiRequestList removeAllObjects];
}

@end

