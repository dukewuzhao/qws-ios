//
//  G100SchemeHelper.h
//  G100
//
//  Created by yuhanle on 16/3/10.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100Router.h"

@interface G100SchemeHelper : NSObject

/**
 快速创建实例

 @return 管理实例
 */
+ (instancetype)shareInstance;

/**
 添加注册路由
 */
- (void)addQwsScheme;

@end
