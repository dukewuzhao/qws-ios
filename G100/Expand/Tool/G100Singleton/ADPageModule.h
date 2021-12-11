//
//  ADPageModule.h
//  G100
//
//  Created by yuhanle on 2018/7/11.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADPageModule : NSObject

/**
 创建开屏图管理模块

 @return 模块
 */
+ (instancetype)pageModule;

/**
 加载开屏图
 */
- (void)loadADPage;

@end
