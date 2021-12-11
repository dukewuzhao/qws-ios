//
//  G100Mediator.h
//  G100
//
//  Created by yuhanle on 16/7/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100NotFoundViewController.h"

@protocol G100ShouldLoginProtocol <NSObject>

- (BOOL)shouldLoginBeforeAction:(NSString *)actionName;

@end

@interface G100Mediator : NSObject

/**
 *  快速创建中间件实例（Mediator）
 *
 *  @return 中间件实例
 */
+ (instancetype)sharedInstance;

/**
 *  远程App调用入口
 *
 *  @param url        远程url
 *  @param completion 接口回调
 *
 *  @return YES/NO
 */
- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *info))completion;
/**
 *  本地模块调用入口
 *
 *  @param targetName 模块类名
 *  @param actionName 方法名
 *  @param params     函数参数
 *
 *  @return YES/NO
 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params;

@end
