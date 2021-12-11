//
//  G100Router.h
//  G100Foundation
//
//  Created by tilink on 10/3/16.
//  Copyright (c) 2016 tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const G100RouterParameterURL;
extern NSString * const G100RouterParameterCompletion;
extern NSString * const G100RouterParameterUserInfo;
extern NSString * const G100RouterParameterRegisterCompletion;

/**
 *  routerParameters 里内置的几个参数会用到上面定义的 string
 */
typedef void (^G100RouterHandler)(NSDictionary *routerParameters);

/**
 *  需要返回一个 object，配合 objectForURL: 使用
 */
typedef id (^G100RouterObjectHandler)(NSDictionary *routerParameters);

@interface G100Router : NSObject

/**
 *  注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
 *
 *  @param URLPattern 带上 scheme，如 qwsapp://home/:userid
 *  @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量。
 *                    假如注册的 URL 为 qwsapp://home/:userid 那么，就会传一个 @{@"userid": 4} 这样的字典过来
 */
+ (void)registerURLPattern:(NSString *)URLPattern toHandler:(G100RouterHandler)handler;

/**
 *  注册 URLPattern 对应的 ObjectHandler，需要返回一个 object 给调用方
 *
 *  @param URLPattern 带上 scheme，如 qwsapp://home/:userid
 *  @param handler    该 block 会传一个字典，包含了注册的 URL 中对应的变量。
 *                    假如注册的 URL 为 qwsapp://home/:userid 那么，就会传一个 @{@"userid": 4} 这样的字典过来
 *                    自带的 key 为 @"url" 和 @"completion" (如果有的话)
 */
+ (void)registerURLPattern:(NSString *)URLPattern toObjectHandler:(G100RouterObjectHandler)handler;

/**
 *  取消注册某个 URL Pattern
 *
 *  @param URLPattern
 */
+ (void)deregisterURLPattern:(NSString *)URLPattern;

/**
 *  打开此 URL
 *  会在已注册的 URL -> Handler 中寻找，如果找到，则执行 Handler
 *
 *  @param URL 带 Scheme，如 qwsapp://home/3
 */
+ (void)openURL:(NSString *)URL;

/**
 *  打开此 URL，同时当操作完成时，执行额外的代码
 *
 *  @param URL        带 Scheme 的 URL，如 qwsapp://home/4
 *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
 */
+ (void)openURL:(NSString *)URL completion:(void (^)(id result))completion;

/**
 *  打开此 URL，带上附加信息，同时当操作完成时，执行额外的代码
 *
 *  @param URL        带 Scheme 的 URL，如 qwsapp://home/4
 *  @param parameters 附加参数
 *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
 */
+ (void)openURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(void (^)(id result))completion;

/**
 * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
 *
 *  @param URL
 */
+ (id)objectForURL:(NSString *)URL;

/**
 * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
 *
 *  @param URL
 *  @param userInfo
 */
+ (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo;

/**
 *  是否可以打开URL
 *
 *  @param URL
 *
 *  @return
 */
+ (BOOL)canOpenURL:(NSString *)URL;

/**
 *  调用此方法来拼接 urlpattern 和 parameters
 *
 *  #define G100_ROUTE_BEAUTY @"home/:userid"
 *  [G100Router generateURLWithPattern:G100_ROUTE_BEAUTY, @[@13]];
 *
 *
 *  @param pattern    url pattern 比如 @"home/:userid"
 *  @param parameters 一个数组，数量要跟 pattern 里的变量一致
 *
 *  @return
 */
+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;
@end
