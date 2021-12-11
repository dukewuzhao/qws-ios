//
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//


#import "ApiInvoker.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "G100Macros.h"

#define API_BASE_URL(url) ([NSURL URLWithString:url])

@interface ApiInvoker () <AFIdonglerApiInvokerDelegate>

@property (nonatomic, copy) NSString *apiBaseUrl;   //!< 接口地址
@property (nonatomic, copy) NSString *apiHttpsBaseUrl;  //!< https接口地址
@property (nonatomic, strong) AFIdonglerApiInvoker *apiInvoker; //!< 网络请求管理类

@end

@implementation ApiInvoker {

}

@synthesize apiInvoker = _apiInvoker;
@synthesize apiBaseUrl = _apiBaseUrl;
@synthesize apiHttpsBaseUrl = _apiHttpsBaseUrl;

- (id)init {
    self = [super init];
    if (self) {
        
    }

    return self;
}

- (void)requestApi:(NSString *)api withMethod:(NSString *)httpMethod andRequest:(ApiRequest *)apiRequest callback:(API_CALLBACK)callback {
	//通过encodeApiRequest_iOS6: 得到请求的请求体 （参数排序、拼接成请求字符串）
    NSString *body = ([self encodeApiRequest_iOS6:apiRequest]);
    NSString *completeApiUrl = nil;
	//判断是get还是post请求 拼接成完整的请求url
    if ([self isGet:httpMethod] || [self isDelete:httpMethod]) {
        //get 和 delete方法的body放在queryString
        completeApiUrl = [NSString stringWithFormat:@"%@?%@", api, body];
    } else {
        completeApiUrl = api;
    }
    
    NSURL *url = [NSURL URLWithString:completeApiUrl relativeToURL:API_BASE_URL(apiRequest.isHttps ? self.apiHttpsBaseUrl : self.apiBaseUrl)];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //设置超时时间:默认 30秒
    [request setTimeoutInterval:apiRequest.timeoutInSeconds];
    [request setValue:[UserManager shareManager].reqUa forHTTPHeaderField:@"User-Agent"];
    if ([UserManager shareManager].env.length) {
        [request setValue:[UserManager shareManager].env forHTTPHeaderField:@"TY-Env"];
    }

	//设置请求方式为传递的请求参数的方
    [request setHTTPMethod:httpMethod];
    NSDictionary * params = [self encodeJSONApiRequest_iOS6:apiRequest];
    if ([self isPost:httpMethod] || [self isPut:httpMethod]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"content-type"]; //请求头
        [request setHTTPBody:[params mj_JSONData]];
    }

    [self.apiInvoker request:request apiRequest:apiRequest callback:callback];

    IDLog(IDLogTypeInfo, @"OK, request %@ data is %@", request, params);
}

- (void)requestApi:(NSString *)api andRequest:(ApiRequest *)apiRequest imageArray:(NSArray*)imageArray nameArray:(NSArray*)nameArray progress:(Progress_Callback)progressCallback callback:(API_CALLBACK)callback {
    NSString *completeApiUrl = api;

    NSURL *url = [NSURL URLWithString:completeApiUrl relativeToURL:API_BASE_URL(apiRequest.isHttps ? self.apiHttpsBaseUrl : self.apiBaseUrl)];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //设置超时时间:默认 30秒
    [request setTimeoutInterval:120];
    [request setValue:[UserManager shareManager].reqUa forHTTPHeaderField:@"User-Agent"];
    if ([UserManager shareManager].env.length) {
        [request setValue:[UserManager shareManager].env forHTTPHeaderField:@"TY-Env"];
    }
    
    //设置请求方式为传递的请求参数的方
    [request setHTTPMethod:@"POST"];
    NSDictionary * params = [self encodeJSONApiRequest_iOS6:apiRequest];
    //[request setValue:@"application/json" forHTTPHeaderField:@"content-type"]; //请求头
    //[request setHTTPBody:[params mj_JSONData]];
    apiRequest.bizDataDict = params;
    [self.apiInvoker requestImage:apiRequest imageArray:imageArray nameArray:nameArray progress:progressCallback callback:callback];
}

-(NSDictionary *)encodeJSONApiRequest_iOS6:(ApiRequest *)request {
    @autoreleasepool {
        NSMutableDictionary * JSONBody = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:request.bizDataDict];
        NSString *token = [[G100InfoHelper shareInstance] token];
        if (NOT_NULL(token) && request.hasToken)
        {
            [dict setObject:token forKey:@"token"];
        }
        
        NSArray *keys = [dict allKeys];
        
        NSComparator comparator =  ^(id obj1, id obj2){
            NSString *key1 = obj1;
            NSString *key2 = obj2;
            return [key1 compare:key2];
        };
        NSArray *sortedKeys = [keys sortedArrayUsingComparator:comparator];
        
        for (NSString * key in sortedKeys) {
            NSString *value = [dict objectForKey:key];
            [JSONBody setValue:value forKey:key];
        }
        
        return JSONBody.copy;
    }
}
- (NSString *)encodeApiRequest_iOS6:(ApiRequest *)request {
	@autoreleasepool {
		//在这个方法内对参数进行排列 然后按顺序拼接成请求的URL
		//ENT CS 参数算法
		NSMutableArray *namedValuePair = [[NSMutableArray alloc] init];

		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:request.bizDataDict];
		NSString *token = [[G100InfoHelper shareInstance] token];
		if (NOT_NULL(token) && request.hasToken)
		{
			[dict setObject:token forKey:@"token"];
		}
		NSArray *keys = [dict allKeys];

		NSComparator comparator =  ^(id obj1, id obj2){
			NSString *key1 = obj1;
			NSString *key2 = obj2;
			return [key1 compare:key2];
		};
		NSArray *sortedKeys = [keys sortedArrayUsingComparator:comparator];
		
		NSMutableArray *values = [[NSMutableArray alloc] init];
		for(NSString *key in sortedKeys){
			NSString *value = [dict objectForKey:key];
			[values addObject:value];
			[namedValuePair addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
		}
        
		NSString *returnString = [namedValuePair componentsJoinedByString:@"&"];
		return returnString;
	}
}
- (NSString *)md5:(NSString *) input
{
	const char *cStr = [input UTF8String];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call

	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];

	return  output;
}

//统一处理错误
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse {
    
}
- (void)handleError:(NSInteger)statusCode apiRequest:(ApiRequest *)apiRequest response:(ApiResponse *)apiResponse error:(NSError *)error {

}

- (BOOL)isGet:(NSString *)httpMethod {
    return [[httpMethod lowercaseString] isEqualToString:@"get"];
}

- (BOOL)isPut:(NSString *)httpMethod {
    return [[httpMethod lowercaseString] isEqualToString:@"put"];
}

- (BOOL)isDelete:(NSString *)httpMethod {
    return [[httpMethod lowercaseString] isEqualToString:@"delete"];
}

- (BOOL)isPost:(NSString *)httpMethod {
    return [[httpMethod lowercaseString] isEqualToString:@"post"];
}

- (void)setupApiBaseUrl:(NSString *)apiBaseUrl apiHttpsBaseUrl:(NSString *)apiHttpsBaseUrl {
	_apiBaseUrl = apiBaseUrl;
    _apiHttpsBaseUrl = apiHttpsBaseUrl;
	self.apiInvoker = [AFIdonglerApiInvoker apiInvokerWithBaseUrl:self.apiBaseUrl httpsBaseUrl:apiHttpsBaseUrl];
	self.apiInvoker.delegate = self;
}

-(void)addRequest:(ApiRequest *)apiRequest {
    [self.apiInvoker addRequest:apiRequest];
}

-(void)removeAllRequest {
    [self.apiInvoker removeAllRequest];
}

-(void)removeRequest:(ApiRequest *)apiRequest {
    [self.apiInvoker removeRequest:apiRequest normal:NO];
}

-(void)cancelAllRequest {
    [self.apiInvoker cancelAllRequest];
}

-(void)reRequest:(ApiRequest *)apiRequest {
    NSString * token = [[G100InfoHelper shareInstance] token];
    if (NOT_NULL(token)) {
        if (apiRequest.hasToken) {
            self.token = token;
            NSMutableDictionary * dataDict = apiRequest.bizDataDict.mutableCopy;
            [dataDict setObject:self.token forKey:@"token"];
            apiRequest.bizDataDict = dataDict.copy;
        }
        
        if ([apiRequest isKindOfClass:[ApiImageRequest class]]) {
            ApiImageRequest * request = (ApiImageRequest*)apiRequest;
            [self requestApi:request.api
                  andRequest:request
                  imageArray:request.imageDataArray
                   nameArray:request.imageNameArray
                    progress:request.progressCallback
                    callback:request.callback];
        }else if ([apiRequest isKindOfClass:[ApiRequest class]]) {
            [self requestApi:apiRequest.api
                  withMethod:@"POST"
                  andRequest:apiRequest
                    callback:apiRequest.callback];
        }
    }else {
        [self removeRequest:apiRequest];
    }
}

-(void)reRequestAllRequest {
    // 保证多线程安全
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger i = 0; i < [self.apiInvoker.apiRequestArray count]; i++) {
        dispatch_async(queue, ^{
            ApiRequest * apiRequest = [self.apiInvoker.apiRequestArray safe_objectAtIndex:i];
            if ([apiRequest.api isEqualToString:kApiLoginUrl] ||
                [apiRequest.api isEqualToString:kApiValidateTokenUrl] ||
                apiRequest.api == nil) {
                [self removeRequest:apiRequest];
            }else {
                [self reRequest:apiRequest];
            }
        });
    }
}

@end
