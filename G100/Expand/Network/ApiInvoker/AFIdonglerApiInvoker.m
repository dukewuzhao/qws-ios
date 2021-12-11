//
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "AFIdonglerApiInvoker.h"
#import "ApiResponse.h"
#import "G100Macros.h"

/**
 *  关于自动登陆的解释
 *
 *  自动登陆请求 我们使用了唯一的请求管理器 loginRequestOperationManager
 *  在任何一般请求（包括http 和https）返回token 无效（errcode==06）的时候
 *  回调中cancel http 和https 管理器中的所有请求，同时将队列中的请求 标识为需要重传的状态 needRetry 
 *  因为请求在被cancel 的时候都会走 failed的回调，这个时候根据是否需要重传来判断是否处理这个cancel，以此区分是正常还是非正常的cancel
 *  只要保证 遇到06 的时候，取消所有管理器中的请求，让他们不执行callback，在自动登录以后可以正常发送请求并执行callback 就可以了
 */

@interface AFIdonglerApiInvoker ()

@property (nonatomic, strong) AFHTTPSessionManager * httpSessionManager;//!< 正常请求
@property (nonatomic, strong) AFHTTPSessionManager * httpsSessionManager;//!< https认证请求
@property (nonatomic, strong) AFHTTPSessionManager * loginSessionManager;//!< 登陆请求管理

@property(nonatomic, strong) NSString *baseUrl;
@property(nonatomic, strong) NSString *baseHttpsUrl;
@property(nonatomic, assign) BOOL isLogining; //!< 登录中...
@end

@implementation AFIdonglerApiInvoker

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        // 监听当前网络变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(kAFIdonglerApiInvokerNetworkChanged:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
        
        _isLogining = NO;
    }
    
    return self;
}

#pragma mark - 懒加载
- (QSThreadSafeMutableArray *)apiRequestArray {
    if (!_apiRequestArray) {
        _apiRequestArray = [[QSThreadSafeMutableArray alloc] init];
    }
    return _apiRequestArray;
}

#pragma mark - 发送请求
- (void)requestImage:(ApiRequest *)request imageArray:(NSArray*)imageArray nameArray:(NSArray*)nameArray progress:(Progress_Callback)progressCallback callback:(API_CALLBACK)callback {
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        if ([self.delegate respondsToSelector:@selector(handleError:apiRequest:response:)]) {
            [self.delegate handleError:-200 apiRequest:nil response:nil];
        }
        if (callback) {
            callback(0, nil, NO);
        }
        return;
    }
    /**
     *  如果不是登陆或者验证token
     *  就可以重传 重传需要添加到数组中保存实例
     */
    __weak AFIdonglerApiInvoker *weakSelf = self;
    AFHTTPSessionManager *session = self.httpsSessionManager;
    NSURLSessionTask *task = [session POST:request.api parameters:request.bizDataDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        int i = 0;
        for (NSData *imageData in imageArray) {
            NSString *name = nameArray[i];
            if ([imageData isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:imageData name:name fileName:name mimeType:@"image/*"];
            }
            i++;
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressCallback) {
            // 32位处理器 不能读取到这个值 就不返回结果
            if (uploadProgress.totalUnitCount) {
                progressCallback((float)uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
            }
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (progressCallback) {
            progressCallback(1);
        }
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (!responseObject) {
            IDLog(IDLogTypeInfo, @"OK, request %@ response is %@", request, responseObject);
        }
        else {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            IDLog(IDLogTypeInfo, @"OK, request %@ response is %@", request, jsonStr);
            
        }
        responseObject = AFJSONObjectByRemovingKeysWithNullValues(responseObject, NSJSONReadingMutableContainers);
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)task.response;
        if (callback) {
            ApiResponse *apiResponse = nil;
            @try {
                apiResponse = [[ApiResponse alloc] initWithDictionary:responseObject];
                if (!apiResponse.success && [weakSelf.delegate respondsToSelector:@selector(handleError:apiRequest:response:)]) {
                    [weakSelf.delegate handleError:httpResponse.statusCode apiRequest:nil response:apiResponse];
                }
            }
            @catch (NSException *exception) {
                IDLog(IDLogTypeError, @"Exception occurred: %@, %@", exception, [exception userInfo]);
                id <AFIdonglerApiInvokerDelegate> o = weakSelf.delegate;
                if ([o respondsToSelector:@selector(handleError:apiRequest:response:)]) {
                    [o handleError:httpResponse.statusCode apiRequest:nil response:apiResponse];
                }
                if (callback) {
                    callback(0, nil, NO);
                }
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)task.response;
        IDLog(IDLogTypeError, @"ERROR! request %@ statusCode is %li, \n\r%@", request, (long)httpResponse.statusCode, error);
        
        id <AFIdonglerApiInvokerDelegate> o = weakSelf.delegate;
        if ([o respondsToSelector:@selector(handleError:apiRequest:response:)]) {
            [o handleError:error.code apiRequest:nil response:nil];
        }
        if (callback) {
            callback(httpResponse.statusCode, nil, NO);
        }
    }];
    [task resume];
    request.task = task;
}

- (void)request:(NSURLRequest *)request apiRequest:(ApiRequest *)apiRequest callback:(API_CALLBACK)callback {
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        if ([self.delegate respondsToSelector:@selector(handleError:apiRequest:response:)]) {
            [self.delegate handleError:-200 apiRequest:apiRequest response:nil];
        }
        if (callback) {
            callback(0, nil, NO);
        }
        return;
    }
    
    /**
     *  如果不是登陆或者验证token
     *  就可以重传 重传需要添加到数组中保存实例
     */
    __block ApiRequest *blockApiRequest = apiRequest;
    //[self addRequest:blockApiRequest];
    
    /**
     *  如果登陆的请求仍然没有回来 
     *  拦截掉其他请求，并加入到队列中
     */
    if (_isLogining) {
        return;
    }
    
    if ([blockApiRequest.api isEqualToString:kApiLoginUrl]) {
        _isLogining = YES;
    }
    AFHTTPSessionManager * sessionManager = nil;
    if ([blockApiRequest.api isEqualToString:kApiLoginUrl]) {
        sessionManager = self.loginSessionManager;
    }else {
        sessionManager = blockApiRequest.isHttps ? self.httpsSessionManager : self.httpSessionManager;
    }
    
    if (![self beforeExecute:sessionManager]) {
        return;
    }
    
    __weak AFIdonglerApiInvoker *weakSelf = self;
    NSURLSessionTask * task = [sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (!responseObject) {
                 IDLog(IDLogTypeInfo, @"OK, request %@ response is %@", request, responseObject);
            }
            else {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                IDLog(IDLogTypeInfo, @"OK, request %@ response is %@", request, jsonStr);

            }
            responseObject = AFJSONObjectByRemovingKeysWithNullValues(responseObject, NSJSONReadingMutableContainers);
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            if ([blockApiRequest.api isEqualToString:kApiLoginUrl]) {
                weakSelf.isLogining = NO;
            }
            ApiResponse *apiResponse = nil;
            @try {
                apiResponse = [[ApiResponse alloc] initWithDictionary:responseObject];
                // 判断是否超过重传次数
                if (blockApiRequest.retryCount <= 0) {
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                    if (callback) {
                        callback(httpResponse.statusCode, apiResponse, apiResponse.success);
                    }
                    return;
                }
                /**
                 * 如果此时处于被抢占登陆的状态 则直接callback回去 并取消其他所有请求
                 */
                if ([UserManager shareManager].remoteLogin) {
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                    if (callback) {
                        callback(httpResponse.statusCode, apiResponse, apiResponse.success);
                    }
                        
                    // 如果被抢占 则取消所有请求
                    [weakSelf cancelAllRequest];
                    return;
                }
                
                if (apiResponse.errCode == 6) {
                    // 将其他请求标志为 需要重传
                    for (NSInteger i = 0; i < [weakSelf.apiRequestArray count]; i++) {
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^{
                            ApiRequest *ar = [weakSelf.apiRequestArray safe_objectAtIndex:i];
                            ar.needRetry = YES;
                        });
                    }
                    
                    // 取消所有请求
                    [weakSelf cancelAllRequest];
                }
                
                if (!apiResponse.success && [weakSelf.delegate respondsToSelector:@selector(handleError:apiRequest:response:)]) {
                    [weakSelf.delegate handleError:httpResponse.statusCode apiRequest:blockApiRequest response:apiResponse];
                }
                
                if (apiResponse.errCode != 6) {
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                    if (callback) {
                        callback(httpResponse.statusCode, apiResponse, apiResponse.success);
                    }
                }
            }
            @catch (NSException *exception) {
                IDLog(IDLogTypeError, @"Exception occurred: %@, %@", exception, [exception userInfo]);
                id <AFIdonglerApiInvokerDelegate> o = weakSelf.delegate;
                if ([o respondsToSelector:@selector(handleError:apiRequest:response:)]) {
                    [o handleError:httpResponse.statusCode apiRequest:blockApiRequest response:apiResponse];
                }
                if (callback){
                    callback(0, nil, NO);
                }
                [weakSelf removeRequest:blockApiRequest normal:YES];
            }

        }
        else {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            IDLog(IDLogTypeError, @"ERROR! request %@ statusCode is %li, \n\r%@", request, (long)httpResponse.statusCode, error);
            if ([blockApiRequest.api isEqualToString:kApiLoginUrl]) {
                weakSelf.isLogining = NO;
            }
            
            if (error.code == -999) {
                IDLog(IDLogTypeWarning, @"request cancel %@ statusCode %li needRetry %@", request, (long)httpResponse.statusCode, @(blockApiRequest.needRetry));
                // 用户取消请求
                if (blockApiRequest.needRetry) {
                    // 需要重传则不处理
                    
                }else {
                    id <AFIdonglerApiInvokerDelegate> o = weakSelf.delegate;
                    if ([o respondsToSelector:@selector(handleError:apiRequest:response:error:)]) {
                        [o handleError:httpResponse.statusCode apiRequest:blockApiRequest response:nil error:error];
                    }
                    
                    if (callback) {
                        callback(httpResponse.statusCode, nil, NO);
                    }
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                }
            }else {
                // 判断是否超过重传次数
                if (blockApiRequest.retryCount <= 0) {
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                    if (callback) {
                        callback(httpResponse.statusCode, nil, NO);
                    }
                }else if ([UserManager shareManager].remoteLogin) {
                    /**
                     *  如果此时处于被抢占登陆的状态 则直接callback回去 并取消其他所有请求
                     */
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                    if (callback)
                        callback(httpResponse.statusCode, nil, NO);
                    // 如果被抢占 则取消所有请求
                    [weakSelf cancelAllRequest];
                }else {
                    id <AFIdonglerApiInvokerDelegate> o = weakSelf.delegate;
                    if ([o respondsToSelector:@selector(handleError:apiRequest:response:error:)]) {
                        [o handleError:httpResponse.statusCode apiRequest:blockApiRequest response:nil error:error];
                    }
                    
                    if (callback) {
                        callback(httpResponse.statusCode, nil, NO);
                    }
                    [weakSelf removeRequest:blockApiRequest normal:YES];
                }
            }
        }
    }];
    [task resume];
    blockApiRequest.task = task;
}

#pragma mark - 初始化基地址 
+ (id)apiInvokerWithBaseUrl:(NSString *)baseUrl httpsBaseUrl:(NSString *)httpsBaseUrl {
    static AFIdonglerApiInvoker * invoker;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        invoker = [[self alloc] init];
    });

    // http 请求 manager
    invoker.baseUrl = baseUrl;
    assert(invoker.baseUrl);
    invoker.httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:invoker.baseUrl]];
    [invoker.httpSessionManager.operationQueue setMaxConcurrentOperationCount:2];
    invoker.httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    invoker.httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
     
    // https 请求 manager
    invoker.baseHttpsUrl = httpsBaseUrl;
    assert(invoker.baseHttpsUrl);
    invoker.httpsSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:invoker.baseHttpsUrl]];
    [invoker.httpsSessionManager.operationQueue setMaxConcurrentOperationCount:2];
    
    invoker.httpsSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    invoker.httpsSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //[invoker.httpsSessionManager setSecurityPolicy:[self customSecurityPolicy]];
     
    // login 请求 manager
    invoker.loginSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:invoker.baseHttpsUrl]];
    [invoker.loginSessionManager.operationQueue setMaxConcurrentOperationCount:1];
    
    invoker.loginSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    invoker.loginSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //[invoker.loginSessionManager setSecurityPolicy:[self customSecurityPolicy]];
    
	return invoker;
}

#pragma mark - HTTPS
+ (AFSecurityPolicy*)customSecurityPolicy
{
    // 先导入证书
    NSString *cerPath1 = [[NSBundle mainBundle] pathForResource:@"qws_root" ofType:@"cer"];//证书的路径
    NSData *certData1 = [NSData dataWithContentsOfFile:cerPath1];
    
    NSString *cerPath2 = [[NSBundle mainBundle] pathForResource:@"1_Intermediate" ofType:@"cer"];//证书的路径
    NSData *certData2 = [NSData dataWithContentsOfFile:cerPath2];
    
    NSString *cerPath3 = [[NSBundle mainBundle] pathForResource:@"2_api_360qws_cn" ofType:@"cer"];//证书的路径
    NSData *certData3 = [NSData dataWithContentsOfFile:cerPath3];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    // validatesDomainName 是否需要验证域名，默认为YES；
    // 假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    // 置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    // 如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    //validatesCertificateChain 是否验证整个证书链，默认为YES
    //设置为YES，会将服务器返回的Trust Object上的证书链与本地导入的证书进行对比，这就意味着，假如你的证书链是这样的：
    //GeoTrust Global CA
    //    Google Internet Authority G2
    //        *.google.com
    //那么，除了导入*.google.com之外，还需要导入证书链上所有的CA证书（GeoTrust Global CA, Google Internet Authority G2）；
    //如是自建证书的时候，可以设置为YES，增强安全性；假如是信任的CA所签发的证书，则建议关闭该验证，因为整个证书链一一比对是完全没有必要（请查看源代码）；
    //securityPolicy.validatesCertificateChain = YES;
    
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certData1, certData2, certData3, nil];
    return securityPolicy;
}

#pragma mark - 处理操作
- (void)addRequest:(ApiRequest *)apiRequest {
    if ([apiRequest.api isEqualToString:kApiLoginUrl] ||
        [apiRequest.api isEqualToString:kApiValidateTokenUrl]) {
        return;
    }

    if (apiRequest.needAddTask) {
        // bugfix: 此处有崩溃
        @try {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [self.apiRequestArray addObject:apiRequest];
            });
            apiRequest.needAddTask = NO;
        }
        @catch (NSException *exception) {
            IDLog(IDLogTypeError, @"Exception occurred: %@, %@", exception, [exception userInfo]);
            @throw;
        }
    }else {
        apiRequest.retryCount--;
        if (apiRequest.retryCount <= 0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [self.apiRequestArray removeObject:apiRequest];
            });
        }
    }
}

- (void)removeAllRequest {
    for (NSInteger i = 0; i < [self.apiRequestArray count]; i++) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            ApiRequest * apiRequest = [self.apiRequestArray safe_objectAtIndex:i];
            [self removeRequest:apiRequest normal:NO];
        });
    }
}

- (void)removeRequest:(ApiRequest *)apiRequest normal:(BOOL)normal {
    if (normal) {
        
    }else {
        API_CALLBACK callback = apiRequest.callback;
        if (callback) {
            callback(0, nil, NO);
        }
        
        [self cancellTheRequest:apiRequest];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.apiRequestArray removeObject:apiRequest];
    });
}

- (void)cancelAllRequest {
    for (NSInteger i = 0; i < self.httpSessionManager.dataTasks.count; i++) {
        NSURLSessionTask * task = [self.httpSessionManager.dataTasks safe_objectAtIndex:i];
        [task cancel];
    }
    for (NSInteger i = 0; i < self.httpsSessionManager.dataTasks.count; i++) {
        NSURLSessionTask * task = [self.httpsSessionManager.dataTasks safe_objectAtIndex:i];
        [task cancel];
    }
}

- (void)cancellTheRequest:(ApiRequest *)apiRequest {
    AFHTTPSessionManager * manager = apiRequest.isHttps ? self.httpsSessionManager : self.httpSessionManager;
    
    for (NSInteger i = 0; i < manager.dataTasks.count; i++) {
        NSURLSessionTask * task = [manager.dataTasks safe_objectAtIndex:i];
        if (task == apiRequest.task) {
            [task cancel];
        }
    }
}

#pragma mark - 请求过程中网络情况判断
- (BOOL)beforeExecute:(AFHTTPSessionManager *)manager {
    NSOperationQueue *operationQueue = manager.operationQueue;
    switch (manager.reachabilityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            [operationQueue setSuspended:NO];
            operationQueue.maxConcurrentOperationCount = 2;
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            [operationQueue setSuspended:NO];
            operationQueue.maxConcurrentOperationCount = 3;
        }
            break;
        case AFNetworkReachabilityStatusNotReachable:
        {
            [operationQueue setSuspended:YES];
        }
            break;
        default:
        {
            [operationQueue setSuspended:NO];
        }
            break;
    }
    
    return true;
}

#pragma mark - 网络状态监听
- (void)kAFIdonglerApiInvokerNetworkChanged:(NSNotification *)notification {
    NSInteger status = [[[notification userInfo]objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
        {
            [self.httpSessionManager.operationQueue setSuspended:YES];
            [self.httpsSessionManager.operationQueue setSuspended:YES];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            [self.httpSessionManager.operationQueue setSuspended:NO];
            [self.httpsSessionManager.operationQueue setSuspended:NO];
        }
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            [self.httpSessionManager.operationQueue setSuspended:NO];
            [self.httpsSessionManager.operationQueue setSuspended:NO];
        }
            break;
        default:
        {
            [self.httpSessionManager.operationQueue setSuspended:NO];
            [self.httpsSessionManager.operationQueue setSuspended:NO];
        }
            break;
    }
}

static id AFJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:AFJSONObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = [(NSDictionary *)JSONObject objectForKey:key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                [mutableDictionary setObject:AFJSONObjectByRemovingKeysWithNullValues(value, readingOptions) forKey:key];
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}

@end
